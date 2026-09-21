import { Router } from 'express'
import rateLimit from 'express-rate-limit'
import {
  register,
  login,
  google,
  me,
  updateMe,
  changePasswordCtrl,
  forgotPasswordCtrl,
  sendVerification,
  logout,
} from '../controllers/auth.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import {
  registerSchema,
  loginSchema,
  googleAuthSchema,
  forgotPasswordSchema,
  updateProfileSchema,
  changePasswordSchema,
} from '../validators/auth.schema.js'

const router = Router()

// Strict rate limit for auth actions
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: {
    success: false,
    message: 'Too many attempts. Please try again in 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// ============================================================
// Public
// ============================================================
router.post('/register', authLimiter, validateBody(registerSchema), register)
router.post('/login', authLimiter, validateBody(loginSchema), login)
router.post('/google', authLimiter, validateBody(googleAuthSchema), google)
router.post(
  '/forgot-password',
  authLimiter,
  validateBody(forgotPasswordSchema),
  forgotPasswordCtrl
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
router.post('/send-verification', requireAuth, sendVerification)
router.post('/logout', requireAuth, logout)

export default router
