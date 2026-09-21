import { Router } from 'express'
import { list, toggle, clear } from '../controllers/wishlist.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { validateBody } from '../middleware/validate.js'
import { toggleWishlistSchema } from '../validators/wishlist.schema.js'

const router = Router()

router.use(requireAuth)

router.get('/', list)
router.post('/toggle', validateBody(toggleWishlistSchema), toggle)
router.delete('/', clear)

export default router
