import { z } from 'zod'

export const addToCartSchema = z.object({
  product_id: z.string().uuid('Invalid product ID'),
  variant_id: z.string().uuid().optional().nullable(),
  quantity: z.coerce.number().int().min(1).max(99).default(1),
})

export const updateCartItemSchema = z.object({
  quantity: z.coerce.number().int().min(1).max(99),
})

export const applyCouponSchema = z.object({
  code: z.string().min(1).max(50),
})
