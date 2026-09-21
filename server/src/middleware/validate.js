/**
 * Validate request body against a Zod schema
 */
export const validateBody = (schema) => (req, res, next) => {
  try {
    req.body = schema.parse(req.body)
    next()
  } catch (err) {
    next(err)
  }
}

/**
 * Validate request query against a Zod schema
 */
export const validateQuery = (schema) => (req, res, next) => {
  try {
    req.query = schema.parse(req.query)
    next()
  } catch (err) {
    next(err)
  }
}

/**
 * Validate request params against a Zod schema
 */
export const validateParams = (schema) => (req, res, next) => {
  try {
    req.params = schema.parse(req.params)
    next()
  } catch (err) {
    next(err)
  }
}
