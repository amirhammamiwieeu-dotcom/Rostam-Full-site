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
