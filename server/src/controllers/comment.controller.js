import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getProductComments,
  getRatingSummary,
  addComment,
  updateComment,
  deleteComment,
  voteComment,
  adminReply,
  getUserComments,
} from '../services/comment.service.js'
import { supabaseAdmin } from '../config/supabase.js'

export const listByProduct = asyncHandler(async (req, res) => {
  const result = await getProductComments(req.params.productId, req.query)
  return ApiResponse.success(res, result, 'Comments retrieved')
})

export const ratingSummary = asyncHandler(async (req, res) => {
  const summary = await getRatingSummary(req.params.productId)
  return ApiResponse.success(res, summary, 'Rating summary')
})

export const create = asyncHandler(async (req, res) => {
  const comment = await addComment(req.user.id, req.body)
  return ApiResponse.created(res, { comment }, 'Comment added')
})

export const update = asyncHandler(async (req, res) => {
  const comment = await updateComment(req.params.id, req.user.id, req.body)
  return ApiResponse.success(res, { comment }, 'Comment updated')
})

export const remove = asyncHandler(async (req, res) => {
  const isAdmin = req.profile?.role === 'admin'
  await deleteComment(req.params.id, req.user.id, isAdmin)
  return ApiResponse.success(res, null, 'Comment deleted')
})

export const vote = asyncHandler(async (req, res) => {
  await voteComment(req.params.id, req.user.id, req.body.vote)
  return ApiResponse.success(res, null, 'Vote recorded')
})

export const myComments = asyncHandler(async (req, res) => {
  const comments = await getUserComments(req.user.id)
  return ApiResponse.success(res, { comments }, 'Your comments')
})

// Admin
export const adminReplyCtrl = asyncHandler(async (req, res) => {
  const comment = await adminReply(req.params.id, req.body.admin_reply)
  return ApiResponse.success(res, { comment }, 'Reply added')
})