import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  generateDescription,
  smartSearch,
  chat,
  recommendProducts,
  translateText,
} from '../services/ai.service.js'

export const generateProductDescription = asyncHandler(async (req, res) => {
  const result = await generateDescription(req.body)
  return ApiResponse.success(res, result, 'Description generated')
})

export const smartSearchCtrl = asyncHandler(async (req, res) => {
  const result = await smartSearch(req.body.query)
  return ApiResponse.success(res, result, 'Search parsed')
})

export const chatCtrl = asyncHandler(async (req, res) => {
  const result = await chat(req.body)
  return ApiResponse.success(res, result, 'Reply generated')
})

export const recommendCtrl = asyncHandler(async (req, res) => {
  const { product_id, limit } = req.body
  const result = await recommendProducts({ product_id, limit })
  return ApiResponse.success(res, result, 'Recommendations')
})

export const translateCtrl = asyncHandler(async (req, res) => {
  const result = await translateText(req.body)
  return ApiResponse.success(res, result, 'Translation')
})