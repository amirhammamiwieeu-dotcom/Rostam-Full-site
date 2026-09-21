import { z } from 'zod'

// ============================================================
// List/Query
// ============================================================
export const productQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  category: z.string().optional(),
  brand: z.string().optional(),
  q: z.string().optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
  rating: z.coerce.number().min(0).max(5).optional(),
  prime: z.coerce.boolean().optional(),
  inStock: z.coerce.boolean().optional(),
  sort: z
    .enum(['featured', 'price-asc', 'price-desc', 'rating', 'newest', 'discount', 'popular'])
    .default('featured'),
})

// ============================================================
// Create
// ============================================================
export const createProductSchema = z.object({
  title: z.string().min(3).max(255),
  slug: z.string().min(3).max(255).optional(),
  sku: z.string().optional(),
  barcode: z.string().optional(),
  description: z.string().optional(),
  short_description: z.string().max(500).optional(),
  highlights: z.array(z.string()).optional(),

  price: z.coerce.number().min(0),
  old_price: z.coerce.number().min(0).optional(),
  cost_price: z.coerce.number().min(0).optional(),
  discount: z.coerce.number().int().min(0).max(100).optional(),

  stock: z.coerce.number().int().min(0).default(0),
  low_stock_threshold: z.coerce.number().int().min(0).default(5),
  track_inventory: z.boolean().default(true),
  allow_backorder: z.boolean().default(false),

  category_id: z.string().uuid().optional().nullable(),
  brand_id: z.string().uuid().optional().nullable(),
  seller_id: z.string().uuid().optional().nullable(),

  thumbnail: z.string().url().optional(),
  images: z.array(z.string().url()).optional(),
  video_url: z.string().url().optional(),

  features: z.array(z.string()).optional(),
  specifications: z.record(z.any()).optional(),

  is_active: z.boolean().default(true),
  is_featured: z.boolean().default(false),
  is_new: z.boolean().default(false),
  is_prime: z.boolean().default(false),
  status: z.enum(['draft', 'published', 'archived']).default('published'),

  meta_title: z.string().max(255).optional(),
  meta_description: z.string().max(500).optional(),
  meta_keywords: z.string().optional(),

  weight: z.coerce.number().min(0).optional(),
  dimensions: z.record(z.any()).optional(),
  free_shipping: z.boolean().default(false),

  tax_class: z.string().optional(),
  tax_rate: z.coerce.number().min(0).optional(),
})

// ============================================================
// Update (all optional)
// ============================================================
export const updateProductSchema = createProductSchema.partial()

// ============================================================
// ID param
// ============================================================
export const idParamSchema = z.object({
  id: z.string().uuid('Invalid ID format'),
})

export const slugParamSchema = z.object({
  slug: z.string().min(1),
})
