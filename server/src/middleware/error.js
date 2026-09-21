import { ApiError } from '../utils/ApiError.js'

/**
 * 404 handler — for unmatched routes
 */
export const notFound = (req, res, next) => {
  next(ApiError.notFound(`Route ${req.originalUrl} not found`))
}

/**
 * Global error handler
 */
export const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500
  let message = err.message || 'Internal server error'
  let details = err.details || null

  // Log in development
  if (process.env.NODE_ENV === 'development') {
    console.error('❌ Error:', {
      message: err.message,
      statusCode,
      path: req.originalUrl,
    })
  }

  // Supabase not found
  if (err.code === 'PGRST116') {
    statusCode = 404
    message = 'Resource not found'
  }

  // Zod validation errors
  if (err.name === 'ZodError') {
    statusCode = 400
    message = 'Validation failed'
    details = err.errors.map((e) => ({
      field: e.path.join('.'),
      message: e.message,
    }))
  }

  // PostgreSQL unique violation
  if (err.code === '23505') {
    statusCode = 409
    message = 'Resource already exists'
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401
    message = 'Invalid token'
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401
    message = 'Token expired'
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(details && { details }),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  })
}
