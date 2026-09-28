import { z } from 'zod'

export const generateDescriptionSchema = z.object({
  title: z.string().min(3).max(255),
  features: z.array(z.string()).optional().default([]),
  category: z.string().optional(),
  brand: z.string().optional(),
  tone: z.enum(['professional', 'casual', 'luxury', 'friendly']).default('professional'),
})

export const smartSearchSchema = z.object({
  query: z.string().min(2).max(200),
})

export const chatSchema = z.object({
  message: z.string().min(1).max(1000),
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        content: z.string(),
      })
    )
    .optional()
    .default([]),
})

export const recommendSchema = z.object({
  product_id: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(20).default(6),
})

export const compareSchema = z.object({
  product_ids: z
    .array(z.string().uuid())
    .min(2, 'At least 2 products required')
    .max(4, 'Maximum 4 products'),
})
