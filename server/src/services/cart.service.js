import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Get user's cart with populated products
 */
export const getCart = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('cart_items')
    .select(`
      id, quantity, variant_id, price_at_add, created_at,
      product:products(
        id, title, slug, price, old_price, discount, stock,
        thumbnail, images, is_active, is_prime,
        brand:brands(id, name, slug)
      ),
      variant:product_variants(id, title, price, stock, image_url)
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) throw ApiError.badRequest(error.message)

  const items = (data || []).filter((i) => i.product && i.product.is_active)

  // Compute totals
  const subtotal = items.reduce((sum, item) => {
    const price = item.variant?.price || item.product.price
    return sum + price * item.quantity
  }, 0)

  const count = items.reduce((sum, item) => sum + item.quantity, 0)

  return {
    items,
    subtotal,
    count,
  }
}

/**
 * Add product to cart (or increment if exists)
 */
export const addToCart = async (userId, { product_id, variant_id, quantity }) => {
  // Check product exists and is active
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('id, stock, is_active')
    .eq('id', product_id)
    .maybeSingle()

  if (!product || !product.is_active) {
    throw ApiError.notFound('Product not found')
  }

  if (product.stock < quantity) {
    throw ApiError.badRequest('Insufficient stock')
  }

  // Check if item already in cart
  const query = supabaseAdmin
    .from('cart_items')
    .select('id, quantity')
    .eq('user_id', userId)
    .eq('product_id', product_id)

  if (variant_id) query.eq('variant_id', variant_id)
  else query.is('variant_id', null)

  const { data: existing } = await query.maybeSingle()

  if (existing) {
    const newQty = existing.quantity + quantity
    if (newQty > product.stock) {
      throw ApiError.badRequest('Insufficient stock')
    }

    const { error } = await supabaseAdmin
      .from('cart_items')
      .update({ quantity: newQty, updated_at: new Date().toISOString() })
      .eq('id', existing.id)

    if (error) throw ApiError.badRequest(error.message)
  } else {
    const { error } = await supabaseAdmin.from('cart_items').insert({
      user_id: userId,
      product_id,
      variant_id: variant_id || null,
      quantity,
    })

    if (error) throw ApiError.badRequest(error.message)
  }

  return getCart(userId)
}

/**
 * Update item quantity
 */
export const updateCartItem = async (userId, itemId, quantity) => {
  // Check item belongs to user
  const { data: item } = await supabaseAdmin
    .from('cart_items')
    .select('id, product:products(stock)')
    .eq('id', itemId)
    .eq('user_id', userId)
    .maybeSingle()

  if (!item) throw ApiError.notFound('Cart item not found')

  if (quantity > item.product.stock) {
    throw ApiError.badRequest('Insufficient stock')
  }

  const { error } = await supabaseAdmin
    .from('cart_items')
    .update({ quantity, updated_at: new Date().toISOString() })
    .eq('id', itemId)

  if (error) throw ApiError.badRequest(error.message)
  return getCart(userId)
}

/**
 * Remove item from cart
 */
export const removeCartItem = async (userId, itemId) => {
  const { error } = await supabaseAdmin
    .from('cart_items')
    .delete()
    .eq('id', itemId)
    .eq('user_id', userId)

  if (error) throw ApiError.badRequest(error.message)
  return getCart(userId)
}

/**
 * Clear entire cart
 */
export const clearCart = async (userId) => {
  const { error } = await supabaseAdmin
    .from('cart_items')
    .delete()
    .eq('user_id', userId)

  if (error) throw ApiError.badRequest(error.message)
  return { items: [], subtotal: 0, count: 0 }
}

/**
 * Validate stock for all items (before checkout)
 */
export const validateCart = async (userId) => {
  const cart = await getCart(userId)
  const issues = []

  for (const item of cart.items) {
    if (!item.product.is_active) {
      issues.push({ item_id: item.id, issue: 'Product is no longer available' })
    } else if (item.product.stock < item.quantity) {
      issues.push({
        item_id: item.id,
        issue: `Only ${item.product.stock} in stock`,
      })
    }
  }

  return { valid: issues.length === 0, issues, cart }
}
