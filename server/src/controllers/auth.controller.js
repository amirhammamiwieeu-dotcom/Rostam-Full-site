import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  registerUser,
  loginUser,
  googleAuth,
  getUserProfile,
  updateUserProfile,
  changePassword,
  forgotPassword,
  sendEmailVerification,
  logoutUser,
} from '../services/auth.service.js'

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
    'Account created successfully. Please check your email to verify.'
  )
})

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

export const google = asyncHandler(async (req, res) => {
  const user = await googleAuth(req.body)

  return ApiResponse.success(
    res,
    {
      user: {
        id: user.id,
        email: user.email,
        full_name: user.user_metadata?.full_name,
      },
    },
    'Google authentication successful'
  )
})

export const me = asyncHandler(async (req, res) => {
  const profile = await getUserProfile(req.user.id)
  return ApiResponse.success(res, { profile }, 'Profile retrieved')
})

export const updateMe = asyncHandler(async (req, res) => {
  const profile = await updateUserProfile(req.user.id, req.body)
  return ApiResponse.success(res, { profile }, 'Profile updated')
})

export const changePasswordCtrl = asyncHandler(async (req, res) => {
  await changePassword(req.user.id, req.body)
  return ApiResponse.success(res, null, 'Password changed successfully')
})

export const forgotPasswordCtrl = asyncHandler(async (req, res) => {
  await forgotPassword(req.body)
  return ApiResponse.success(
    res,
    null,
    'If an account exists with that email, a reset link has been sent.'
  )
})

export const sendVerification = asyncHandler(async (req, res) => {
  await sendEmailVerification(req.user.id)
  return ApiResponse.success(res, null, 'Verification email sent')
})

export const logout = asyncHandler(async (req, res) => {
  await logoutUser(req.user.id)
  return ApiResponse.success(res, null, 'Logged out successfully')
})
