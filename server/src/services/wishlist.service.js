import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Get user's wishlist
 */
export const getWishlist = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('wishlists')
    .select(`
      id, created_at,
      product:products(
        id, title, slug, price, old_price, discount, stock,
        thumbnail, images, rating, num_reviews, is_active, is_prime,
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
 * Toggle product in wishlist
 */
export const toggleWishlist = async (userId, productId) => {
  // Check product exists
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('id')
    .eq('id', productId)
    .maybeSingle()

  if (!product) throw ApiError.notFound('Product not found')

  // Check if already in wishlist
  const { data: existing } = await supabaseAdmin
    .from('wishlists')
    .select('id')
    .eq('user_id', userId)
    .eq('product_id', productId)
    .maybeSingle()

  if (existing) {
    await supabaseAdmin.from('wishlists').delete().eq('id', existing.id)
    return { added: false, message: 'Removed from wishlist' }
  }

  const { error } = await supabaseAdmin
    .from('wishlists')
    .insert({ user_id: userId, product_id: productId })

  if (error) throw ApiError.badRequest(error.message)
  return { added: true, message: 'Added to wishlist' }
}

/**
 * Check if product is in user's wishlist
 */
export const isInWishlist = async (userId, productId) => {
  const { data } = await supabaseAdmin
    .from('wishlists')
    .select('id')
    .eq('user_id', userId)
    .eq('product_id', productId)
    .maybeSingle()

  return !!data
}

/**
 * Clear entire wishlist
 */
export const clearWishlist = async (userId) => {
  const { error } = await supabaseAdmin
    .from('wishlists')
    .delete()
    .eq('user_id', userId)

  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}
