import { z } from 'zod'

export const createCommentSchema = z.object({
  product_id: z.string().uuid(),
  rating: z.coerce.number().int().min(1).max(5),
  title: z.string().max(150).optional(),
  text: z.string().min(5).max(2000),
  images: z.array(z.string().url()).max(5).optional(),
})

export const updateCommentSchema = z.object({
  rating: z.coerce.number().int().min(1).max(5).optional(),
  title: z.string().max(150).optional(),
  text: z.string().min(5).max(2000).optional(),
})

export const voteCommentSchema = z.object({
  vote: z.enum(['helpful', 'not_helpful']),
})

export const adminReplySchema = z.object({
  admin_reply: z.string().min(1).max(1000),
})