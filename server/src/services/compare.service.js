import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Get user's compare list
 */
export const getCompare = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('compares')
    .select(`
      id, created_at,
      product:products(
        id, title, slug, price, old_price, discount,
        thumbnail, images, rating, num_reviews, is_prime,
        stock, features, specifications,
        brand:brands(id, name, slug)
      )
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) throw ApiError.badRequest(error.message)

  const items = (data || []).filter((i) => i.product && i.product.is_active)
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
    .maybeSingle()

  if (!product) throw ApiError.notFound('Product not found')

  const { error } = await supabaseAdmin
    .from('compares')
    .insert({ user_id: userId, product_id: productId })

  if (error) throw ApiError.badRequest(error.message)
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
  return { success: true }
}
