import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getProducts,
  getProductById,
  getProductBySlug,
  getRelatedProducts,
  getFeaturedProducts,
  getNewArrivals,
  getBestSellers,
  searchProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  incrementProductViews,
} from '../services/product.service.js'

export const list = asyncHandler(async (req, res) => {
  const result = await getProducts(req.query)
  return ApiResponse.success(res, result, 'Products retrieved')
})

export const getOne = asyncHandler(async (req, res) => {
  const product = await getProductById(req.params.id)
  incrementProductViews(req.params.id).catch(() => {})
  return ApiResponse.success(res, { product }, 'Product retrieved')
})

export const getBySlug = asyncHandler(async (req, res) => {
  const product = await getProductBySlug(req.params.slug)
  incrementProductViews(product.id).catch(() => {})
  return ApiResponse.success(res, { product }, 'Product retrieved')
})

export const related = asyncHandler(async (req, res) => {
  const products = await getRelatedProducts(req.params.id, 8)
  return ApiResponse.success(res, { products }, 'Related products')
})

export const featured = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getFeaturedProducts(limit)
  return ApiResponse.success(res, { products }, 'Featured products')
})

export const newArrivals = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getNewArrivals(limit)
  return ApiResponse.success(res, { products }, 'New arrivals')
})

export const bestSellers = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getBestSellers(limit)
  return ApiResponse.success(res, { products }, 'Best sellers')
})

export const search = asyncHandler(async (req, res) => {
  const q = req.query.q || ''
  const limit = parseInt(req.query.limit) || 10
  const products = await searchProducts(q, limit)
  return ApiResponse.success(res, { products }, 'Search results')
})

// ============================================================
// Admin
// ============================================================
export const create = asyncHandler(async (req, res) => {
  const product = await createProduct(req.body)
  return ApiResponse.created(res, { product }, 'Product created')
})

export const update = asyncHandler(async (req, res) => {
  const product = await updateProduct(req.params.id, req.body)
  return ApiResponse.success(res, { product }, 'Product updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteProduct(req.params.id)
  return ApiResponse.success(res, null, 'Product deleted')
})
