import { z } from 'zod'

export const toggleWishlistSchema = z.object({
  product_id: z.string().uuid('Invalid product ID'),
})
