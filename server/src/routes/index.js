import { Router } from 'express'
import authRoutes from './auth.routes.js'
import productRoutes from './product.routes.js'
import categoryRoutes from './category.routes.js'
import brandRoutes from './brand.routes.js'

const router = Router()

// ============================================================
// Health check
// ============================================================
router.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'MarketHub API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  })
})

// ============================================================
// Routes
// ============================================================
router.use('/auth', authRoutes)
router.use('/products', productRoutes)
router.use('/categories', categoryRoutes)
router.use('/brands', brandRoutes)

// Coming next:
// router.use('/cart', cartRoutes)
// router.use('/wishlist', wishlistRoutes)
// router.use('/orders', orderRoutes)
// router.use('/payment', paymentRoutes)
// router.use('/comments', commentRoutes)
// router.use('/admin', adminRoutes)
// router.use('/ai', aiRoutes)

export default router
