import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getBrands,
  getBrandBySlug,
  createBrand,
  updateBrand,
  deleteBrand,
} from '../services/brand.service.js'

export const list = asyncHandler(async (req, res) => {
  const { isActive, isFeatured } = req.query
  const brands = await getBrands({
    isActive: isActive !== 'false',
    isFeatured: isFeatured === 'true' ? true : undefined,
  })
  return ApiResponse.success(res, { brands }, 'Brands retrieved')
})

export const getBySlug = asyncHandler(async (req, res) => {
  const brand = await getBrandBySlug(req.params.slug)
  return ApiResponse.success(res, { brand }, 'Brand retrieved')
})

export const create = asyncHandler(async (req, res) => {
  const brand = await createBrand(req.body)
  return ApiResponse.created(res, { brand }, 'Brand created')
})

export const update = asyncHandler(async (req, res) => {
  const brand = await updateBrand(req.params.id, req.body)
  return ApiResponse.success(res, { brand }, 'Brand updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteBrand(req.params.id)
  return ApiResponse.success(res, null, 'Brand deleted')
})
