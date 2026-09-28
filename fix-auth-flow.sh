#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🔧 Fixing Auth flow (signup, signin, forgot-password)..."
echo ""

cp src/services/auth.service.js src/services/auth.service.js.backup-$(date +%s) 2>/dev/null || true

cat > src/services/auth.service.js << 'ENDOFFILE'
import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import {
  sendWelcomeEmail,
  sendPasswordResetEmail,
} from './email.service.js'

// ============================================================
// SIGN UP
// ============================================================
export const registerUser = async ({ email, password, full_name, phone }) => {
  // 1. Check existing user
  const { data: existing } = await supabaseAdmin
    .from('profiles')
    .select('id')
    .eq('email', email)
    .maybeSingle()

  if (existing) {
    throw ApiError.conflict('Email already registered')
  }

  // 2. Create user in Supabase Auth
  // email_confirm: false → Supabase sends confirmation email
  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email,
    password,
    email_confirm: false,
    user_metadata: {
      full_name,
      phone: phone || null,
    },
  })

  if (error) {
    console.error('❌ Signup error:', error.message)
    throw ApiError.badRequest(error.message)
  }

  // 3. Send welcome email (non-blocking)
  sendWelcomeEmail({ to: email, name: full_name }).catch((err) =>
    console.error('Welcome email failed:', err)
  )

  // 4. Note: Supabase automatically sends confirmation email
  // via custom SMTP (Resend) — we don't need to do it manually

  console.log(`✅ User registered: ${email}`)
  return data.user
}

// ============================================================
// SIGN IN
// ============================================================
export const loginUser = async ({ email, password }) => {
  const { data, error } = await supabaseAdmin.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    console.error('❌ Login error:', error.message)

    // Check specific errors
    if (error.message.includes('Email not confirmed')) {
      throw ApiError.forbidden(
        'Please confirm your email before signing in. Check your inbox.'
      )
    }
    if (error.message.includes('Invalid login credentials')) {
      throw ApiError.unauthorized('Invalid email or password')
    }
    throw ApiError.unauthorized(error.message)
  }

  // Update last_login_at
  await supabaseAdmin
    .from('profiles')
    .update({ last_login_at: new Date().toISOString() })
    .eq('id', data.user.id)

  return {
    user: data.user,
    session: data.session,
  }
}

// ============================================================
// FORGOT PASSWORD
// ============================================================
export const forgotPassword = async ({ email }) => {
  // 1. Check if user exists (don't reveal in response)
  const { data: profile } = await supabaseAdmin
    .from('profiles')
    .select('full_name')
    .eq('email', email)
    .maybeSingle()

  if (!profile) {
    // Don't reveal that email doesn't exist (security)
    console.log(`⚠️  Forgot password for non-existent email: ${email}`)
    return { success: true }
  }

  // 2. Generate reset link via Supabase
  // Supabase will send the email via custom SMTP (Resend)
  const { data, error } = await supabaseAdmin.auth.admin.generateLink({
    type: 'recovery',
    email,
    options: {
      redirectTo: `${process.env.CLIENT_URL}/reset-password`,
    },
  })

  if (error) {
    console.error('❌ Generate link error:', error.message)
    throw ApiError.badRequest(error.message)
  }

  // 3. Optionally send a custom email with Resend
  // (Supabase already sends its own via SMTP, so this is a fallback/backup)
  if (data?.properties?.action_link) {
    sendPasswordResetEmail({
      to: email,
      name: profile.full_name || 'there',
      resetLink: data.properties.action_link,
    }).catch((err) => console.error('Reset email failed:', err))
  }

  console.log(`✅ Password reset link sent: ${email}`)
  return { success: true }
}

// ============================================================
// GET PROFILE
// ============================================================
export const getUserProfile = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single()

  if (error) throw ApiError.notFound('Profile not found')
  return data
}

// ============================================================
// UPDATE PROFILE
// ============================================================
export const updateUserProfile = async (userId, updates) => {
  const allowed = ['full_name', 'phone', 'username', 'bio', 'avatar_url']
  const clean = {}
  allowed.forEach((k) => {
    if (updates[k] !== undefined) clean[k] = updates[k]
  })

  const { data, error } = await supabaseAdmin
    .from('profiles')
    .update({ ...clean, updated_at: new Date().toISOString() })
    .eq('id', userId)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return data
}

// ============================================================
// CHANGE PASSWORD
// ============================================================
export const changePassword = async (userId, { current_password, new_password }) => {
  const { data: user } = await supabaseAdmin.auth.admin.getUserById(userId)
  if (!user?.user?.email) throw ApiError.notFound('User not found')

  // Verify current password
  const { error: signInError } = await supabaseAdmin.auth.signInWithPassword({
    email: user.user.email,
    password: current_password,
  })

  if (signInError) throw ApiError.unauthorized('Current password is incorrect')

  // Update password
  const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
    password: new_password,
  })

  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}

