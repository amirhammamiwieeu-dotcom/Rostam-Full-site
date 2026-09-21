import { Resend } from 'resend'
import dotenv from 'dotenv'

dotenv.config()

if (!process.env.RESEND_API_KEY) {
  throw new Error('❌ Missing RESEND_API_KEY')
}

export const resend = new Resend(process.env.RESEND_API_KEY)

export const FROM_EMAIL = process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev'
export const FROM_NAME = process.env.RESEND_FROM_NAME || 'MarketHub'

console.log('✅ Resend client initialized')
