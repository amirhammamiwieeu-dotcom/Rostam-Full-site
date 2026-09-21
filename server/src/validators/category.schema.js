import { z } from 'zod'

export const categoryQuerySchema = z.object({
  parent: z.string().uuid().optional(),
  isActive: z.coerce.boolean().optional(),
  isFeatured: z.coerce.boolean().optional(),
  tree: z.coerce.boolean().optional(), // return nested tree
})

export const createCategorySchema = z.object({
  name: z.string().min(2).max(100),
  slug: z.string().min(2).max(100).optional(),
  description: z.string().max(1000).optional(),
  icon: z.string().max(100).optional(),
  image_url: z.string().url().optional().or(z.literal('')),
  banner_url: z.string().url().optional().or(z.literal('')),
  parent_id: z.string().uuid().optional().nullable(),
  sort_order: z.coerce.number().int().default(0),
  is_active: z.boolean().default(true),
  is_featured: z.boolean().default(false),
  meta_title: z.string().max(255).optional(),
  meta_description: z.string().max(500).optional(),
})

export const updateCategorySchema = createCategorySchema.partial()
