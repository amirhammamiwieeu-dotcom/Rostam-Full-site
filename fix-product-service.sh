#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🔧 Replacing product.service.js with brand_name support..."
echo ""

cp src/services/product.service.js src/services/product.service.js.backup-$(date +%s) 2>/dev/null || true

cat > src/services/product.service.js << 'ENDOFFILE'
import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

// ============================================================
// Helpers
// ============================================================
const generateSlug = (str) => {
  return String(str)
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
}

/**
 * Find or create a brand by name → return its UUID
 */
const findOrCreateBrand = async (brandName) => {
  if (!brandName || !String(brandName).trim()) return null

  const name = String(brandName).trim()
  const slug = generateSlug(name)

  // 1. Check by slug
  const { data: bySlug } = await supabaseAdmin
    .from('brands')
    .select('id')
    .eq('slug', slug)
    .maybeSingle()

  if (bySlug?.id) return bySlug.id

  // 2. Check by name (case-insensitive)
  const { data: byName } = await supabaseAdmin
    .from('brands')
    .select('id')
    .ilike('name', name)
    .maybeSingle()

  if (byName?.id) return byName.id

  // 3. Create new brand
  const { data: created, error } = await supabaseAdmin
    .from('brands')
    .insert({ name, slug, is_active: true })
    .select('id')
    .single()

  if (error) {
    console.error('❌ Failed to create brand:', error.message)
    return null
  }

  console.log(`✨ Created brand: ${name} (${created.id})`)
  return created.id
}

/**
 * Normalize incoming product payload:
 *  - convert brand_name → brand_id (find or create)
 *  - auto-calculate discount
 *  - generate slug if missing
 */
const normalizeProductPayload = async (data) => {
  const out = { ...data }

  // brand_name → brand_id
  if ('brand_name' in out) {
    if (out.brand_name && String(out.brand_name).trim()) {
      out.brand_id = await findOrCreateBrand(out.brand_name)
    } else {
      out.brand_id = null
    }
    delete out.brand_name
  }

  // slug
  if (!out.slug && out.title) {
    out.slug = generateSlug(out.title) + '-' + Date.now().toString(36)
  }

  // discount
  if (out.old_price && out.price && Number(out.old_price) > Number(out.price)) {
    out.discount = Math.round(
      (1 - Number(out.price) / Number(out.old_price)) * 100
    )
  }

  // features: ensure array of strings
  if (out.features && !Array.isArray(out.features)) {
    out.features = []
  }

  return out
}

// ============================================================
// Get products (with filters, sort, pagination)
// ============================================================
export const getProducts = async (query) => {
  const {
    page = 1,
    limit = 20,
    category,
    brand,
    q,
    minPrice,
    maxPrice,
    rating,
    prime,
    inStock,
    sort = 'featured',
  } = query

  const offset = (page - 1) * limit

  let queryBuilder = supabaseAdmin
    .from('products')
    .select(
      `
      id, title, slug, price, old_price, discount,
      thumbnail, images, rating, num_reviews, sold_count,
      stock, is_prime, is_featured, is_new, free_shipping,
      category_id, brand_id,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url)
    `,
      { count: 'exact' }
    )
    .eq('is_active', true)
    .eq('status', 'published')

  // Filter: category
  if (category) {
    const { data: cat } = await supabaseAdmin
      .from('categories')
      .select('id')
      .eq('slug', category)
      .maybeSingle()
    if (cat) queryBuilder = queryBuilder.eq('category_id', cat.id)
  }

  // Filter: brand
  if (brand) {
    const { data: b } = await supabaseAdmin
      .from('brands')
      .select('id')
      .eq('slug', brand)
      .maybeSingle()
    if (b) queryBuilder = queryBuilder.eq('brand_id', b.id)
  }

  // Filter: search
  if (q) {
    queryBuilder = queryBuilder.or(
      `title.ilike.%${q}%,description.ilike.%${q}%,sku.ilike.%${q}%`
    )
  }

  // Filter: price
  if (minPrice !== undefined && minPrice !== '') {
    queryBuilder = queryBuilder.gte('price', Number(minPrice))
  }
  if (maxPrice !== undefined && maxPrice !== '') {
    queryBuilder = queryBuilder.lte('price', Number(maxPrice))
  }

  // Filter: rating
  if (rating !== undefined && rating !== '' && Number(rating) > 0) {
    queryBuilder = queryBuilder.gte('rating', Number(rating))
  }

  // Filter: prime
  if (prime === true || prime === 'true') {
    queryBuilder = queryBuilder.eq('is_prime', true)
  }

  // Filter: in stock
  if (inStock === true || inStock === 'true') {
    queryBuilder = queryBuilder.gt('stock', 0)
  }

  // Sort
  switch (sort) {
    case 'price-asc':
      queryBuilder = queryBuilder.order('price', { ascending: true })
      break
    case 'price-desc':
      queryBuilder = queryBuilder.order('price', { ascending: false })
      break
    case 'rating':
      queryBuilder = queryBuilder.order('rating', { ascending: false })
      break
    case 'newest':
      queryBuilder = queryBuilder.order('created_at', { ascending: false })
      break
    case 'discount':
      queryBuilder = queryBuilder.order('discount', { ascending: false })
      break
    case 'popular':
      queryBuilder = queryBuilder.order('sold_count', { ascending: false })
      break
    case 'featured':
    default:
      queryBuilder = queryBuilder
        .order('is_featured', { ascending: false })
        .order('rating', { ascending: false })
  }

  queryBuilder = queryBuilder.range(offset, offset + limit - 1)

  const { data, error, count } = await queryBuilder

  if (error) throw ApiError.badRequest(error.message)

  return {
    products: data || [],
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: count || 0,
      pages: Math.ceil((count || 0) / Number(limit)),
      hasMore: offset + Number(limit) < (count || 0),
    },
  }
}

