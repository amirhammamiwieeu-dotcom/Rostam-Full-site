import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getPublicCoupons,
  getAllCoupons,
  createCoupon,
  updateCoupon,
  deleteCoupon,
} from '../services/coupon.service.js'

// Public
export const publicList = asyncHandler(async (req, res) => {
  const coupons = await getPublicCoupons()
  return ApiResponse.success(res, { coupons }, 'Public coupons retrieved')
})

// Admin
export const adminList = asyncHandler(async (req, res) => {
  const coupons = await getAllCoupons()
  return ApiResponse.success(res, { coupons }, 'Coupons retrieved')
})

export const create = asyncHandler(async (req, res) => {
  const coupon = await createCoupon(req.body)
  return ApiResponse.created(res, { coupon }, 'Coupon created')
})

export const update = asyncHandler(async (req, res) => {
  const coupon = await updateCoupon(req.params.id, req.body)
  return ApiResponse.success(res, { coupon }, 'Coupon updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteCoupon(req.params.id)
  return ApiResponse.success(res, null, 'Coupon deleted')
})
