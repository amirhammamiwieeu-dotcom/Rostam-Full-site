import { Router } from 'express'
import {
  dashboard,
  users,
  updateUserCtrl,
  orders,
  comments,
  approveComment,
  salesReport,
  lowStock,
} from '../controllers/admin.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'

const router = Router()

router.use(requireAuth, requireAdmin)

router.get('/dashboard', dashboard)
router.get('/users', users)
router.put('/users/:id', updateUserCtrl)
router.get('/orders', orders)
router.get('/comments', comments)
router.put('/comments/:id/approve', approveComment)
router.get('/reports/sales', salesReport)
router.get('/reports/low-stock', lowStock)

export default router