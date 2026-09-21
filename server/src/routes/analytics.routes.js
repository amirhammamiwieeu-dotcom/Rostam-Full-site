import { Router } from 'express'
import {
  trackView,
  trackSearchCtrl,
  recentlyViewed,
  trendingSearches,
  topViewed,
} from '../controllers/analytics.controller.js'
import { requireAuth, optionalAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody } from '../middleware/validate.js'
import {
  trackViewSchema,
  trackSearchSchema,
} from '../validators/analytics.schema.js'

const router = Router()

// Public tracking (auth optional)
router.post('/view', optionalAuth, validateBody(trackViewSchema), trackView)
router.post('/search', optionalAuth, validateBody(trackSearchSchema), trackSearchCtrl)
router.get('/trending', trendingSearches)

// Auth
router.get('/recently-viewed', requireAuth, recentlyViewed)

// Admin
router.get('/top-viewed', requireAuth, requireAdmin, topViewed)

export default router