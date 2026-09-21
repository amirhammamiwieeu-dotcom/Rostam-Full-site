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

  // Add shipping and tax as line items
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
    success_url: `${process.env.CLIENT_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.CLIENT_URL}/checkout/cancel?order_id=${order.id}`,
    metadata: {
      order_id: order.id,
      order_number: order.order_number,
      user_id: userId,
    },
    ...(order.discount > 0 && {
      discounts: [
        {
          coupon: await createStripeCoupon(order.discount),
        },
      ],
    }),
  })

  // Save session id
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
 * Create a one-time Stripe coupon for a fixed discount
 */
const createStripeCoupon = async (amount) => {
  const coupon = await stripe.coupons.create({
    amount_off: Math.round(amount * 100),
    currency: 'usd',
    duration: 'once',
  })
  return coupon.id
}

/**
 * Handle Stripe webhook
 */
export const handleWebhook = async (event) => {
  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object
      await handleCheckoutComplete(session)
      break
    }
    case 'payment_intent.succeeded': {
      break
    }
    case 'payment_intent.payment_failed': {
      const intent = event.data.object
      await handlePaymentFailed(intent)
      break
    }
    case 'charge.refunded': {
      const charge = event.data.object
      await handleRefund(charge)
      break
    }
    default:
      console.log(`Unhandled event type: ${event.type}`)
  }
}

const handleCheckoutComplete = async (session) => {
  const orderId = session.metadata?.order_id
  const userId = session.metadata?.user_id

  if (!orderId) return

  // Update order
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

  // Record payment
  await supabaseAdmin.from('payments').insert({
    order_id: orderId,
    user_id: userId,
    amount: session.amount_total / 100,
    currency: session.currency,
    provider: 'stripe',
    provider_payment_id: session.payment_intent,
    provider_session_id: session.id,
    status: 'succeeded',
    method: 'card',
    metadata: { customer_email: session.customer_email },
  })

  // Clear user's cart
  if (userId) {
    await clearCart(userId).catch(() => {})
  }

  // Send confirmation email
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
    .update({
      payment_status: 'failed',
      updated_at: new Date().toISOString(),
    })
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
  if (order.payment_status !== 'paid') {
    throw ApiError.badRequest('Order is not paid')
  }
  if (amount > order.total) {
    throw ApiError.badRequest('Refund amount exceeds order total')
  }

  const refund = await stripe.refunds.create({
    payment_intent: order.payment_id,
    amount: Math.round(amount * 100),
    reason: 'requested_by_customer',
  })

  const { data: refundRecord } = await supabaseAdmin
    .from('refunds')
    .insert({
      order_id: orderId,
      payment_id: null,
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