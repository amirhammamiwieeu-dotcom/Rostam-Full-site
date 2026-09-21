import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import { getClientIp, getUserAgent } from '../utils/helpers.js'

/**
 * Track a product view
 */
export const trackProductView = async (req, { product_id, session_id, referrer }) => {
  const { error } = await supabaseAdmin.from('product_views').insert({
    product_id,
    user_id: req.user?.id || null,
    session_id: session_id || null,
    ip_address: getClientIp(req),
    user_agent: getUserAgent(req),
    referrer: referrer || null,
  })

  if (error) {
    // silent fail (analytics should never break the app)
    console.error('Track view failed:', error.message)
  }

  return { success: true }
}

/**
 * Track a search query
 */
export const trackSearch = async (req, { query, results_count, filters, session_id }) => {
  const { error } = await supabaseAdmin.from('search_queries').insert({
    query,
    user_id: req.user?.id || null,
    session_id: session_id || null,
    results_count,
    filters: filters || {},
  })

  if (error) console.error('Track search failed:', error.message)
  return { success: true }
}

/**
 * Recently viewed products for user
 */
export const getRecentlyViewed = async (userId, limit = 8) => {
  const { data, error } = await supabaseAdmin
    .from('product_views')
    .select(
      `
      viewed_at,
      product:products(
        id, title, slug, price, old_price, discount, thumbnail, rating
      )
    `
    )
    .eq('user_id', userId)
    .order('viewed_at', { ascending: false })
    .limit(50)

  if (error) throw ApiError.badRequest(error.message)

  // Dedupe by product id, keep most recent
  const seen = new Set()
  const items = []
  for (const row of data || []) {
    if (!row.product || seen.has(row.product.id)) continue
    seen.add(row.product.id)
    items.push(row.product)
    if (items.length >= limit) break
  }

  return items
}

/**
 * Trending searches (last 7 days)
 */
export const getTrendingSearches = async (limit = 10) => {
  const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()

  const { data, error } = await supabaseAdmin
    .from('search_queries')
    .select('query')
    .gte('searched_at', since)

  if (error) throw ApiError.badRequest(error.message)

  const counts = {}
  for (const row of data || []) {
    const q = row.query.toLowerCase().trim()
    if (q.length < 2) continue
    counts[q] = (counts[q] || 0) + 1
  }

  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, limit)
    .map(([query, count]) => ({ query, count }))
}

/**
 * Top viewed products (last N days)
 */
export const getTopViewed = async (days = 7, limit = 10) => {
  const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString()

  const { data, error } = await supabaseAdmin
    .from('product_views')
    .select(
      `
      product_id,
      product:products(id, title, slug, thumbnail, price)
    `
    )
    .gte('viewed_at', since)

  if (error) throw ApiError.badRequest(error.message)

  const counts = {}
  const products = {}
  for (const row of data || []) {
    if (!row.product_id) continue
    counts[row.product_id] = (counts[row.product_id] || 0) + 1
    products[row.product_id] = row.product
  }

  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, limit)
    .map(([id, views]) => ({ product: products[id], views }))
    .filter((x) => x.product)
}