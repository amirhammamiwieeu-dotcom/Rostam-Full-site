import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Generate slug from title
 */
const generateSlug = (title) => {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
}

/**
 * Get products with filters, sorting, pagination
 */
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
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url)
    `,
      { count: 'exact' }
    )
    .eq('is_active', true)
    .eq('status', 'published')

  // Filters
  if (category) {
    // Look up category by slug first
    const { data: cat } = await supabaseAdmin
      .from('categories')
      .select('id')
      .eq('slug', category)
      .maybeSingle()
    if (cat) queryBuilder = queryBuilder.eq('category_id', cat.id)
  }

  if (brand) {
    const { data: b } = await supabaseAdmin
      .from('brands')
      .select('id')
      .eq('slug', brand)
      .maybeSingle()
    if (b) queryBuilder = queryBuilder.eq('brand_id', b.id)
  }

  if (q) {
    queryBuilder = queryBuilder.or(
      `title.ilike.%${q}%,description.ilike.%${q}%,sku.ilike.%${q}%`
    )
  }

  if (minPrice !== undefined) queryBuilder = queryBuilder.gte('price', minPrice)
  if (maxPrice !== undefined) queryBuilder = queryBuilder.lte('price', maxPrice)
  if (rating !== undefined) queryBuilder = queryBuilder.gte('rating', rating)
  if (prime === true) queryBuilder = queryBuilder.eq('is_prime', true)
  if (inStock === true) queryBuilder = queryBuilder.gt('stock', 0)

  // Sorting
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

  // Pagination
  queryBuilder = queryBuilder.range(offset, offset + limit - 1)

  const { data, error, count } = await queryBuilder

  if (error) throw ApiError.badRequest(error.message)

  return {
    products: data || [],
    pagination: {
      page,
      limit,
      total: count || 0,
      pages: Math.ceil((count || 0) / limit),
      hasMore: offset + limit < (count || 0),
    },
  }
}

/**
 * Get single product by ID
 */
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

/**
 * Get single product by slug
 */
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

/**
 * Get related products (same category)
 */
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
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime'
    )
    .eq('category_id', product.category_id)
    .neq('id', productId)
    .eq('is_active', true)
    .limit(limit)

  return data || []
}

/**
 * Get featured products
 */
export const getFeaturedProducts = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime'
    )
    .eq('is_active', true)
    .eq('is_featured', true)
    .order('rating', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

/**
 * Get new arrivals
 */
export const getNewArrivals = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime'
    )
    .eq('is_active', true)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

/**
 * Get best sellers (most sold)
 */
export const getBestSellers = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, sold_count, is_prime'
    )
    .eq('is_active', true)
    .order('sold_count', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

/**
 * Search products (for live search)
 */
export const searchProducts = async (q, limit = 10) => {
  if (!q || q.trim().length < 2) return []

  const { data, error } = await supabaseAdmin
    .from('products')
    .select('id, title, slug, price, thumbnail, rating')
    .eq('is_active', true)
    .or(`title.ilike.%${q}%,brand_id.not.is.null`)
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

/**
 * Create new product (admin)
 */
export const createProduct = async (data) => {
  if (!data.slug) {
    data.slug = generateSlug(data.title) + '-' + Date.now().toString(36)
  }

  // Auto-calculate discount
  if (data.old_price && data.old_price > data.price) {
    data.discount = Math.round((1 - data.price / data.old_price) * 100)
  }

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .insert(data)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return product
}

/**
 * Update product (admin)
 */
export const updateProduct = async (id, data) => {
  if (data.old_price && data.price && data.old_price > data.price) {
    data.discount = Math.round((1 - data.price / data.old_price) * 100)
  }

  data.updated_at = new Date().toISOString()

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .update(data)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!product) throw ApiError.notFound('Product not found')
  return product
}

/**
 * Delete product (soft delete - admin)
 */
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

/**
 * Increment product views
 */
export const incrementProductViews = async (id) => {
  await supabaseAdmin.rpc('increment_product_views', { product_id: id }).catch(() => {
    // Fallback if RPC not defined
    supabaseAdmin
      .from('products')
      .select('views_count')
      .eq('id', id)
      .single()
      .then(({ data }) => {
        if (data) {
          supabaseAdmin
            .from('products')
            .update({ views_count: (data.views_count || 0) + 1 })
            .eq('id', id)
            .then()
        }
      })
  })
    }
