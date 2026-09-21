import { Router } from 'express'
import {
  listByProduct,
  ratingSummary,
  create,
  update,
  remove,
  vote,
  myComments,
} from '../controllers/comment.controller.js'
import { requireAuth, optionalAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import {
  createCommentSchema,
  updateCommentSchema,
  voteCommentSchema,
} from '../validators/comment.schema.js'

const router = Router()

// Public
router.get('/product/:productId', optionalAuth, listByProduct)
router.get('/product/:productId/summary', ratingSummary)

// Auth
router.post('/', requireAuth, validateBody(createCommentSchema), create)
router.put('/:id', requireAuth, validateBody(updateCommentSchema), update)
router.delete('/:id', requireAuth, remove)
router.post('/:id/vote', requireAuth, validateBody(voteCommentSchema), vote)
router.get('/my', requireAuth, myComments)

export default router