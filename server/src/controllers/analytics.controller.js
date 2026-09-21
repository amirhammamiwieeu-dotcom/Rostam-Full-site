import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  trackProductView,
  trackSearch,
  getRecentlyViewed,
  getTrendingSearches,
  getTopViewed,
} from '../services/analytics.service.js'

export const trackView = asyncHandler(async (req, res) => {
  await trackProductView(req, req.body)
  return ApiResponse.success(res, null, 'Tracked')
})

export const trackSearchCtrl = asyncHandler(async (req, res) => {
  await trackSearch(req, req.body)
  return ApiResponse.success(res, null, 'Tracked')
})

export const recentlyViewed = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 8
  const products = await getRecentlyViewed(req.user.id, limit)
  return ApiResponse.success(res, { products }, 'Recently viewed')
})

export const trendingSearches = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 10
  const searches = await getTrendingSearches(limit)
  return ApiResponse.success(res, { searches }, 'Trending searches')
})

export const topViewed = asyncHandler(async (req, res) => {
  const days = parseInt(req.query.days) || 7
  const limit = parseInt(req.query.limit) || 10
  const products = await getTopViewed(days, limit)
  return ApiResponse.success(res, { products }, 'Top viewed')
})