import { Router } from 'express'
import {
  list,
  getBySlug,
  create,
  update,
  remove,
} from '../controllers/brand.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody, validateQuery } from '../middleware/validate.js'
import {
  brandQuerySchema,
  createBrandSchema,
  updateBrandSchema,
} from '../validators/brand.schema.js'

const router = Router()

// Public
router.get('/', validateQuery(brandQuerySchema), list)
router.get('/slug/:slug', getBySlug)

// Admin
router.post('/', requireAuth, requireAdmin, validateBody(createBrandSchema), create)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateBrandSchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)

export default router
