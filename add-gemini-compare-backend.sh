#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🤖 Adding Gemini Compare to Backend..."
echo ""

# ============================================================
# 1. آپدیت ai.service.js (اضافه کردن تابع)
# ============================================================
cat > src/services/ai.service.js << 'ENDOFFILE'
import { geminiModel } from '../config/gemini.js'
import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

// ============================================================
// Product description generator
// ============================================================
export const generateDescription = async ({ title, features, category, brand, tone }) => {
  const toneMap = {
    professional: 'professional and clear',
    casual: 'casual and friendly',
    luxury: 'elegant and premium',
    friendly: 'warm and welcoming',
  }

  const prompt = `Write a compelling e-commerce product description.

Product: ${title}
${brand ? `Brand: ${brand}` : ''}
${category ? `Category: ${category}` : ''}
${features?.length ? `Key features:\n${features.map((f) => `- ${f}`).join('\n')}` : ''}
Tone: ${toneMap[tone] || toneMap.professional}

Requirements:
- Length: 2-3 short paragraphs (about 100-150 words)
- Focus on benefits, not just features
- Be persuasive but honest
- No emojis, no markdown headers, no bullet points
- Return only the description text

Description:`

  const result = await geminiModel.generateContent(prompt)
  const text = result.response.text().trim()

  return { description: text }
}

// ============================================================
// Smart search (natural language → structured filters)
// ============================================================
export const smartSearch = async (query) => {
  const prompt = `Extract structured search filters from this natural-language e-commerce query.

Query: "${query}"

Available categories: mobile-phones, laptops, headphones-audio, cameras, smartwatches, gaming, mens-clothing, womens-clothing, shoes, bags-accessories
Available brands: Apple, Samsung, Sony, Google, Microsoft, Dell, HP, Lenovo, Asus, Xiaomi, Nike, Adidas, Levi's, Zara, H&M, Dyson, Philips, Bose, Canon, Nikon

Return ONLY valid JSON in this exact shape (no markdown, no extra text):
{
  "category": "category-slug or null",
  "brand": "Brand name or null",
  "minPrice": number or null,
  "maxPrice": number or null,
  "keywords": ["array", "of", "keywords"],
  "sort": "price-asc | price-desc | rating | newest | null"
}

JSON:`

  const result = await geminiModel.generateContent(prompt)
  let text = result.response.text().trim()

  text = text.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim()

  try {
    const filters = JSON.parse(text)
    return { filters, originalQuery: query }
  } catch {
    return {
      filters: { category: null, brand: null, keywords: [query], sort: null },
      originalQuery: query,
    }
  }
}

// ============================================================
// Customer support chat
// ============================================================
export const chat = async ({ message, history = [] }) => {
  const systemContext = `You are a helpful customer support assistant for MarketHub, an e-commerce store.
You help customers with:
- Finding products
- Order status questions
- Return and refund policies
- Shipping information
- General questions

Be friendly, concise, and helpful. If you don't know something specific to the customer's account,
politely suggest they check their account page or contact support@markethub.com.
Keep replies under 3 short paragraphs.`

  const contents = [
    { role: 'user', parts: [{ text: systemContext }] },
    ...history.map((h) => ({
      role: h.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: h.content }],
    })),
    { role: 'user', parts: [{ text: message }] },
  ]

  const result = await geminiModel.generateContent({ contents })
  const reply = result.response.text().trim()

  return { reply }
}

// ============================================================
// Recommendations
// ============================================================
export const recommendProducts = async ({ product_id, limit = 6 }) => {
  if (product_id) {
    const { data: product } = await supabaseAdmin
      .from('products')
      .select('id, title, description, category_id, brand_id, price')
      .eq('id', product_id)
      .maybeSingle()

    if (!product) throw ApiError.notFound('Product not found')

    const { data: similar } = await supabaseAdmin
      .from('products')
      .select(
        'id, title, slug, price, old_price, discount, thumbnail, rating, num_reviews, is_prime'
      )
      .eq('category_id', product.category_id)
      .neq('id', product_id)
      .eq('is_active', true)
      .order('rating', { ascending: false })
      .limit(limit)

    return { products: similar || [], basis: 'similar' }
  }

  const { data: top } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, rating, num_reviews, is_prime'
    )
    .eq('is_active', true)
    .order('rating', { ascending: false })
    .order('sold_count', { ascending: false })
    .limit(limit)

  return { products: top || [], basis: 'popular' }
}

