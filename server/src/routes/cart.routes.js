import { Router } from 'express'
import {
  get,
  add,
  update,
  remove,
  clear,
  validateStock,
  applyCoupon,
} from '../controllers/cart.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import {
  addToCartSchema,
  updateCartItemSchema,
  applyCouponSchema,
} from '../validators/cart.schema.js'

const router = Router()

// All routes require auth
router.use(requireAuth)

router.get('/', get)
router.post('/add', validateBody(addToCartSchema), add)
router.put('/items/:id', validateBody(updateCartItemSchema), update)
router.delete('/items/:id', remove)
router.delete('/', clear)
router.post('/validate', validateStock)
router.post('/coupon', validateBody(applyCouponSchema), applyCoupon)

export default router
