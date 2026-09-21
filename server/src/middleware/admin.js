import { ApiError } from '../utils/ApiError.js'

/**
 * Requires user to be admin.
 * Must be used AFTER requireAuth.
 */
export const requireAdmin = (req, res, next) => {
  if (!req.profile) {
    return next(ApiError.unauthorized('Authentication required'))
  }

  if (req.profile.role !== 'admin') {
    return next(ApiError.forbidden('Admin access required'))
  }

  next()
}

/**
 * Requires user to be admin or seller.
 */
export const requireSeller = (req, res, next) => {
  if (!req.profile) {
    return next(ApiError.unauthorized('Authentication required'))
  }

  if (!['admin', 'seller'].includes(req.profile.role)) {
    return next(ApiError.forbidden('Seller or admin access required'))
  }

  next()
}
