import { Router } from 'express'
import {
  publicList,
  adminList,
  create,
  update,
  remove,
} from '../controllers/coupon.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import {
  createCouponSchema,
  updateCouponSchema,
} from '../validators/coupon.schema.js'

const router = Router()

// Public — list active public coupons
router.get('/public', publicList)

// Admin
router.get('/', requireAuth, requireAdmin, adminList)
router.post('/', requireAuth, requireAdmin, validateBody(createCouponSchema), create)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateCouponSchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)

export default router
