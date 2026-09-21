import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getCompare,
  addToCompare,
  removeFromCompare,
  clearCompare,
} from '../services/compare.service.js'

export const list = asyncHandler(async (req, res) => {
  const compare = await getCompare(req.user.id)
  return ApiResponse.success(res, compare, 'Compare list retrieved')
})

export const add = asyncHandler(async (req, res) => {
  const compare = await addToCompare(req.user.id, req.body.product_id)
  return ApiResponse.success(res, compare, 'Added to compare')
})

export const remove = asyncHandler(async (req, res) => {
  const compare = await removeFromCompare(req.user.id, req.params.productId)
  return ApiResponse.success(res, compare, 'Removed from compare')
})

export const clear = asyncHandler(async (req, res) => {
  await clearCompare(req.user.id)
  return ApiResponse.success(res, null, 'Compare list cleared')
})
