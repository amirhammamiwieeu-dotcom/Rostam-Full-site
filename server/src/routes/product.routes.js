import { Router } from 'express'
import {
  list,
  getOne,
  getBySlug,
  related,
  featured,
  newArrivals,
  bestSellers,
  search,
  create,
  update,
  remove,
} from '../controllers/product.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody, validateQuery } from '../middleware/validate.js'
import {
  productQuerySchema,
  createProductSchema,
  updateProductSchema,
} from '../validators/product.schema.js'

const router = Router()

// ============================================================
// Public routes
// ============================================================
router.get('/', validateQuery(productQuerySchema), list)
router.get('/featured', featured)
router.get('/new', newArrivals)
router.get('/best-sellers', bestSellers)
router.get('/search', search)
router.get('/slug/:slug', getBySlug)
router.get('/:id', getOne)
router.get('/:id/related', related)

// ============================================================
// Admin routes
// ============================================================
router.post('/', requireAuth, requireAdmin, validateBody(createProductSchema), create)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateProductSchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)

export default router
