import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import {
  sendWelcomeEmail,
  sendPasswordResetEmail,
  sendVerificationEmail,
} from './email.service.js'

/**
 * Register new user with email + password
 */
export const registerUser = async ({ email, password, full_name, phone }) => {
  const { data: existing } = await supabaseAdmin
    .from('profiles')
    .select('id')
    .eq('email', email)
    .maybeSingle()

  if (existing) {
    throw ApiError.conflict('Email already registered')
  }

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
    throw ApiError.badRequest(error.message)
  }

  if (phone) {
    await supabaseAdmin
      .from('profiles')
      .update({ phone })
      .eq('id', data.user.id)
  }

  sendWelcomeEmail({ to: email, name: full_name }).catch((err) =>
    console.error('Welcome email failed:', err)
  )

  return data.user
}

/**
 * Login with email + password
 */
export const loginUser = async ({ email, password }) => {
  const { data, error } = await supabaseAdmin.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    throw ApiError.unauthorized('Invalid email or password')
  }

  await supabaseAdmin
    .from('profiles')
    .update({ last_login_at: new Date().toISOString() })
    .eq('id', data.user.id)

  return {
    user: data.user,
    session: data.session,
  }
}

/**
 * Verify token (used for Google OAuth flow from client)
 */
export const googleAuth = async ({ access_token, id_token }) => {
  const { data, error } = await supabaseAdmin.auth.getUser(
    id_token || access_token
  )

  if (error || !data.user) {
    throw ApiError.unauthorized('Invalid token')
  }

  await supabaseAdmin
    .from('profiles')
    .update({ last_login_at: new Date().toISOString() })
    .eq('id', data.user.id)

  return data.user
}

/**
 * Get user profile
 */
export const getUserProfile = async (userId) => {
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single()

  if (error) {
    throw ApiError.notFound('Profile not found')
  }

  return data
}

/**
 * Update user profile
 */
export const updateUserProfile = async (userId, updates) => {
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .update({
      ...updates,
      updated_at: new Date().toISOString(),
    })
    .eq('id', userId)
    .select()
    .single()

  if (error) {
    throw ApiError.badRequest(error.message)
  }

  return data
}

/**
 * Change password (user knows current password)
 */
export const changePassword = async (userId, { current_password, new_password }) => {
  const { data: user } = await supabaseAdmin.auth.admin.getUserById(userId)
  if (!user?.user?.email) {
    throw ApiError.notFound('User not found')
  }

  const { error: signInError } = await supabaseAdmin.auth.signInWithPassword({
    email: user.user.email,
    password: current_password,
  })

  if (signInError) {
    throw ApiError.unauthorized('Current password is incorrect')
  }

  const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
    password: new_password,
  })

  if (error) {
    throw ApiError.badRequest(error.message)
  }

  return { success: true }
}

/**
 * Send password reset email
 */
export const forgotPassword = async ({ email }) => {
  const { data: profile } = await supabaseAdmin
    .from('profiles')
    .select('full_name')
    .eq('email', email)
    .maybeSingle()

  // Don't reveal if email exists (security)
  if (profile) {
    const { data, error } = await supabaseAdmin.auth.admin.generateLink({
      type: 'recovery',
      email,
      options: {
        redirectTo: `${process.env.CLIENT_URL}/reset-password`,
      },
    })

    if (!error && data?.properties?.action_link) {
      await sendPasswordResetEmail({
        to: email,
        name: profile.full_name || 'there',
        resetLink: data.properties.action_link,
      }).catch((err) => console.error('Reset email failed:', err))
    }
  }

  return { success: true }
}

/**
 * Send email verification link
 */
export const sendEmailVerification = async (userId) => {
  const { data: user } = await supabaseAdmin.auth.admin.getUserById(userId)
  if (!user?.user?.email) {
    throw ApiError.notFound('User not found')
  }

  const { data, error } = await supabaseAdmin.auth.admin.generateLink({
    type: 'signup',
    email: user.user.email,
    options: {
      redirectTo: `${process.env.CLIENT_URL}/auth/callback`,
    },
  })

  if (error) {
    throw ApiError.badRequest(error.message)
  }

  const { data: profile } = await supabaseAdmin
    .from('profiles')
    .select('full_name')
    .eq('id', userId)
    .single()

  await sendVerificationEmail({
    to: user.user.email,
    name: profile?.full_name || 'there',
    verifyLink: data.properties.action_link,
  })

  return { success: true }
}

/**
 * Logout (client handles session revocation)
 */
export const logoutUser = async () => {
  return { success: true }
}
