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

  // Strip markdown fences if present
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
// Recommendations (hybrid: AI + DB)
// ============================================================
export const recommendProducts = async ({ product_id, limit = 6 }) => {
  // If product_id given, find similar via AI signal + same category
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

  // Otherwise: top rated + featured
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
// Bulk translate (optional utility)
// ============================================================
export const translateText = async ({ text, targetLanguage }) => {
  const prompt = `Translate the following text to ${targetLanguage}. Return ONLY the translation, no extra text.

Text:
${text}`

  const result = await geminiModel.generateContent(prompt)
  return { translation: result.response.text().trim() }
}