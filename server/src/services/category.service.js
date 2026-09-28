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
 * 🆕 Get main categories only (parent_id = null) with their children
 */
export const getMainCategories = async () => {
  // Get all active categories
  const { data: all, error } = await supabaseAdmin
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('sort_order', { ascending: true })

  if (error) throw ApiError.badRequest(error.message)

  // Filter main + build children
  const mainCategories = (all || []).filter((c) => !c.parent_id)

  return mainCategories.map((main) => ({
    ...main,
    children: (all || [])
      .filter((c) => c.parent_id === main.id)
      .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0)),
  }))
}

/**
 * 🆕 Get category by slug + its children (for /category/:slug page)
 */
export const getCategoryWithChildren = async (slug) => {
  // Find the category
  const { data: category, error } = await supabaseAdmin
    .from('categories')
    .select('*')
    .eq('slug', slug)
    .eq('is_active', true)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!category) throw ApiError.notFound('Category not found')

  // Get children (subcategories)
  const { data: children } = await supabaseAdmin
    .from('categories')
    .select('*')
    .eq('parent_id', category.id)
    .eq('is_active', true)
    .order('sort_order', { ascending: true })

  // If this category itself has a parent, get its siblings too
  let siblings = []
  if (category.parent_id) {
    const { data: sib } = await supabaseAdmin
      .from('categories')
      .select('*')
      .eq('parent_id', category.parent_id)
      .eq('is_active', true)
      .order('sort_order', { ascending: true })
    siblings = sib || []
  }

  return {
    category,
    children: children || [],
    siblings,
    parent: category.parent_id
      ? await getCategoryById(category.parent_id)
      : null,
  }
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
