/**
 * Generate a random string
 */
export const generateRandomString = (length = 32) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  let result = ''
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

/**
 * Format currency
 */
export const formatCurrency = (amount, currency = 'USD') => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount)
}

/**
 * Generate order number
 * Format: MH-YYYYMMDD-XXXX
 */
export const generateOrderNumber = () => {
  const now = new Date()
  const date = now.toISOString().slice(0, 10).replace(/-/g, '')
  const random = Math.floor(1000 + Math.random() * 9000)
  return `MH-${date}-${random}`
}

/**
 * Sanitize user input (basic)
 */
export const sanitize = (str) => {
  if (typeof str !== 'string') return str
  return str.trim().replace(/[<>]/g, '')
}

/**
 * Sleep helper (for testing delays)
 */
export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

/**
 * Parse pagination params from query
 */
export const parsePagination = (query) => {
  const page = Math.max(1, parseInt(query.page) || 1)
  const limit = Math.min(100, Math.max(1, parseInt(query.limit) || 20))
  const offset = (page - 1) * limit
  return { page, limit, offset }
}

/**
 * Get client IP address
 */
export const getClientIp = (req) => {
  return (
    req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
    req.headers['x-real-ip'] ||
    req.socket?.remoteAddress ||
    'unknown'
  )
}

/**
 * Get user agent
 */
export const getUserAgent = (req) => {
  return req.headers['user-agent'] || 'unknown'
}

/**
 * Parse device info from user agent
 */
export const parseUserAgent = (ua) => {
  if (!ua || ua === 'unknown') {
    return { device: 'unknown', browser: 'unknown', os: 'unknown' }
  }

  let device = 'desktop'
  if (/mobile/i.test(ua)) device = 'mobile'
  if (/tablet|ipad/i.test(ua)) device = 'tablet'

  let browser = 'unknown'
  if (/chrome/i.test(ua) && !/edg/i.test(ua)) browser = 'Chrome'
  else if (/firefox/i.test(ua)) browser = 'Firefox'
  else if (/safari/i.test(ua) && !/chrome/i.test(ua)) browser = 'Safari'
  else if (/edg/i.test(ua)) browser = 'Edge'

  let os = 'unknown'
  if (/windows/i.test(ua)) os = 'Windows'
  else if (/mac/i.test(ua)) os = 'macOS'
  else if (/android/i.test(ua)) os = 'Android'
  else if (/iphone|ipad/i.test(ua)) os = 'iOS'
  else if (/linux/i.test(ua)) os = 'Linux'

  return { device, browser, os }
}
