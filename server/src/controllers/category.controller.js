import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getCategories,
  getCategoryBySlug,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getMainCategories,
  getCategoryWithChildren,
} from '../services/category.service.js'

export const list = asyncHandler(async (req, res) => {
  const { parent, isActive, isFeatured, tree } = req.query
  const categories = await getCategories({
    parent: parent || undefined,
    isActive: isActive !== 'false',
    isFeatured: isFeatured === 'true' ? true : undefined,
    tree: tree === 'true',
  })
  return ApiResponse.success(res, { categories }, 'Categories retrieved')
})

// 🆕 Main categories with children
export const mainList = asyncHandler(async (req, res) => {
  const categories = await getMainCategories()
  return ApiResponse.success(res, { categories }, 'Main categories retrieved')
})

// 🆕 Category with children (for /category/:slug)
export const withChildren = asyncHandler(async (req, res) => {
  const result = await getCategoryWithChildren(req.params.slug)
  return ApiResponse.success(res, result, 'Category retrieved')
})

export const getBySlug = asyncHandler(async (req, res) => {
  const category = await getCategoryBySlug(req.params.slug)
  return ApiResponse.success(res, { category }, 'Category retrieved')
})

export const getOne = asyncHandler(async (req, res) => {
  const category = await getCategoryById(req.params.id)
  return ApiResponse.success(res, { category }, 'Category retrieved')
})

export const create = asyncHandler(async (req, res) => {
  const category = await createCategory(req.body)
  return ApiResponse.created(res, { category }, 'Category created')
})

export const update = asyncHandler(async (req, res) => {
  const category = await updateCategory(req.params.id, req.body)
  return ApiResponse.success(res, { category }, 'Category updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteCategory(req.params.id)
  return ApiResponse.success(res, null, 'Category deleted')
})
