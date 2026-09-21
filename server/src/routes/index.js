import { Router } from 'express'
import authRoutes from './auth.routes.js'
import productRoutes from './product.routes.js'
import categoryRoutes from './category.routes.js'
import brandRoutes from './brand.routes.js'
import cartRoutes from './cart.routes.js'
import wishlistRoutes from './wishlist.routes.js'
import compareRoutes from './compare.routes.js'
import couponRoutes from './coupon.routes.js'
import orderRoutes from './order.routes.js'
import paymentRoutes from './payment.routes.js'
import commentRoutes from './comment.routes.js'
import adminRoutes from './admin.routes.js'
import aiRoutes from './ai.routes.js'
import uploadRoutes from './upload.routes.js'
import analyticsRoutes from './analytics.routes.js'

const router = Router()

// Health
router.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'MarketHub API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  })
})

// Routes
router.use('/auth', authRoutes)
router.use('/products', productRoutes)
router.use('/categories', categoryRoutes)
router.use('/brands', brandRoutes)
router.use('/cart', cartRoutes)
router.use('/wishlist', wishlistRoutes)
router.use('/compare', compareRoutes)
router.use('/coupons', couponRoutes)
router.use('/orders', orderRoutes)
router.use('/payment', paymentRoutes)
router.use('/comments', commentRoutes)
router.use('/admin', adminRoutes)
router.use('/ai', aiRoutes)
router.use('/upload', uploadRoutes)
router.use('/analytics', analyticsRoutes)

export default router