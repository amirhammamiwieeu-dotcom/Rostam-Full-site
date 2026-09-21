import Stripe from 'stripe'
import dotenv from 'dotenv'

dotenv.config()

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('❌ Missing STRIPE_SECRET_KEY')
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-09-30.acacia',
  typescript: false,
})

console.log('✅ Stripe client initialized')