// ============================================================
// Get single product by ID
// ============================================================
export const getProductById = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      `
      *,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url),
      seller:profiles(id, full_name, avatar_url)
    `
    )
    .eq('id', id)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return data
}

// ============================================================
// Get single product by slug
// ============================================================
export const getProductBySlug = async (slug) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      `
      *,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url),
      seller:profiles(id, full_name, avatar_url)
    `
    )
    .eq('slug', slug)
    .eq('is_active', true)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return data
}

// ============================================================
// Related products (same category)
// ============================================================
export const getRelatedProducts = async (productId, limit = 8) => {
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('category_id')
    .eq('id', productId)
    .maybeSingle()

  if (!product?.category_id) return []

  const { data } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('category_id', product.category_id)
    .neq('id', productId)
    .eq('is_active', true)
    .limit(limit)

  return data || []
}

// ============================================================
// Featured products
// ============================================================
export const getFeaturedProducts = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('is_active', true)
    .eq('is_featured', true)
    .order('rating', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// New arrivals
// ============================================================
export const getNewArrivals = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('is_active', true)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Best sellers
// ============================================================
export const getBestSellers = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, sold_count, is_prime, stock'
    )
    .eq('is_active', true)
    .order('sold_count', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Search (live search)
// ============================================================
export const searchProducts = async (q, limit = 10) => {
  if (!q || q.trim().length < 2) return []

  const { data, error } = await supabaseAdmin
    .from('products')
    .select('id, title, slug, price, thumbnail, rating, stock')
    .eq('is_active', true)
    .ilike('title', `%${q}%`)
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Create product (admin) — supports brand_name
// ============================================================
export const createProduct = async (data) => {
  const payload = await normalizeProductPayload(data)

  console.log('📦 Creating product:', {
    title: payload.title,
    brand_id: payload.brand_id,
    category_id: payload.category_id,
    price: payload.price,
    stock: payload.stock,
  })

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .insert(payload)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return product
}

// ============================================================
// Update product (admin) — supports brand_name
// ============================================================
export const updateProduct = async (id, data) => {
  const payload = await normalizeProductPayload(data)
  payload.updated_at = new Date().toISOString()

  console.log('📦 Updating product:', id, {
    brand_id: payload.brand_id,
    category_id: payload.category_id,
  })

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .update(payload)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!product) throw ApiError.notFound('Product not found')
  return product
}

// ============================================================
// Delete product (soft delete — admin)
// ============================================================
export const deleteProduct = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .update({ is_active: false, status: 'archived' })
    .eq('id', id)
    .select('id')
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return { success: true }
}

// ============================================================
// Increment product views
// ============================================================
export const incrementProductViews = async (id) => {
  try {
    const { data } = await supabaseAdmin
      .from('products')
      .select('views_count')
      .eq('id', id)
      .single()

    if (data) {
      await supabaseAdmin
        .from('products')
        .update({ views_count: (data.views_count || 0) + 1 })
        .eq('id', id)
    }
  } catch (err) {
    // silent fail
  }
}
ENDOFFILE

echo "✅ product.service.js replaced!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Backend terminal"
echo "   2. cd ~/Rostam-Full-site/server"
echo "   3. npm run dev"
echo ""
