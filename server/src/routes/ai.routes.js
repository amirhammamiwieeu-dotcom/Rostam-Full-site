import { Router } from 'express'
import {
  generateProductDescription,
  smartSearchCtrl,
  chatCtrl,
  recommendCtrl,
  translateCtrl,
} from '../controllers/ai.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import {
  generateDescriptionSchema,
  smartSearchSchema,
  chatSchema,
  recommendSchema,
} from '../validators/ai.schema.js'

const router = Router()

// Public
router.post('/smart-search', validateBody(smartSearchSchema), smartSearchCtrl)
router.post('/chat', validateBody(chatSchema), chatCtrl)
router.post('/recommend', validateBody(recommendSchema), recommendCtrl)

// Admin only
router.post(
  '/generate-description',
  requireAuth,
  requireAdmin,
  validateBody(generateDescriptionSchema),
  generateProductDescription
)

router.post('/translate', requireAuth, requireAdmin, translateCtrl)

export default router