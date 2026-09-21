import { Router } from 'express'
import {
  uploadSingle,
  uploadMultiple,
  removeFile,
} from '../controllers/upload.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { upload } from '../middleware/upload.js'

const router = Router()

router.post(
  '/image',
  requireAuth,
  requireAdmin,
  upload.single('file'),
  uploadSingle
)

router.post(
  '/images',
  requireAuth,
  requireAdmin,
  upload.array('files', 10),
  uploadMultiple
)

router.delete('/file', requireAuth, requireAdmin, removeFile)

export default router