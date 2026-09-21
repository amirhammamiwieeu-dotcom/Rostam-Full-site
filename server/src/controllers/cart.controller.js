import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
  validateCart,
} from '../services/cart.service.js'
import { validateCoupon } from '../services/coupon.service.js'

export const get = asyncHandler(async (req, res) => {
  const cart = await getCart(req.user.id)
  return ApiResponse.success(res, cart, 'Cart retrieved')
})

export const add = asyncHandler(async (req, res) => {
  const cart = await addToCart(req.user.id, req.body)
  return ApiResponse.success(res, cart, 'Added to cart')
})

export const update = asyncHandler(async (req, res) => {
  const cart = await updateCartItem(req.user.id, req.params.id, req.body.quantity)
  return ApiResponse.success(res, cart, 'Cart updated')
})

export const remove = asyncHandler(async (req, res) => {
  const cart = await removeCartItem(req.user.id, req.params.id)
  return ApiResponse.success(res, cart, 'Removed from cart')
})

export const clear = asyncHandler(async (req, res) => {
  const cart = await clearCart(req.user.id)
  return ApiResponse.success(res, cart, 'Cart cleared')
})

export const validateStock = asyncHandler(async (req, res) => {
  const result = await validateCart(req.user.id)
  return ApiResponse.success(res, result, 'Cart validated')
})

export const applyCoupon = asyncHandler(async (req, res) => {
  const cart = await getCart(req.user.id)
  const result = await validateCoupon(req.body.code, cart.subtotal, req.user.id)

  return ApiResponse.success(
    res,
    {
      ...result,
      subtotal: cart.subtotal,
      total: cart.subtotal - result.discountAmount,
    },
    'Coupon applied'
  )
})
