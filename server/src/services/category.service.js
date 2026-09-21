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

/**
 * Get all categories (flat or tree)
 */
export const getCategories = async ({ parent, isActive = true, isFeatured, tree = false } = {}) => {
  let query = supabaseAdmin
    .from('categories')
    .select('*')
    .order('sort_order', { ascending: true })

  if (isActive !== undefined) query = query.eq('is_active', isActive)
  if (isFeatured !== undefined) query = query.eq('is_featured', isFeatured)
  if (parent !== undefined) {
    if (parent === null) query = query.is('parent_id', null)
    else query = query.eq('parent_id', parent)
  }

  const { data, error } = await query
  if (error) throw ApiError.badRequest(error.message)

  if (!tree) return data || []

  // Build tree
  return buildTree(data || [])
}

/**
 * Build category tree from flat list
 */
const buildTree = (categories, parentId = null) => {
  return categories
    .filter((c) => c.parent_id === parentId)
    .map((c) => ({
      ...c,
      children: buildTree(categories, c.id),
    }))
}

/**
 * Get category by slug
 */
export const getCategoryBySlug = async (slug) => {
  const { data, error } = await supabaseAdmin
    .from('categories')
    .select('*')
    .eq('slug', slug)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Category not found')
  return data
}

/**
 * Get category by ID
 */
export const getCategoryById = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('categories')
    .select('*')
    .eq('id', id)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Category not found')
  return data
}

/**
 * Create category (admin)
 */
export const createCategory = async (data) => {
  if (!data.slug) data.slug = generateSlug(data.name)

  const { data: category, error } = await supabaseAdmin
    .from('categories')
    .insert(data)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return category
}

/**
 * Update category (admin)
 */
export const updateCategory = async (id, data) => {
  data.updated_at = new Date().toISOString()

  const { data: category, error } = await supabaseAdmin
    .from('categories')
    .update(data)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!category) throw ApiError.notFound('Category not found')
  return category
}

/**
 * Delete category (admin)
 */
export const deleteCategory = async (id) => {
  // Check for subcategories
  const { count } = await supabaseAdmin
    .from('categories')
    .select('*', { count: 'exact', head: true })
    .eq('parent_id', id)

  if (count > 0) {
    throw ApiError.badRequest('Cannot delete category with subcategories')
  }

  const { error } = await supabaseAdmin.from('categories').delete().eq('id', id)
  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}
