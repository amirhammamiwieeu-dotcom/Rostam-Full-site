import { Router } from 'express'
import { list, add, remove, clear } from '../controllers/compare.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import { addCompareSchema } from '../validators/compare.schema.js'

const router = Router()

router.use(requireAuth)

router.get('/', list)
router.post('/', validateBody(addCompareSchema), add)
router.delete('/:productId', remove)
router.delete('/', clear)

export default router
