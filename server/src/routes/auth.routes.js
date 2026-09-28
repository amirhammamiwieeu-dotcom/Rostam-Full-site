import { Router } from 'express'
import rateLimit from 'express-rate-limit'
import {
  register,
  login,
  me,
  updateMe,
  changePasswordCtrl,
  forgotPasswordCtrl,
  resendConfirmationCtrl,
  logout,
} from '../controllers/auth.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import {
  registerSchema,
  loginSchema,
  forgotPasswordSchema,
  updateProfileSchema,
  changePasswordSchema,
  resendConfirmationSchema,
} from '../validators/auth.schema.js'

const router = Router()

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: {
    success: false,
    message: 'Too many attempts. Please try again in 15 minutes.',
  },
})

// ============================================================
// Public
// ============================================================
router.post('/register', authLimiter, validateBody(registerSchema), register)
router.post('/login', authLimiter, validateBody(loginSchema), login)
router.post(
  '/forgot-password',
  authLimiter,
  validateBody(forgotPasswordSchema),
  forgotPasswordCtrl
)
router.post(
  '/resend-confirmation',
  authLimiter,
  validateBody(resendConfirmationSchema),
  resendConfirmationCtrl
)

// ============================================================
// Protected
// ============================================================
router.get('/me', requireAuth, me)
router.put('/me', requireAuth, validateBody(updateProfileSchema), updateMe)
router.post(
  '/change-password',
  requireAuth,
  validateBody(changePasswordSchema),
  changePasswordCtrl
)
router.post('/logout', requireAuth, logout)

export default router
