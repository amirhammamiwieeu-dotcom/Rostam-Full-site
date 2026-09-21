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

const router = Router()

router.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'MarketHub API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  })
})

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

export default router