import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Get user's compare list
 */
export const getCompare = async (userId) => {
  // اول لیست product_idها رو بگیر
  const { data: compareRows, error: compareError } = await supabaseAdmin
    .from('compares')
    .select('id, product_id, created_at')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (compareError) throw ApiError.badRequest(compareError.message)

  if (!compareRows || compareRows.length === 0) {
    return { items: [], count: 0 }
  }

  // بعد محصولات رو جدا بگیر
  const productIds = compareRows.map((r) => r.product_id)

  const { data: products, error: productsError } = await supabaseAdmin
    .from('products')
    .select(`
      id, title, slug, price, old_price, discount,
      thumbnail, images, rating, num_reviews, is_prime,
      stock, features, specifications,
      brand:brands(id, name, slug)
    `)
    .in('id', productIds)
    .eq('is_active', true)

  if (productsError) throw ApiError.badRequest(productsError.message)

  // ترکیب کن
  const productMap = {}
  ;(products || []).forEach((p) => {
    productMap[p.id] = p
  })

  const items = compareRows
    .filter((r) => productMap[r.product_id])
    .map((r) => ({
      id: r.id,
      product_id: r.product_id,
      created_at: r.created_at,
      product: productMap[r.product_id],
    }))

  return { items, count: items.length }
}

/**
 * Add product to compare list (max 4)
 */
export const addToCompare = async (userId, productId) => {
  // Check count
  const { count } = await supabaseAdmin
    .from('compares')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)

  if (count >= 4) {
    throw ApiError.badRequest('You can compare up to 4 products')
  }

  // Check if already added
  const { data: existing } = await supabaseAdmin
    .from('compares')
    .select('id')
    .eq('user_id', userId)
    .eq('product_id', productId)
    .maybeSingle()

  if (existing) {
    throw ApiError.badRequest('Product already in compare list')
  }

  // Check product exists
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('id')
    .eq('id', productId)
    .eq('is_active', true)
    .maybeSingle()

  if (!product) throw ApiError.notFound('Product not found')

  // Insert
  const { error } = await supabaseAdmin
    .from('compares')
    .insert({ user_id: userId, product_id: productId })

  if (error) throw ApiError.badRequest(error.message)

  // Return updated list
  return getCompare(userId)
}

/**
 * Remove product from compare
 */
export const removeFromCompare = async (userId, productId) => {
  const { error } = await supabaseAdmin
    .from('compares')
    .delete()
    .eq('user_id', userId)
    .eq('product_id', productId)

  if (error) throw ApiError.badRequest(error.message)
  return getCompare(userId)
}

/**
 * Clear compare list
 */
export const clearCompare = async (userId) => {
  const { error } = await supabaseAdmin
    .from('compares')
    .delete()
    .eq('user_id', userId)

  if (error) throw ApiError.badRequest(error.message)
  return { items: [], count: 0 }
}
