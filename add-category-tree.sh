#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🔧 Adding category tree endpoint..."
echo ""

cp src/services/category.service.js src/services/category.service.js.backup-$(date +%s) 2>/dev/null || true
cp src/controllers/category.controller.js src/controllers/category.controller.js.backup-$(date +%s) 2>/dev/null || true
cp src/routes/category.routes.js src/routes/category.routes.js.backup-$(date +%s) 2>/dev/null || true

# ============================================================
# 1. category.service.js — اضافه کردن getCategoryTree
# ============================================================
cat > src/services/category.service.js << 'ENDOFFILE'
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
ENDOFFILE

echo "✅ category.service.js updated"

# ============================================================
# 2. category.controller.js — اضافه کردن main + withChildren
# ============================================================
cat > src/controllers/category.controller.js << 'ENDOFFILE'
import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getCategories,
  getCategoryBySlug,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getMainCategories,
  getCategoryWithChildren,
} from '../services/category.service.js'

export const list = asyncHandler(async (req, res) => {
  const { parent, isActive, isFeatured, tree } = req.query
  const categories = await getCategories({
    parent: parent || undefined,
    isActive: isActive !== 'false',
    isFeatured: isFeatured === 'true' ? true : undefined,
    tree: tree === 'true',
  })
  return ApiResponse.success(res, { categories }, 'Categories retrieved')
})

// 🆕 Main categories with children
export const mainList = asyncHandler(async (req, res) => {
  const categories = await getMainCategories()
  return ApiResponse.success(res, { categories }, 'Main categories retrieved')
})

// 🆕 Category with children (for /category/:slug)
export const withChildren = asyncHandler(async (req, res) => {
  const result = await getCategoryWithChildren(req.params.slug)
  return ApiResponse.success(res, result, 'Category retrieved')
})

export const getBySlug = asyncHandler(async (req, res) => {
  const category = await getCategoryBySlug(req.params.slug)
  return ApiResponse.success(res, { category }, 'Category retrieved')
})

export const getOne = asyncHandler(async (req, res) => {
  const category = await getCategoryById(req.params.id)
  return ApiResponse.success(res, { category }, 'Category retrieved')
})

export const create = asyncHandler(async (req, res) => {
  const category = await createCategory(req.body)
  return ApiResponse.created(res, { category }, 'Category created')
})

export const update = asyncHandler(async (req, res) => {
  const category = await updateCategory(req.params.id, req.body)
  return ApiResponse.success(res, { category }, 'Category updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteCategory(req.params.id)
  return ApiResponse.success(res, null, 'Category deleted')
})
ENDOFFILE

echo "✅ category.controller.js updated"

# ============================================================
# 3. category.routes.js — اضافه کردن routes جدید
# ============================================================
cat > src/routes/category.routes.js << 'ENDOFFILE'
import { Router } from 'express'
import {
  list,
  mainList,
  withChildren,
  getBySlug,
  getOne,
  create,
  update,
  remove,
} from '../controllers/category.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody, validateQuery } from '../middleware/validate.js'
import {
  categoryQuerySchema,
  createCategorySchema,
  updateCategorySchema,
} from '../validators/category.schema.js'

const router = Router()

// Public
router.get('/', validateQuery(categoryQuerySchema), list)
router.get('/main', mainList)                       // 🆕 Main + children
router.get('/:slug/with-children', withChildren)    // 🆕 Category + children
router.get('/slug/:slug', getBySlug)
router.get('/:id', getOne)

// Admin
router.post('/', requireAuth, requireAdmin, validateBody(createCategorySchema), create)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateCategorySchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)

export default router
ENDOFFILE

echo "✅ category.routes.js updated"
echo ""
echo "🎉 Backend done!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Backend terminal"
echo "   2. cd ~/Rostam-Full-site/server"
echo "   3. npm run dev"
echo ""
echo "🧪 Test:"
echo "   curl -s http://localhost:5000/api/categories/main | python -m json.tool | head -40"
echo ""
