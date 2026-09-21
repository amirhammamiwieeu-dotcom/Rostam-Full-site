import { Router } from 'express'
import { create, list, getOne, cancel, adminUpdateStatus } from '../controllers/order.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import { createOrderSchema, updateOrderStatusSchema } from '../validators/order.schema.js'

const router = Router()

router.use(requireAuth)

router.post('/', validateBody(createOrderSchema), create)
router.get('/', list)
router.get('/:id', getOne)
router.put('/:id/cancel', cancel)

// Admin
router.put('/:id/status', requireAdmin, validateBody(updateOrderStatusSchema), adminUpdateStatus)

export default router