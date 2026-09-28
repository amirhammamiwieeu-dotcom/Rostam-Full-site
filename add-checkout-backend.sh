#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🔧 Adding Checkout Backend (verify-session)..."
echo ""

# ============================================================
# 1. payment.service.js — اضافه کردن verifySession
# ============================================================
cat > src/services/payment.service.js << 'ENDOFFILE'
import { stripe } from '../config/stripe.js'
import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import { getOrderById } from './order.service.js'
import { clearCart } from './cart.service.js'
import { sendOrderConfirmationEmail } from './email.service.js'

/**
 * Create Stripe Checkout Session
 */
export const createCheckoutSession = async (userId, orderId) => {
  const order = await getOrderById(orderId, userId)

  if (order.payment_status === 'paid') {
    throw ApiError.badRequest('Order already paid')
  }

  const lineItems = order.items.map((item) => ({
    price_data: {
      currency: 'usd',
      product_data: {
        name: item.title,
        images: item.image ? [item.image] : [],
      },
      unit_amount: Math.round(item.price * 100),
    },
    quantity: item.quantity,
  }))

  if (order.shipping_cost > 0) {
    lineItems.push({
      price_data: {
        currency: 'usd',
        product_data: { name: 'Shipping' },
        unit_amount: Math.round(order.shipping_cost * 100),
      },
      quantity: 1,
    })
  }

  if (order.tax > 0) {
    lineItems.push({
      price_data: {
        currency: 'usd',
        product_data: { name: 'Tax' },
        unit_amount: Math.round(order.tax * 100),
      },
      quantity: 1,
    })
  }

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    line_items: lineItems,
    customer_email: order.customer_email,
    success_url: `${process.env.CLIENT_URL}/order-success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.CLIENT_URL}/checkout?order_id=${order.id}&cancelled=true`,
    metadata: {
      order_id: order.id,
      order_number: order.order_number,
      user_id: userId,
    },
  })

  await supabaseAdmin
    .from('orders')
    .update({
      stripe_session_id: session.id,
      payment_id: session.payment_intent,
      payment_intent_id: session.payment_intent,
    })
    .eq('id', order.id)

  return { sessionId: session.id, url: session.url }
}

/**
 * 🆕 Verify Stripe session manually (polling — no webhook needed)
 */
export const verifySession = async (sessionId, userId) => {
  if (!sessionId) throw ApiError.badRequest('Session ID required')

  let session
  try {
    session = await stripe.checkout.sessions.retrieve(sessionId)
  } catch (err) {
    throw ApiError.badRequest('Invalid session ID')
  }

  const orderId = session.metadata?.order_id
  if (!orderId) throw ApiError.badRequest('Order not found in session')

  // Ensure this order belongs to the user
  const { data: order, error: orderErr } = await supabaseAdmin
    .from('orders')
    .select('id, user_id, payment_status, order_number, customer_email, customer_name, total, subtotal, discount, shipping_cost, tax')
    .eq('id', orderId)
    .maybeSingle()

  if (orderErr || !order) throw ApiError.notFound('Order not found')
  if (order.user_id !== userId) throw ApiError.forbidden('Not your order')

  // If already paid, just return
  if (order.payment_status === 'paid') {
    return { paid: true, status: 'paid', order }
  }

  // Check Stripe status
  const isPaid = session.payment_status === 'paid'

  if (isPaid) {
    // Mark order as paid
    const { data: updatedOrder } = await supabaseAdmin
      .from('orders')
      .update({
        status: 'confirmed',
        payment_status: 'paid',
        fulfillment_status: 'unfulfilled',
        paid_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', orderId)
      .select()
      .single()

    // Record payment
    await supabaseAdmin.from('payments').insert({
      order_id: orderId,
      user_id: userId,
      amount: session.amount_total / 100,
      currency: (session.currency || 'usd').toUpperCase(),
      provider: 'stripe',
      provider_payment_id: session.payment_intent,
      provider_session_id: session.id,
      status: 'succeeded',
      method: 'card',
    })

    // Clear cart
    await clearCart(userId).catch(() => {})

    // Send confirmation email
    sendOrderConfirmationEmail({
      to: order.customer_email,
      name: order.customer_name,
      order: updatedOrder || order,
    }).catch((err) => console.error('Order email failed:', err))

    return { paid: true, status: 'paid', order: updatedOrder || order }
  }

  return {
    paid: false,
    status: session.payment_status || 'pending',
    order,
  }
}

/**
 * Handle Stripe webhook (for production)
 */
export const handleWebhook = async (event) => {
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object)
      break
    case 'payment_intent.payment_failed':
      await handlePaymentFailed(event.data.object)
      break
    case 'charge.refunded':
      await handleRefund(event.data.object)
      break
    default:
      console.log(`Unhandled event type: ${event.type}`)
  }
}

