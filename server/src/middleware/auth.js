import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

/**
 * Verify Supabase JWT and attach user + profile to request
 */
export const requireAuth = async (req, res, next) => {
  try {
    let token
    if (req.headers.authorization?.startsWith('Bearer ')) {
      token = req.headers.authorization.split(' ')[1]
    }

    if (!token) {
      throw ApiError.unauthorized('No token provided')
    }

    const { data: { user }, error } = await supabaseAdmin.auth.getUser(token)

    if (error || !user) {
      throw ApiError.unauthorized('Invalid or expired token')
    }

    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()

    if (profileError && profileError.code !== 'PGRST116') {
      throw profileError
    }

    req.user = user
    req.profile = profile
    req.token = token

    next()
  } catch (err) {
    next(err)
  }
}

/**
 * Optional auth — doesn't fail if no token, but attaches user if present
 */
export const optionalAuth = async (req, res, next) => {
  try {
    let token
    if (req.headers.authorization?.startsWith('Bearer ')) {
      token = req.headers.authorization.split(' ')[1]
    }

    if (!token) {
      return next()
    }

    const { data: { user } } = await supabaseAdmin.auth.getUser(token)

    if (user) {
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single()

      req.user = user
      req.profile = profile
      req.token = token
    }

    next()
  } catch {
    next()
  }
}
