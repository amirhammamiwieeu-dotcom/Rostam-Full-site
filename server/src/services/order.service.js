import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import { generateOrderNumber } from '../utils/helpers.js'
import { getCart, validateCart } from './cart.service.js'
import { validateCoupon, recordCouponUsage } from './coupon.service.js'

/**
 * Create a new order from user's cart
 */
export const createOrder = async (userId, data) => {
  const { shipping_address, billing_address, shipping_method, customer_note, coupon_code } = data

  // 1. Get and validate cart
  const { valid, issues, cart } = await validateCart(userId)
  if (!valid) {
    throw ApiError.badRequest('Cart validation failed', issues)
  }
  if (cart.items.length === 0) {
    throw ApiError.badRequest('Cart is empty')
  }

  // 2. Compute pricing
  const subtotal = cart.subtotal
  let discount = 0
  let couponId = null

  if (coupon_code) {
    const result = await validateCoupon(coupon_code, subtotal, userId)
    discount = result.discountAmount
    couponId = result.coupon.id
  }

  // 3. Shipping cost
  const shippingCost = getShippingCost(shipping_method, subtotal - discount)

  // 4. Tax (based on state)
  const taxRate = getTaxRate(shipping_address.state)
  const taxableAmount = subtotal - discount
  const tax = Math.round(taxableAmount * taxRate) / 100

  // 5. Total
  const total = Math.round((subtotal - discount + shippingCost + tax) * 100) / 100

  // 6. Generate order number
  const orderNumber = generateOrderNumber()

  // 7. Create order
  const { data: order, error } = await supabaseAdmin
    .from('orders')
    .insert({
      order_number: orderNumber,
      user_id: userId,
      status: 'pending',
      payment_status: 'pending',
      fulfillment_status: 'unfulfilled',
      customer_email: shipping_address.email,
      customer_name: shipping_address.full_name,
      customer_phone: shipping_address.phone,
      shipping_address,
      billing_address: billing_address || shipping_address,
      shipping_method,
      shipping_cost: shippingCost,
      subtotal,
      discount,
      coupon_code: coupon_code || null,
      tax,
      total,
      currency: 'USD',
      customer_note: customer_note || null,
    })
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)

  // 8. Create order items (snapshot of products)
  const orderItems = cart.items.map((item) => ({
    order_id: order.id,
    product_id: item.product.id,
    variant_id: item.variant_id || null,
    title: item.product.title,
    sku: item.product.sku || null,
    price: item.variant?.price || item.product.price,
    quantity: item.quantity,
    total: (item.variant?.price || item.product.price) * item.quantity,
    image: item.product.thumbnail,
    attributes: item.variant?.attributes || null,
  }))

  const { error: itemsError } = await supabaseAdmin
    .from('order_items')
    .insert(orderItems)

  if (itemsError) {
    // Rollback order
    await supabaseAdmin.from('orders').delete().eq('id', order.id)
    throw ApiError.badRequest(itemsError.message)
  }

  // 9. Record coupon usage
  if (couponId) {
    await recordCouponUsage(couponId, userId, order.id, discount)
  }

  // 10. Return full order
  return getOrderById(order.id, userId)
}

/**
 * Get single order
 */
export const getOrderById = async (orderId, userId = null) => {
  let query = supabaseAdmin
    .from('orders')
    .select(`
      *,
      items:order_items(
        id, title, sku, price, quantity, total, image, attributes,
        product_id, variant_id
      ),
      user:profiles(id, full_name, email)
    `)
    .eq('id', orderId)

  if (userId) query = query.eq('user_id', userId)

  const { data, error } = await query.maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Order not found')

  return data
}

/**
 * Get user's orders with pagination
 */
export const getUserOrders = async (userId, { page = 1, limit = 20 } = {}) => {
  const offset = (page - 1) * limit

  const { data, error, count } = await supabaseAdmin
    .from('orders')
    .select(
      `
      id, order_number, status, payment_status, fulfillment_status,
      total, currency, created_at, tracking_number,
      items:order_items(id, title, image, quantity)
    `,
      { count: 'exact' }
    )
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) throw ApiError.badRequest(error.message)

  return {
    orders: data || [],
    pagination: {
      page,
      limit,
      total: count || 0,
      pages: Math.ceil((count || 0) / limit),
    },
  }
}

/**
 * Cancel an order (only if pending/confirmed)
 */
export const cancelOrder = async (orderId, userId) => {
  const { data: order } = await supabaseAdmin
    .from('orders')
    .select('status, payment_status')
    .eq('id', orderId)
    .eq('user_id', userId)
    .maybeSingle()

  if (!order) throw ApiError.notFound('Order not found')

  if (!['pending', 'confirmed'].includes(order.status)) {
    throw ApiError.badRequest('Order cannot be cancelled')
  }

  if (order.payment_status === 'paid') {
    throw ApiError.badRequest('Paid orders require refund. Contact support.')
  }

  const { error } = await supabaseAdmin
    .from('orders')
    .update({
      status: 'cancelled',
      cancelled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', orderId)

  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}

/**
 * Update order status (admin)
 */
export const updateOrderStatus = async (orderId, data) => {
  const updates = {
    status: data.status,
    updated_at: new Date().toISOString(),
  }

  if (data.tracking_number) updates.tracking_number = data.tracking_number
  if (data.tracking_url) updates.tracking_url = data.tracking_url
  if (data.note) updates.admin_note = data.note

  if (data.status === 'shipped') updates.shipped_at = new Date().toISOString()
  if (data.status === 'delivered') updates.delivered_at = new Date().toISOString()
  if (data.status === 'cancelled') updates.cancelled_at = new Date().toISOString()

  const { data: order, error } = await supabaseAdmin
    .from('orders')
    .update(updates)
    .eq('id', orderId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return order
}

/**
 * Helper: shipping cost
 */
const getShippingCost = (method, amount) => {
  const rates = { standard: 5.99, express: 14.99, same_day: 24.99 }
  const base = rates[method] || rates.standard
  if (amount >= 50 && method === 'standard') return 0
  return base
}

/**
 * Helper: tax rate by state
 */
const getTaxRate = (state) => {
  const rates = { CA: 7.25, NY: 4.0, TX: 6.25, FL: 6.0, IL: 6.25 }
  return rates[state] || 5
}