// ============================================================
// Translate
// ============================================================
export const translateText = async ({ text, targetLanguage }) => {
  const prompt = `Translate the following text to ${targetLanguage}. Return ONLY the translation, no extra text.

Text:
${text}`

  const result = await geminiModel.generateContent(prompt)
  return { translation: result.response.text().trim() }
}

// ============================================================
// 🤖 Compare Products with Gemini (جدید!)
// ============================================================
export const compareProducts = async ({ product_ids }) => {
  if (!product_ids || product_ids.length < 2) {
    throw ApiError.badRequest('At least 2 products required for comparison')
  }
  if (product_ids.length > 4) {
    throw ApiError.badRequest('Maximum 4 products for comparison')
  }

  // Fetch products with full details
  const { data: products, error } = await supabaseAdmin
    .from('products')
    .select(`
      id, title, price, old_price, discount, rating, num_reviews,
      stock, features, specifications, short_description,
      brand:brands(id, name)
    `)
    .in('id', product_ids)

  if (error) throw ApiError.badRequest(error.message)
  if (!products || products.length < 2) {
    throw ApiError.badRequest('Could not find enough products')
  }

  // Build a detailed product description for Gemini
  const productsText = products
    .map((p, i) => {
      const specs = p.specifications && Object.keys(p.specifications).length > 0
        ? Object.entries(p.specifications)
            .map(([k, v]) => `    - ${k}: ${v}`)
            .join('\n')
        : '    (none provided)'

      const features = p.features && p.features.length > 0
        ? p.features.map((f) => `    - ${f}`).join('\n')
        : '    (none provided)'

      return `Product ${i + 1}:
  Title: ${p.title}
  Brand: ${p.brand?.name || 'Unknown'}
  Price: $${p.price}${p.old_price ? ` (was $${p.old_price}, ${p.discount}% off)` : ''}
  Rating: ${p.rating || 0}/5 (${p.num_reviews || 0} reviews)
  Stock: ${p.stock > 0 ? 'In stock' : 'Out of stock'}
  Features:
${features}
  Specifications:
${specs}
${p.short_description ? `  Description: ${p.short_description}` : ''}`
    })
    .join('\n\n')

  const prompt = `You are an expert product comparison assistant for an e-commerce store.
A customer is comparing the following products. Analyze them and provide a helpful comparison.

${productsText}

Please provide a comprehensive comparison in this EXACT JSON format (no markdown, no extra text, valid JSON only):

{
  "summary": "A 2-3 sentence overall summary of the comparison",
  "winner": {
    "product_index": 0,
    "reason": "Why this product wins overall (1-2 sentences)"
  },
  "best_for": {
    "budget": {
      "product_index": 0,
      "reason": "Best for budget-conscious buyers"
    },
    "performance": {
      "product_index": 0,
      "reason": "Best for performance/features"
    },
    "value": {
      "product_index": 0,
      "reason": "Best overall value"
    }
  },
  "pros_cons": [
    {
      "product_index": 0,
      "pros": ["pro1", "pro2", "pro3"],
      "cons": ["con1", "con2"]
    }
  ],
  "key_differences": [
    "Difference 1 in plain language",
    "Difference 2 in plain language",
    "Difference 3 in plain language"
  ],
  "recommendation": "Final recommendation paragraph (2-3 sentences) telling the customer which one to choose and why, considering common use cases"
}

IMPORTANT RULES:
- product_index refers to the position in the list above (0-indexed)
- Each pros/cons array should have 2-4 items
- Each item should be a SHORT phrase (5-10 words)
- Be objective and honest — don't favor any brand
- If a product is clearly better, say so in the "winner" field
- Base analysis on the actual data provided, don't make up specs

JSON:`

  const result = await geminiModel.generateContent(prompt)
  let text = result.response.text().trim()

  // Clean markdown fences if present
  text = text.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim()

  try {
    const analysis = JSON.parse(text)

    // Attach product info to the response for convenience
    return {
      analysis,
      products: products.map((p) => ({
        id: p.id,
        title: p.title,
        price: p.price,
        rating: p.rating,
        thumbnail: null,
      })),
    }
  } catch (err) {
    console.error('❌ Gemini compare parse failed:', text)
    throw ApiError.internal('Failed to parse AI comparison')
  }
}
ENDOFFILE

