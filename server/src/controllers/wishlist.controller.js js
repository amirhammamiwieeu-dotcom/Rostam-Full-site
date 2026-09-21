import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getWishlist,
  toggleWishlist,
  clearWishlist,
} from '../services/wishlist.service.js'

export const list = asyncHandler(async (req, res) => {
  const wishlist = await getWishlist(req.user.id)
  return ApiResponse.success(res, wishlist, 'Wishlist retrieved')
})

export const toggle = asyncHandler(async (req, res) => {
  const result = await toggleWishlist(req.user.id, req.body.product_id)
  return ApiResponse.success(res, result, result.message)
})

export const clear = asyncHandler(async (req, res) => {
  await clearWishlist(req.user.id)
  return ApiResponse.success(res, null, 'Wishlist cleared')
})
