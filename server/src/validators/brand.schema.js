import { z } from 'zod'

export const brandQuerySchema = z.object({
  isActive: z.coerce.boolean().optional(),
  isFeatured: z.coerce.boolean().optional(),
})

export const createBrandSchema = z.object({
  name: z.string().min(2).max(100),
  slug: z.string().min(2).max(100).optional(),
  logo_url: z.string().url().optional().or(z.literal('')),
  banner_url: z.string().url().optional().or(z.literal('')),
  description: z.string().max(2000).optional(),
  website: z.string().url().optional().or(z.literal('')),
  country: z.string().max(100).optional(),
  is_active: z.boolean().default(true),
  is_featured: z.boolean().default(false),
  sort_order: z.coerce.number().int().default(0),
  meta_title: z.string().max(255).optional(),
  meta_description: z.string().max(500).optional(),
})

export const updateBrandSchema = createBrandSchema.partial()
