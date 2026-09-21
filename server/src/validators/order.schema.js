import { z } from 'zod'

export const createOrderSchema = z.object({
  shipping_address: z.object({
    full_name: z.string().min(2),
    phone: z.string().min(10),
    address_line1: z.string().min(5),
    address_line2: z.string().optional(),
    city: z.string().min(2),
    state: z.string().optional(),
    country: z.string().default('US'),
    zip: z.string().min(3),
  }),
  billing_address: z.object({
    full_name: z.string().min(2),
    phone: z.string().min(10),
    address_line1: z.string().min(5),
    address_line2: z.string().optional(),
    city: z.string().min(2),
    state: z.string().optional(),
    country: z.string().default('US'),
    zip: z.string().min(3),
  }).optional(),
  shipping_method: z.string().default('standard'),
  customer_note: z.string().max(500).optional(),
  coupon_code: z.string().optional(),
})

export const updateOrderStatusSchema = z.object({
  status: z.enum([
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'returned',
    'refunded',
  ]),
  tracking_number: z.string().optional(),
  tracking_url: z.string().url().optional(),
  note: z.string().max(500).optional(),
})