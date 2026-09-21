import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import rateLimit from 'express-rate-limit'
import dotenv from 'dotenv'

// Config (initializes clients on import)
import './src/config/supabase.js'
import './src/config/stripe.js'
import './src/config/resend.js'
import './src/config/gemini.js'

// Middleware
import { notFound, errorHandler } from './src/middleware/error.js'

// Routes
import routes from './src/routes/index.js'

dotenv.config()

const app = express()

// ============================================================
// SECURITY
// ============================================================
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}))

app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}))

// ============================================================
// RATE LIMITING
// ============================================================
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  message: {
    success: false,
    message: 'Too many requests. Please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
})

app.use('/api', limiter)

// ============================================================
// BODY PARSER
// ============================================================
// Raw body for Stripe webhook
app.use('/api/payment/webhook', express.raw({ type: 'application/json' }))

// JSON for everything else
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// ============================================================
// LOGGER
// ============================================================
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'))
}

// ============================================================
// ROUTES
// ============================================================
app.use('/api', routes)

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to MarketHub API 🛒',
    docs: '/api/health',
    version: '1.0.0',
  })
})

// ============================================================
// ERROR HANDLING
// ============================================================
app.use(notFound)
app.use(errorHandler)

// ============================================================
// START
// ============================================================
const PORT = process.env.PORT || 5000

const server = app.listen(PORT, () => {
  console.log('')
  console.log('🛒 ═══════════════════════════════════════')
  console.log('   MarketHub API Server')
  console.log('🛒 ═══════════════════════════════════════')
  console.log(`   📡 Server:      http://localhost:${PORT}`)
  console.log(`   🌍 Environment: ${process.env.NODE_ENV}`)
  console.log(`   ✅ Health:      http://localhost:${PORT}/api/health`)
  console.log('🛒 ═══════════════════════════════════════')
  console.log('')
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down...')
  server.close(() => {
    console.log('Server closed')
    process.exit(0)
  })
})

process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Rejection:', err)
  server.close(() => process.exit(1))
})

export default app