const handleCheckoutComplete = async (session) => {
  const orderId = session.metadata?.order_id
  const userId = session.metadata?.user_id
  if (!orderId) return

  const { data: existingOrder } = await supabaseAdmin
    .from('orders')
    .select('payment_status, customer_email, customer_name')
    .eq('id', orderId)
    .maybeSingle()

  if (existingOrder?.payment_status === 'paid') return

  const { data: order } = await supabaseAdmin
    .from('orders')
    .update({
      status: 'confirmed',
      payment_status: 'paid',
      fulfillment_status: 'unfulfilled',
      paid_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', orderId)
    .select()
    .single()

  await supabaseAdmin.from('payments').insert({
    order_id: orderId,
    user_id: userId,
    amount: session.amount_total / 100,
    currency: (session.currency || 'usd').toUpperCase(),
    provider: 'stripe',
    provider_payment_id: session.payment_intent,
    provider_session_id: session.id,
    status: 'succeeded',
    method: 'card',
  })

  if (userId) await clearCart(userId).catch(() => {})

  if (order) {
    sendOrderConfirmationEmail({
      to: order.customer_email,
      name: order.customer_name,
      order,
    }).catch((err) => console.error('Order email failed:', err))
  }
}

const handlePaymentFailed = async (intent) => {
  const orderId = intent.metadata?.order_id
  if (!orderId) return
  await supabaseAdmin
    .from('orders')
    .update({ payment_status: 'failed', updated_at: new Date().toISOString() })
    .eq('id', orderId)
}

const handleRefund = async (charge) => {
  const paymentIntent = charge.payment_intent
  if (!paymentIntent) return
  const { data: payment } = await supabaseAdmin
    .from('payments')
    .select('order_id')
    .eq('provider_payment_id', paymentIntent)
    .maybeSingle()
  if (payment?.order_id) {
    await supabaseAdmin
      .from('orders')
      .update({
        payment_status: 'refunded',
        status: 'refunded',
        refunded_at: new Date().toISOString(),
      })
      .eq('id', payment.order_id)
  }
}

/**
 * Get payment status
 */
export const getPaymentStatus = async (orderId, userId) => {
  const order = await getOrderById(orderId, userId)
  return {
    order_id: order.id,
    payment_status: order.payment_status,
    status: order.status,
    paid_at: order.paid_at,
    total: order.total,
  }
}

/**
 * Create refund (admin)
 */
export const createRefund = async (orderId, { amount, reason }, adminId) => {
  const { data: order } = await supabaseAdmin
    .from('orders')
    .select('id, payment_id, total, payment_status')
    .eq('id', orderId)
    .maybeSingle()

  if (!order) throw ApiError.notFound('Order not found')
  if (order.payment_status !== 'paid') throw ApiError.badRequest('Order is not paid')
  if (amount > order.total) throw ApiError.badRequest('Refund exceeds total')

  const refund = await stripe.refunds.create({
    payment_intent: order.payment_id,
    amount: Math.round(amount * 100),
    reason: 'requested_by_customer',
  })

  const { data: refundRecord } = await supabaseAdmin
    .from('refunds')
    .insert({
      order_id: orderId,
      amount,
      reason,
      status: 'processed',
      provider_refund_id: refund.id,
      processed_by: adminId,
      processed_at: new Date().toISOString(),
    })
    .select()
    .single()

  await supabaseAdmin
    .from('orders')
    .update({
      payment_status: 'refunded',
      refunded_at: new Date().toISOString(),
    })
    .eq('id', orderId)

  return refundRecord
}
ENDOFFILE

echo "✅ payment.service.js updated"

# ============================================================
# 2. payment.controller.js
# ============================================================
cat > src/controllers/payment.controller.js << 'ENDOFFILE'
import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  createCheckoutSession,
  handleWebhook,
  getPaymentStatus,
  createRefund,
  verifySession,
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

export const refund = asyncHandler(async (req, res) => {
  const result = await createRefund(req.params.orderId, req.body, req.user.id)
  return ApiResponse.success(res, { refund: result }, 'Refund created')
})

// 🆕 Verify session (polling)
export const verifySessionCtrl = asyncHandler(async (req, res) => {
  const { session_id } = req.body
  const result = await verifySession(session_id, req.user.id)
  return ApiResponse.success(res, result, 'Session verified')
})
ENDOFFILE

echo "✅ payment.controller.js updated"

# ============================================================
# 3. payment.routes.js
# ============================================================
cat > src/routes/payment.routes.js << 'ENDOFFILE'
import { Router } from 'express'
import {
  createSession,
  status,
  webhook,
  refund,
  verifySessionCtrl,
} from '../controllers/payment.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import {
  createCheckoutSchema,
  refundSchema,
  verifySessionSchema,
} from '../validators/payment.schema.js'

const router = Router()

// Webhook (no auth — Stripe calls this)
router.post('/webhook', webhook)

// Authenticated
router.post('/create-session', requireAuth, validateBody(createCheckoutSchema), createSession)
router.get('/status/:orderId', requireAuth, status)

// 🆕 Verify session (polling)
router.post('/verify-session', requireAuth, validateBody(verifySessionSchema), verifySessionCtrl)

// Admin
router.post('/refund/:orderId', requireAuth, requireAdmin, validateBody(refundSchema), refund)

export default router
ENDOFFILE

echo "✅ payment.routes.js updated"

# ============================================================
# 4. payment.schema.js
# ============================================================
cat > src/validators/payment.schema.js << 'ENDOFFILE'
import { z } from 'zod'

export const createCheckoutSchema = z.object({
  order_id: z.string().uuid(),
})

export const refundSchema = z.object({
  amount: z.coerce.number().min(0.01),
  reason: z.string().max(500).optional(),
})

export const verifySessionSchema = z.object({
  session_id: z.string().min(3),
})
ENDOFFILE

echo "✅ payment.schema.js updated"

echo ""
echo "🎉 Backend done!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Backend terminal"
echo "   2. cd ~/Rostam-Full-site/server"
echo "   3. npm run dev"
echo ""
