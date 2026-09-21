import { z } from 'zod'

export const trackViewSchema = z.object({
  product_id: z.string().uuid(),
  session_id: z.string().optional(),
  referrer: z.string().optional(),
})

export const trackSearchSchema = z.object({
  query: z.string().min(1).max(200),
  results_count: z.coerce.number().int().min(0).default(0),
  filters: z.record(z.any()).optional(),
  session_id: z.string().optional(),
})

export const dateRangeSchema = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  days: z.coerce.number().int().min(1).max(365).optional(),
})