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
