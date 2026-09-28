import { z } from 'zod'

export const createOrderSchema = z.object({
  shipping_address: z.object({
    full_name: z.string().min(2, 'Name too short'),
    email: z.string().optional().or(z.literal('')),
    phone: z.string().min(5, 'Phone too short'),
    address_line1: z.string().min(3, 'Address too short'),
    address_line2: z.string().optional().or(z.literal('')),
    city: z.string().min(2, 'City too short'),
    state: z.string().optional().or(z.literal('')),
    country: z.string().optional().or(z.literal('US')),
    zip: z.string().min(3, 'ZIP too short'),
  }),
  billing_address: z.any().optional(),
  shipping_method: z.string().default('standard'),
  customer_note: z.string().max(500).optional(),
  coupon_code: z.string().optional(),
  customer_email: z.string().optional(),
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
  tracking_url: z.string().optional(),
  note: z.string().max(500).optional(),
})
