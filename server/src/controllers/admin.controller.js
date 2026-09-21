import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getDashboardStats,
  getAllUsers,
  updateUser,
  getAllOrders,
  getAllComments,
  setCommentApproval,
  getSalesReport,
  getLowStockProducts,
} from '../services/admin.service.js'

export const dashboard = asyncHandler(async (req, res) => {
  const stats = await getDashboardStats()
  return ApiResponse.success(res, stats, 'Dashboard stats')
})

export const users = asyncHandler(async (req, res) => {
  const result = await getAllUsers(req.query)
  return ApiResponse.success(res, result, 'Users retrieved')
})

export const updateUserCtrl = asyncHandler(async (req, res) => {
  const user = await updateUser(req.params.id, req.body)
  return ApiResponse.success(res, { user }, 'User updated')
})

export const orders = asyncHandler(async (req, res) => {
  const result = await getAllOrders(req.query)
  return ApiResponse.success(res, result, 'Orders retrieved')
})

export const comments = asyncHandler(async (req, res) => {
  const result = await getAllComments(req.query)
  return ApiResponse.success(res, result, 'Comments retrieved')
})

export const approveComment = asyncHandler(async (req, res) => {
  const comment = await setCommentApproval(req.params.id, req.body.is_approved)
  return ApiResponse.success(res, { comment }, 'Comment updated')
})

export const salesReport = asyncHandler(async (req, res) => {
  const report = await getSalesReport(req.query)
  return ApiResponse.success(res, report, 'Sales report')
})

export const lowStock = asyncHandler(async (req, res) => {
  const products = await getLowStockProducts(parseInt(req.query.threshold) || 5)
  return ApiResponse.success(res, { products }, 'Low stock products')
})