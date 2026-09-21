/**
 * Wraps async route handlers to catch errors automatically.
 * So we don't need try/catch in every controller.
 */
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next)
}
