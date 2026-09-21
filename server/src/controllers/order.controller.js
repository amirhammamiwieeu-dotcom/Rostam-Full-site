import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  createOrder,
  getOrderById,
  getUserOrders,
  cancelOrder,
  updateOrderStatus,
} from '../services/order.service.js'

export const create = asyncHandler(async (req, res) => {
  const order = await createOrder(req.user.id, req.body)
  return ApiResponse.created(res, { order }, 'Order created')
})

export const list = asyncHandler(async (req, res) => {
  const result = await getUserOrders(req.user.id, req.query)
  return ApiResponse.success(res, result, 'Orders retrieved')
})

export const getOne = asyncHandler(async (req, res) => {
  const order = await getOrderById(req.params.id, req.user.id)
  return ApiResponse.success(res, { order }, 'Order retrieved')
})

export const cancel = asyncHandler(async (req, res) => {
  await cancelOrder(req.params.id, req.user.id)
  return ApiResponse.success(res, null, 'Order cancelled')
})

// Admin
export const adminUpdateStatus = asyncHandler(async (req, res) => {
  const order = await updateOrderStatus(req.params.id, req.body)
  return ApiResponse.success(res, { order }, 'Order updated')
})