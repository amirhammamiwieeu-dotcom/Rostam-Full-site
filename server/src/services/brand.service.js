import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

const generateSlug = (name) => {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
}

export const getBrands = async ({ isActive = true, isFeatured } = {}) => {
  let query = supabaseAdmin
    .from('brands')
    .select('*')
    .order('sort_order', { ascending: true })
    .order('name', { ascending: true })

  if (isActive !== undefined) query = query.eq('is_active', isActive)
  if (isFeatured !== undefined) query = query.eq('is_featured', isFeatured)

  const { data, error } = await query
  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

export const getBrandBySlug = async (slug) => {
  const { data, error } = await supabaseAdmin
    .from('brands')
    .select('*')
    .eq('slug', slug)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Brand not found')
  return data
}

export const createBrand = async (data) => {
  if (!data.slug) data.slug = generateSlug(data.name)

  const { data: brand, error } = await supabaseAdmin
    .from('brands')
    .insert(data)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return brand
}

export const updateBrand = async (id, data) => {
  data.updated_at = new Date().toISOString()

  const { data: brand, error } = await supabaseAdmin
    .from('brands')
    .update(data)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!brand) throw ApiError.notFound('Brand not found')
  return brand
}

export const deleteBrand = async (id) => {
  const { error } = await supabaseAdmin.from('brands').delete().eq('id', id)
  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}
