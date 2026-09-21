import { Router } from 'express'
import {
  list,
  getBySlug,
  getOne,
  create,
  update,
  remove,
} from '../controllers/category.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody, validateQuery } from '../middleware/validate.js'
import {
  categoryQuerySchema,
  createCategorySchema,
  updateCategorySchema,
} from '../validators/category.schema.js'

const router = Router()

// Public
router.get('/', validateQuery(categoryQuerySchema), list)
router.get('/slug/:slug', getBySlug)
router.get('/:id', getOne)

// Admin
router.post('/', requireAuth, requireAdmin, validateBody(createCategorySchema), create)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateCategorySchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)

export default router
