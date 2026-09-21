import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  createCheckoutSession,
  handleWebhook,
  getPaymentStatus,
  createRefund,
} from '../services/payment.service.js'
import { stripe } from '../config/stripe.js'

export const createSession = asyncHandler(async (req, res) => {
  const result = await createCheckoutSession(req.user.id, req.body.order_id)
  return ApiResponse.success(res, result, 'Checkout session created')
})

export const status = asyncHandler(async (req, res) => {
  const result = await getPaymentStatus(req.params.orderId, req.user.id)
  return ApiResponse.success(res, result, 'Payment status')
})

export const webhook = asyncHandler(async (req, res) => {
  const sig = req.headers['stripe-signature']
  let event

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    console.error('❌ Webhook signature failed:', err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  await handleWebhook(event)
  res.json({ received: true })
})

// Admin
export const refund = asyncHandler(async (req, res) => {
  const result = await createRefund(req.params.orderId, req.body, req.user.id)
  return ApiResponse.success(res, { refund: result }, 'Refund created')
})