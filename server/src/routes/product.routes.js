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
  adminList,
  create,
  update,
  remove,
  toggleActive,
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

// ============================================================
// Admin routes (must be before /:id)
// ============================================================
router.get('/admin/list', requireAuth, requireAdmin, adminList)
router.post('/', requireAuth, requireAdmin, validateBody(createProductSchema), create)

// ============================================================
// Dynamic routes (must be after specific routes)
// ============================================================
router.get('/:id', getOne)
router.get('/:id/related', related)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateProductSchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)
router.patch('/:id/toggle-active', requireAuth, requireAdmin, toggleActive)

export default router
