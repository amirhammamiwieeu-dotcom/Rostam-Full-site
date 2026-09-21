import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Validate a coupon code against a cart
 */
export const validateCoupon = async (code, subtotal, userId = null) => {
  const { data: coupon, error } = await supabaseAdmin
    .from('coupons')
    .select('*')
    .eq('code', code.toUpperCase())
    .eq('is_active', true)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!coupon) throw ApiError.notFound('Invalid coupon code')

  // Check expiration
  if (coupon.expires_at && new Date(coupon.expires_at) < new Date()) {
    throw ApiError.badRequest('Coupon has expired')
  }

  // Check start date
  if (coupon.starts_at && new Date(coupon.starts_at) > new Date()) {
    throw ApiError.badRequest('Coupon is not active yet')
  }

  // Check min order
  if (subtotal < coupon.min_order) {
    throw ApiError.badRequest(
      `Minimum order of $${coupon.min_order} required for this coupon`
    )
  }

  // Check max uses
  if (coupon.max_uses && coupon.used_count >= coupon.max_uses) {
    throw ApiError.badRequest('Coupon has reached maximum uses')
  }

  // Check per-user limit
  if (userId && coupon.max_uses_per_user) {
    const { count } = await supabaseAdmin
      .from('coupon_usage')
      .select('*', { count: 'exact', head: true })
      .eq('coupon_id', coupon.id)
      .eq('user_id', userId)

    if (count >= coupon.max_uses_per_user) {
      throw ApiError.badRequest('You have already used this coupon')
    }
  }

  // Compute discount
  let discountAmount = 0
  if (coupon.discount_type === 'percent') {
    discountAmount = (subtotal * coupon.discount_value) / 100
    if (coupon.max_discount && discountAmount > coupon.max_discount) {
      discountAmount = coupon.max_discount
    }
  } else if (coupon.discount_type === 'fixed') {
    discountAmount = Math.min(coupon.discount_value, subtotal)
  }
  // free_shipping — no discount on subtotal, handled at checkout

  return {
    coupon: {
      id: coupon.id,
      code: coupon.code,
      discount_type: coupon.discount_type,
      discount_value: coupon.discount_value,
    },
    discountAmount: Math.round(discountAmount * 100) / 100,
  }
}

/**
 * Record coupon usage (called at order creation)
 */
export const recordCouponUsage = async (couponId, userId, orderId, discountAmount) => {
  // Insert usage record
  await supabaseAdmin.from('coupon_usage').insert({
    coupon_id: couponId,
    user_id: userId,
    order_id: orderId,
    discount_amount: discountAmount,
  })

  // Increment usage count
  const { data: coupon } = await supabaseAdmin
    .from('coupons')
    .select('used_count')
    .eq('id', couponId)
    .single()

  if (coupon) {
    await supabaseAdmin
      .from('coupons')
      .update({ used_count: (coupon.used_count || 0) + 1 })
      .eq('id', couponId)
  }
}

/**
 * List all active public coupons
 */
export const getPublicCoupons = async () => {
  const { data, error } = await supabaseAdmin
    .from('coupons')
    .select('code, description, discount_type, discount_value, min_order, expires_at')
    .eq('is_active', true)
    .eq('is_public', true)
    .order('created_at', { ascending: false })

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Admin
// ============================================================
export const getAllCoupons = async () => {
  const { data, error } = await supabaseAdmin
    .from('coupons')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

export const createCoupon = async (data) => {
  data.code = data.code.toUpperCase()
  const { data: coupon, error } = await supabaseAdmin
    .from('coupons')
    .insert(data)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return coupon
}

export const updateCoupon = async (id, data) => {
  if (data.code) data.code = data.code.toUpperCase()
  data.updated_at = new Date().toISOString()

  const { data: coupon, error } = await supabaseAdmin
    .from('coupons')
    .update(data)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return coupon
}

export const deleteCoupon = async (id) => {
  const { error } = await supabaseAdmin.from('coupons').delete().eq('id', id)
  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}
