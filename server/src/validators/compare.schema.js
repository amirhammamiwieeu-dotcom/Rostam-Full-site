import { z } from 'zod'

export const addCompareSchema = z.object({
  product_id: z.string().uuid('Invalid product ID'),
})
