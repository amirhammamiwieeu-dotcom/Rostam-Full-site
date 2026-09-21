import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Get comments for a product
 */
export const getProductComments = async (productId, { page = 1, limit = 10 } = {}) => {
  const offset = (page - 1) * limit

  const { data, error, count } = await supabaseAdmin
    .from('comments')
    .select(
      `
      id, rating, title, text, helpful_count, not_helpful_count,
      is_verified_purchase, admin_reply, created_at,
      user:profiles(id, full_name, avatar_url),
      images:review_images(id, image_url)
    `,
      { count: 'exact' }
    )
    .eq('product_id', productId)
    .eq('is_approved', true)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) throw ApiError.badRequest(error.message)
  return {
    comments: data || [],
    pagination: {
      page,
      limit,
      total: count || 0,
      pages: Math.ceil((count || 0) / limit),
    },
  }
}

/**
 * Get rating summary for a product
 */
export const getRatingSummary = async (productId) => {
  const { data, error } = await supabaseAdmin
    .from('comments')
    .select('rating')
    .eq('product_id', productId)
    .eq('is_approved', true)

  if (error) throw ApiError.badRequest(error.message)

  const ratings = data || []
  const total = ratings.length
  if (total === 0) return { average: 0, total: 0, distribution: {} }

  const sum = ratings.reduce((s, r) => s + r.rating, 0)
  const average = Math.round((sum / total) * 10) / 10

  const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
  ratings.forEach((r) => distribution[r.rating]++)

  return { average, total, distribution }
}

/**
 * Add a comment (must have purchased the product)
 */
export const addComment = async (userId, { product_id, rating, title, text, images }) => {
  // Check if user has purchased this product
  const { data: purchased } = await supabaseAdmin
    .from('order_items')
    .select(`
      id,
      order:orders!inner(user_id, payment_status)
    `)
    .eq('product_id', product_id)
    .eq('order.user_id', userId)
    .eq('order.payment_status', 'paid')
    .limit(1)
    .maybeSingle()

  const isVerifiedPurchase = !!purchased

  // Insert comment
  const { data: comment, error } = await supabaseAdmin
    .from('comments')
    .insert({
      product_id,
      user_id: userId,
      rating,
      title: title || null,
      text,
      is_verified_purchase: isVerifiedPurchase,
    })
    .select()
    .single()

  if (error) {
    if (error.code === '23505') {
      throw ApiError.conflict('You have already reviewed this product')
    }
    throw ApiError.badRequest(error.message)
  }

  // Insert images
  if (images?.length) {
    await supabaseAdmin.from('review_images').insert(
      images.map((url, i) => ({
        comment_id: comment.id,
        image_url: url,
        sort_order: i,
      }))
    )
  }

  // Recompute product rating
  await recomputeProductRating(product_id)

  return comment
}

/**
 * Update comment
 */
export const updateComment = async (commentId, userId, data) => {
  const { data: comment } = await supabaseAdmin
    .from('comments')
    .select('id, user_id, product_id')
    .eq('id', commentId)
    .maybeSingle()

  if (!comment) throw ApiError.notFound('Comment not found')
  if (comment.user_id !== userId) throw ApiError.forbidden('Not your comment')

  const { data: updated, error } = await supabaseAdmin
    .from('comments')
    .update({
      ...data,
      updated_at: new Date().toISOString(),
    })
    .eq('id', commentId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  await recomputeProductRating(comment.product_id)
  return updated
}

/**
 * Delete comment
 */
export const deleteComment = async (commentId, userId, isAdmin = false) => {
  const { data: comment } = await supabaseAdmin
    .from('comments')
    .select('id, user_id, product_id')
    .eq('id', commentId)
    .maybeSingle()

  if (!comment) throw ApiError.notFound('Comment not found')
  if (!isAdmin && comment.user_id !== userId) throw ApiError.forbidden('Not your comment')

  await supabaseAdmin.from('comments').delete().eq('id', commentId)
  await recomputeProductRating(comment.product_id)
  return { success: true }
}

/**
 * Vote on a comment (helpful / not_helpful)
 */
export const voteComment = async (commentId, userId, vote) => {
  const { data: existing } = await supabaseAdmin
    .from('review_votes')
    .select('id, vote')
    .eq('comment_id', commentId)
    .eq('user_id', userId)
    .maybeSingle()

  if (existing) {
    if (existing.vote === vote) {
      // Same vote — remove it
      await supabaseAdmin.from('review_votes').delete().eq('id', existing.id)
    } else {
      // Different vote — update
      await supabaseAdmin
        .from('review_votes')
        .update({ vote })
        .eq('id', existing.id)
    }
  } else {
    await supabaseAdmin
      .from('review_votes')
      .insert({ comment_id: commentId, user_id: userId, vote })
  }

  // Recompute counts
  await recomputeVoteCounts(commentId)
  return { success: true }
}

/**
 * Admin: reply to a comment
 */
export const adminReply = async (commentId, reply) => {
  const { data, error } = await supabaseAdmin
    .from('comments')
    .update({
      admin_reply: reply,
      admin_reply_at: new Date().toISOString(),
    })
    .eq('id', commentId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return data
}

/**
 * Get user's own comments
 */
export const getUserComments = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('comments')
    .select(
      `
      id, rating, title, text, created_at,
      product:products(id, title, slug, thumbnail)
    `
    )
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

/**
 * Recompute product rating + review count
 */
const recomputeProductRating = async (productId) => {
  const { data } = await supabaseAdmin
    .from('comments')
    .select('rating')
    .eq('product_id', productId)
    .eq('is_approved', true)

  if (!data || data.length === 0) {
    await supabaseAdmin
      .from('products')
      .update({ rating: 0, num_reviews: 0 })
      .eq('id', productId)
    return
  }

  const sum = data.reduce((s, r) => s + r.rating, 0)
  const avg = Math.round((sum / data.length) * 10) / 10

  await supabaseAdmin
    .from('products')
    .update({ rating: avg, num_reviews: data.length })
    .eq('id', productId)
}

/**
 * Recompute vote counts on a comment
 */
const recomputeVoteCounts = async (commentId) => {
  const { data } = await supabaseAdmin
    .from('review_votes')
    .select('vote')
    .eq('comment_id', commentId)

  const helpful = (data || []).filter((v) => v.vote === 'helpful').length
  const notHelpful = (data || []).filter((v) => v.vote === 'not_helpful').length

  await supabaseAdmin
    .from('comments')
    .update({ helpful_count: helpful, not_helpful_count: notHelpful })
    .eq('id', commentId)
}