import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Dashboard stats
 */
export const getDashboardStats = async () => {
  const [
    { count: totalUsers },
    { count: totalOrders },
    { count: totalProducts },
    { data: revenueData },
    { data: recentOrders },
  ] = await Promise.all([
    supabaseAdmin.from('profiles').select('*', { count: 'exact', head: true }),
    supabaseAdmin.from('orders').select('*', { count: 'exact', head: true }),
    supabaseAdmin.from('products').select('*', { count: 'exact', head: true }).eq('is_active', true),
    supabaseAdmin.from('orders').select('total').eq('payment_status', 'paid'),
    supabaseAdmin
      .from('orders')
      .select('id, order_number, total, status, customer_name, created_at')
      .order('created_at', { ascending: false })
      .limit(5),
  ])

  const totalRevenue = (revenueData || []).reduce((s, o) => s + Number(o.total || 0), 0)

  return {
    totalUsers: totalUsers || 0,
    totalOrders: totalOrders || 0,
    totalProducts: totalProducts || 0,
    totalRevenue: Math.round(totalRevenue * 100) / 100,
    recentOrders: recentOrders || [],
  }
}

/**
 * List all users (admin)
 */
export const getAllUsers = async ({ page = 1, limit = 20, q } = {}) => {
  const offset = (page - 1) * limit
  let query = supabaseAdmin
    .from('profiles')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (q) query = query.or(`email.ilike.%${q}%,full_name.ilike.%${q}%`)

  const { data, error, count } = await query
  if (error) throw ApiError.badRequest(error.message)

  return {
    users: data || [],
    pagination: { page, limit, total: count || 0, pages: Math.ceil((count || 0) / limit) },
  }
}

/**
 * Update user role / status (admin)
 */
export const updateUser = async (userId, data) => {
  const allowed = ['role', 'is_active', 'is_verified']
  const updates = {}
  for (const key of allowed) {
    if (data[key] !== undefined) updates[key] = data[key]
  }
  updates.updated_at = new Date().toISOString()

  const { data: user, error } = await supabaseAdmin
    .from('profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return user
}

/**
 * List all orders (admin)
 */
export const getAllOrders = async ({ page = 1, limit = 20, status, q } = {}) => {
  const offset = (page - 1) * limit
  let query = supabaseAdmin
    .from('orders')
    .select('*, items:order_items(id, title, image, quantity)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (status) query = query.eq('status', status)
  if (q) query = query.or(`order_number.ilike.%${q}%,customer_email.ilike.%${q}%`)

  const { data, error, count } = await query
  if (error) throw ApiError.badRequest(error.message)

  return {
    orders: data || [],
    pagination: { page, limit, total: count || 0, pages: Math.ceil((count || 0) / limit) },
  }
}

/**
 * List all comments (admin)
 */
export const getAllComments = async ({ page = 1, limit = 20, approved } = {}) => {
  const offset = (page - 1) * limit
  let query = supabaseAdmin
    .from('comments')
    .select(
      `
      *,
      user:profiles(id, full_name, email),
      product:products(id, title, slug, thumbnail)
    `,
      { count: 'exact' }
    )
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (approved !== undefined) query = query.eq('is_approved', approved)

  const { data, error, count } = await query
  if (error) throw ApiError.badRequest(error.message)

  return {
    comments: data || [],
    pagination: { page, limit, total: count || 0, pages: Math.ceil((count || 0) / limit) },
  }
}

/**
 * Approve/unapprove comment (admin)
 */
export const setCommentApproval = async (commentId, isApproved) => {
  const { data, error } = await supabaseAdmin
    .from('comments')
    .update({ is_approved: isApproved })
    .eq('id', commentId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return data
}

/**
 * Sales report
 */
export const getSalesReport = async ({ from, to } = {}) => {
  let query = supabaseAdmin
    .from('orders')
    .select('total, created_at, status, payment_status')
    .eq('payment_status', 'paid')

  if (from) query = query.gte('created_at', from)
  if (to) query = query.lte('created_at', to)

  const { data, error } = await query
  if (error) throw ApiError.badRequest(error.message)

  const orders = data || []
  const total = orders.reduce((s, o) => s + Number(o.total), 0)

  // Group by day
  const byDay = {}
  orders.forEach((o) => {
    const day = o.created_at.slice(0, 10)
    if (!byDay[day]) byDay[day] = { count: 0, revenue: 0 }
    byDay[day].count++
    byDay[day].revenue += Number(o.total)
  })

  return {
    totalRevenue: Math.round(total * 100) / 100,
    totalOrders: orders.length,
    byDay,
  }
}

/**
 * Low stock products
 */
export const getLowStockProducts = async (threshold = 5) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select('id, title, stock, low_stock_threshold, thumbnail')
    .eq('is_active', true)
    .lt('stock', threshold)
    .order('stock', { ascending: true })
    .limit(50)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}