// ============================================================
// RESEND CONFIRMATION EMAIL
// ============================================================
export const resendConfirmation = async (email) => {
  const { error } = await supabaseAdmin.auth.resend({
    type: 'signup',
    email,
    options: {
      emailRedirectTo: `${process.env.CLIENT_URL}/auth/callback`,
    },
  })

  if (error) {
    console.error('❌ Resend error:', error.message)
    throw ApiError.badRequest(error.message)
  }

  console.log(`📧 Confirmation email resent: ${email}`)
  return { success: true }
}

// ============================================================
// LOGOUT
// ============================================================
export const logoutUser = async () => {
  return { success: true }
}
ENDOFFILE

echo "✅ auth.service.js updated"

# ============================================================
# Update controller
# ============================================================
echo ""
echo "📦 Updating auth.controller.js..."

cp src/controllers/auth.controller.js src/controllers/auth.controller.js.backup-$(date +%s) 2>/dev/null || true

cat > src/controllers/auth.controller.js << 'ENDOFFILE'
import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  registerUser,
  loginUser,
  getUserProfile,
  updateUserProfile,
  changePassword,
  forgotPassword,
  resendConfirmation,
  logoutUser,
} from '../services/auth.service.js'

// ============================================================
// SIGN UP
// ============================================================
export const register = asyncHandler(async (req, res) => {
  const { email, password, full_name, phone } = req.body
  const user = await registerUser({ email, password, full_name, phone })

  return ApiResponse.created(
    res,
    {
      user: {
        id: user.id,
        email: user.email,
        full_name: user.user_metadata?.full_name,
      },
    },
    'Account created! Please check your email to confirm.'
  )
})

// ============================================================
// SIGN IN
// ============================================================
export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body
  const { user, session } = await loginUser({ email, password })

  return ApiResponse.success(
    res,
    {
      user: {
        id: user.id,
        email: user.email,
        full_name: user.user_metadata?.full_name,
      },
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      expires_at: session.expires_at,
    },
    'Login successful'
  )
})

// ============================================================
// GET ME
// ============================================================
export const me = asyncHandler(async (req, res) => {
  const profile = await getUserProfile(req.user.id)
  return ApiResponse.success(res, { profile }, 'Profile retrieved')
})

// ============================================================
// UPDATE ME
// ============================================================
export const updateMe = asyncHandler(async (req, res) => {
  const profile = await updateUserProfile(req.user.id, req.body)
  return ApiResponse.success(res, { profile }, 'Profile updated')
})

// ============================================================
// CHANGE PASSWORD
// ============================================================
export const changePasswordCtrl = asyncHandler(async (req, res) => {
  await changePassword(req.user.id, req.body)
  return ApiResponse.success(res, null, 'Password changed successfully')
})

// ============================================================
// FORGOT PASSWORD
// ============================================================
export const forgotPasswordCtrl = asyncHandler(async (req, res) => {
  await forgotPassword(req.body)
  return ApiResponse.success(
    res,
    null,
    'If an account exists with that email, a reset link has been sent.'
  )
})

// ============================================================
// RESEND CONFIRMATION
// ============================================================
export const resendConfirmationCtrl = asyncHandler(async (req, res) => {
  await resendConfirmation(req.body.email)
  return ApiResponse.success(res, null, 'Confirmation email resent')
})

// ============================================================
// LOGOUT
// ============================================================
export const logout = asyncHandler(async (req, res) => {
  await logoutUser(req.user.id)
  return ApiResponse.success(res, null, 'Logged out successfully')
})
ENDOFFILE

echo "✅ auth.controller.js updated"

# ============================================================
# Update routes
# ============================================================
echo ""
echo "📦 Updating auth.routes.js..."

cp src/routes/auth.routes.js src/routes/auth.routes.js.backup-$(date +%s) 2>/dev/null || true

cat > src/routes/auth.routes.js << 'ENDOFFILE'
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
ENDOFFILE

echo "✅ auth.routes.js updated"

# ============================================================
# Update validators
# ============================================================
echo ""
echo "📦 Adding resendConfirmationSchema..."

# Add to validators
cat >> src/validators/auth.schema.js << 'ENDOFFILE'

export const resendConfirmationSchema = z.object({
  email: z
    .string({ required_error: 'Email is required' })
    .email('Invalid email address')
    .toLowerCase(),
})
ENDOFFILE

echo "✅ auth.schema.js updated"

echo ""
echo "🎉 Backend done!"
echo ""
echo "📋 Next:"
echo "   1. Restart Backend: Ctrl+C → npm run dev"
echo "   2. Test: Register → Email → Confirm → Login"
echo ""
