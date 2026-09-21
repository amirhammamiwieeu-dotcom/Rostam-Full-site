import { z } from 'zod'

export const createCouponSchema = z.object({
  code: z.string().min(3).max(50),
  description: z.string().max(255).optional(),
  discount_type: z.enum(['percent', 'fixed', 'free_shipping']),
  discount_value: z.coerce.number().min(0),
  min_order: z.coerce.number().min(0).default(0),
  max_discount: z.coerce.number().min(0).optional().nullable(),
  max_uses: z.coerce.number().int().min(1).optional().nullable(),
  max_uses_per_user: z.coerce.number().int().min(1).default(1),
  applies_to: z.enum(['all', 'category', 'product', 'brand']).default('all'),
  category_ids: z.array(z.string().uuid()).default([]),
  product_ids: z.array(z.string().uuid()).default([]),
  brand_ids: z.array(z.string().uuid()).default([]),
  first_order_only: z.boolean().default(false),
  is_active: z.boolean().default(true),
  is_public: z.boolean().default(true),
  starts_at: z.string().datetime().optional(),
  expires_at: z.string().datetime().optional().nullable(),
})

export const updateCouponSchema = createCouponSchema.partial()