echo "✅ ai.service.js updated with compareProducts"

# ============================================================
# 2. آپدیت ai.controller.js
# ============================================================
cat > src/controllers/ai.controller.js << 'ENDOFFILE'
import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  generateDescription,
  smartSearch,
  chat,
  recommendProducts,
  translateText,
  compareProducts,
} from '../services/ai.service.js'

export const generateProductDescription = asyncHandler(async (req, res) => {
  const result = await generateDescription(req.body)
  return ApiResponse.success(res, result, 'Description generated')
})

export const smartSearchCtrl = asyncHandler(async (req, res) => {
  const result = await smartSearch(req.body.query)
  return ApiResponse.success(res, result, 'Search parsed')
})

export const chatCtrl = asyncHandler(async (req, res) => {
  const result = await chat(req.body)
  return ApiResponse.success(res, result, 'Reply generated')
})

export const recommendCtrl = asyncHandler(async (req, res) => {
  const { product_id, limit } = req.body
  const result = await recommendProducts({ product_id, limit })
  return ApiResponse.success(res, result, 'Recommendations')
})

export const translateCtrl = asyncHandler(async (req, res) => {
  const result = await translateText(req.body)
  return ApiResponse.success(res, result, 'Translation')
})

export const compareCtrl = asyncHandler(async (req, res) => {
  const result = await compareProducts(req.body)
  return ApiResponse.success(res, result, 'Comparison generated')
})
ENDOFFILE

echo "✅ ai.controller.js updated"

# ============================================================
# 3. آپدیت ai.routes.js
# ============================================================
cat > src/routes/ai.routes.js << 'ENDOFFILE'
import { Router } from 'express'
import {
  generateProductDescription,
  smartSearchCtrl,
  chatCtrl,
  recommendCtrl,
  translateCtrl,
  compareCtrl,
} from '../controllers/ai.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import {
  generateDescriptionSchema,
  smartSearchSchema,
  chatSchema,
  recommendSchema,
  compareSchema,
} from '../validators/ai.schema.js'

const router = Router()

// Public
router.post('/smart-search', validateBody(smartSearchSchema), smartSearchCtrl)
router.post('/chat', validateBody(chatSchema), chatCtrl)
router.post('/recommend', validateBody(recommendSchema), recommendCtrl)

// Auth required
router.post('/compare', requireAuth, validateBody(compareSchema), compareCtrl)

// Admin only
router.post(
  '/generate-description',
  requireAuth,
  requireAdmin,
  validateBody(generateDescriptionSchema),
  generateProductDescription
)

router.post('/translate', requireAuth, requireAdmin, translateCtrl)

export default router
ENDOFFILE

echo "✅ ai.routes.js updated"

# ============================================================
# 4. آپدیت ai.schema.js
# ============================================================
cat > src/validators/ai.schema.js << 'ENDOFFILE'
import { z } from 'zod'

export const generateDescriptionSchema = z.object({
  title: z.string().min(3).max(255),
  features: z.array(z.string()).optional().default([]),
  category: z.string().optional(),
  brand: z.string().optional(),
  tone: z.enum(['professional', 'casual', 'luxury', 'friendly']).default('professional'),
})

export const smartSearchSchema = z.object({
  query: z.string().min(2).max(200),
})

export const chatSchema = z.object({
  message: z.string().min(1).max(1000),
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        content: z.string(),
      })
    )
    .optional()
    .default([]),
})

export const recommendSchema = z.object({
  product_id: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(20).default(6),
})

export const compareSchema = z.object({
  product_ids: z
    .array(z.string().uuid())
    .min(2, 'At least 2 products required')
    .max(4, 'Maximum 4 products'),
})
ENDOFFILE

echo "✅ ai.schema.js updated"

echo ""
echo "🎉 Backend done!"
echo ""
