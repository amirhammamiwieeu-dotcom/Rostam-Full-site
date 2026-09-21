import { z } from 'zod'

export const createCheckoutSchema = z.object({
  order_id: z.string().uuid(),
})

export const refundSchema = z.object({
  amount: z.coerce.number().min(0.01),
  reason: z.string().max(500).optional(),
})