#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Fixing everything (backend + frontend)..."
echo ""

# ============================================================
# BACKEND
# ============================================================
cd "$SCRIPT_DIR/server"

echo "📦 [1/3] Updating product.service.js..."

cp src/services/product.service.js src/services/product.service.js.backup-$(date +%s) 2>/dev/null || true

# Replace entire file with clean version
cat > src/services/product.service.js << 'ENDOFFILE'
import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'

// ============================================================
// Helpers
// ============================================================
const generateSlug = (str) => {
  return String(str)
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
}

const findOrCreateBrand = async (brandName) => {
  if (!brandName || !String(brandName).trim()) return null

  const name = String(brandName).trim()
  const slug = generateSlug(name)

  const { data: bySlug } = await supabaseAdmin
    .from('brands')
    .select('id')
    .eq('slug', slug)
    .maybeSingle()

  if (bySlug?.id) return bySlug.id

  const { data: byName } = await supabaseAdmin
    .from('brands')
    .select('id')
    .ilike('name', name)
    .maybeSingle()

  if (byName?.id) return byName.id

  const { data: created, error } = await supabaseAdmin
    .from('brands')
    .insert({ name, slug, is_active: true })
    .select('id')
    .single()

  if (error) {
    console.error('❌ Failed to create brand:', error.message)
    return null
  }

  console.log(`✨ Created brand: ${name}`)
  return created.id
}

const normalizeProductPayload = async (data) => {
  const out = { ...data }

  if ('brand_name' in out) {
    if (out.brand_name && String(out.brand_name).trim()) {
      out.brand_id = await findOrCreateBrand(out.brand_name)
    } else {
      out.brand_id = null
    }
    delete out.brand_name
  }

  if (!out.slug && out.title) {
    out.slug = generateSlug(out.title) + '-' + Date.now().toString(36)
  }

  if (out.old_price && out.price && Number(out.old_price) > Number(out.price)) {
    out.discount = Math.round(
      (1 - Number(out.price) / Number(out.old_price)) * 100
    )
  }

  if (out.features && !Array.isArray(out.features)) {
    out.features = []
  }

  return out
}

// ============================================================
// Get products (public — only active + published)
// ============================================================
export const getProducts = async (query) => {
  const {
    page = 1,
    limit = 20,
    category,
    brand,
    q,
    minPrice,
    maxPrice,
    rating,
    prime,
    inStock,
    sort = 'featured',
  } = query

  const offset = (page - 1) * limit

  let queryBuilder = supabaseAdmin
    .from('products')
    .select(
      `
      id, title, slug, price, old_price, discount,
      thumbnail, images, rating, num_reviews, sold_count,
      stock, is_prime, is_featured, is_new, free_shipping,
      category_id, brand_id,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url)
    `,
      { count: 'exact' }
    )
    .eq('is_active', true)
    .eq('status', 'published')

  if (category) {
    const { data: cat } = await supabaseAdmin
      .from('categories')
      .select('id')
      .eq('slug', category)
      .maybeSingle()
    if (cat) queryBuilder = queryBuilder.eq('category_id', cat.id)
  }

  if (brand) {
    const { data: b } = await supabaseAdmin
      .from('brands')
      .select('id')
      .eq('slug', brand)
      .maybeSingle()
    if (b) queryBuilder = queryBuilder.eq('brand_id', b.id)
  }

  if (q) {
    queryBuilder = queryBuilder.or(
      `title.ilike.%${q}%,description.ilike.%${q}%,sku.ilike.%${q}%`
    )
  }

  if (minPrice !== undefined && minPrice !== '') {
    queryBuilder = queryBuilder.gte('price', Number(minPrice))
  }
  if (maxPrice !== undefined && maxPrice !== '') {
    queryBuilder = queryBuilder.lte('price', Number(maxPrice))
  }

  if (rating !== undefined && rating !== '' && Number(rating) > 0) {
    queryBuilder = queryBuilder.gte('rating', Number(rating))
  }

  if (prime === true || prime === 'true') {
    queryBuilder = queryBuilder.eq('is_prime', true)
  }

  if (inStock === true || inStock === 'true') {
    queryBuilder = queryBuilder.gt('stock', 0)
  }

  switch (sort) {
    case 'price-asc':
      queryBuilder = queryBuilder.order('price', { ascending: true })
      break
    case 'price-desc':
      queryBuilder = queryBuilder.order('price', { ascending: false })
      break
    case 'rating':
      queryBuilder = queryBuilder.order('rating', { ascending: false })
      break
    case 'newest':
      queryBuilder = queryBuilder.order('created_at', { ascending: false })
      break
    case 'discount':
      queryBuilder = queryBuilder.order('discount', { ascending: false })
      break
    case 'popular':
      queryBuilder = queryBuilder.order('sold_count', { ascending: false })
      break
    case 'featured':
    default:
      queryBuilder = queryBuilder
        .order('is_featured', { ascending: false })
        .order('rating', { ascending: false })
  }

  queryBuilder = queryBuilder.range(offset, offset + limit - 1)

  const { data, error, count } = await queryBuilder

  if (error) throw ApiError.badRequest(error.message)

  return {
    products: data || [],
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: count || 0,
      pages: Math.ceil((count || 0) / Number(limit)),
      hasMore: offset + Number(limit) < (count || 0),
    },
  }
}

// ============================================================
// Get ADMIN products (all — active + inactive)
// ============================================================
export const getAdminProducts = async (query = {}) => {
  const {
    page = 1,
    limit = 200,
    q,
    status,
    filter,
  } = query

  const offset = (page - 1) * limit

  let queryBuilder = supabaseAdmin
    .from('products')
    .select(
      `
      id, title, slug, price, old_price, discount,
      thumbnail, images, rating, num_reviews, sold_count,
      stock, is_prime, is_featured, is_new, free_shipping,
      is_active, status, created_at, updated_at,
      category_id, brand_id,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url)
    `,
      { count: 'exact' }
    )

  // Filter by active/inactive
  if (filter === 'active') {
    queryBuilder = queryBuilder.eq('is_active', true)
  } else if (filter === 'inactive') {
    queryBuilder = queryBuilder.eq('is_active', false)
  }

  if (q) {
    queryBuilder = queryBuilder.or(
      `title.ilike.%${q}%,description.ilike.%${q}%`
    )
  }

  if (status) {
    queryBuilder = queryBuilder.eq('status', status)
  }

  queryBuilder = queryBuilder
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  const { data, error, count } = await queryBuilder

  if (error) throw ApiError.badRequest(error.message)

  return {
    products: data || [],
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: count || 0,
      pages: Math.ceil((count || 0) / Number(limit)),
    },
  }
}

// ============================================================
// Get by ID
// ============================================================
export const getProductById = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      `
      *,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url),
      seller:profiles(id, full_name, avatar_url)
    `
    )
    .eq('id', id)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return data
}

// ============================================================
// Get by slug
// ============================================================
export const getProductBySlug = async (slug) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      `
      *,
      category:categories(id, name, slug),
      brand:brands(id, name, slug, logo_url),
      seller:profiles(id, full_name, avatar_url)
    `
    )
    .eq('slug', slug)
    .eq('is_active', true)
    .maybeSingle()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return data
}

// ============================================================
// Related
// ============================================================
export const getRelatedProducts = async (productId, limit = 8) => {
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('category_id')
    .eq('id', productId)
    .maybeSingle()

  if (!product?.category_id) return []

  const { data } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('category_id', product.category_id)
    .neq('id', productId)
    .eq('is_active', true)
    .limit(limit)

  return data || []
}

// ============================================================
// Featured
// ============================================================
export const getFeaturedProducts = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('is_active', true)
    .eq('is_featured', true)
    .order('rating', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// New arrivals
// ============================================================
export const getNewArrivals = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, is_prime, stock'
    )
    .eq('is_active', true)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Best sellers
// ============================================================
export const getBestSellers = async (limit = 12) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select(
      'id, title, slug, price, old_price, discount, thumbnail, images, rating, num_reviews, sold_count, is_prime, stock'
    )
    .eq('is_active', true)
    .order('sold_count', { ascending: false })
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Search
// ============================================================
export const searchProducts = async (q, limit = 10) => {
  if (!q || q.trim().length < 2) return []

  const { data, error } = await supabaseAdmin
    .from('products')
    .select('id, title, slug, price, thumbnail, rating, stock')
    .eq('is_active', true)
    .ilike('title', `%${q}%`)
    .limit(limit)

  if (error) throw ApiError.badRequest(error.message)
  return data || []
}

// ============================================================
// Create product
// ============================================================
export const createProduct = async (data) => {
  const payload = await normalizeProductPayload(data)

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .insert(payload)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return product
}

// ============================================================
// Update product
// ============================================================
export const updateProduct = async (id, data) => {
  const payload = await normalizeProductPayload(data)
  payload.updated_at = new Date().toISOString()

  const { data: product, error } = await supabaseAdmin
    .from('products')
    .update(payload)
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!product) throw ApiError.notFound('Product not found')
  return product
}

// ============================================================
// 🆕 Toggle active/inactive (admin)
// ============================================================
export const toggleProductActive = async (id) => {
  const { data: product, error: fetchError } = await supabaseAdmin
    .from('products')
    .select('is_active, status')
    .eq('id', id)
    .single()

  if (fetchError || !product) {
    throw ApiError.notFound('Product not found')
  }

  const newIsActive = !product.is_active

  const { data: updated, error } = await supabaseAdmin
    .from('products')
    .update({
      is_active: newIsActive,
      status: newIsActive ? 'published' : 'archived',
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return updated
}

// ============================================================
// 🗑️ HARD DELETE product (admin) — completely removes from DB
// ============================================================
export const deleteProduct = async (id) => {
  // 1. Check product exists
  const { data: existing, error: fetchError } = await supabaseAdmin
    .from('products')
    .select('id, title')
    .eq('id', id)
    .maybeSingle()

  if (fetchError) throw ApiError.badRequest(fetchError.message)
  if (!existing) throw ApiError.notFound('Product not found')

  // 2. Delete related records (in correct order for FK constraints)
  await supabaseAdmin.from('cart_items').delete().eq('product_id', id)
  await supabaseAdmin.from('wishlists').delete().eq('product_id', id)
  await supabaseAdmin.from('compares').delete().eq('product_id', id)
  await supabaseAdmin.from('product_attributes').delete().eq('product_id', id)
  await supabaseAdmin.from('product_variants').delete().eq('product_id', id)
  await supabaseAdmin.from('comments').delete().eq('product_id', id)
  await supabaseAdmin.from('review_votes').delete().eq('product_id', id)
  await supabaseAdmin.from('review_images').delete().eq('product_id', id)

  // 3. Delete product itself
  const { error: deleteError } = await supabaseAdmin
    .from('products')
    .delete()
    .eq('id', id)

  if (deleteError) throw ApiError.badRequest(deleteError.message)

  console.log(`🗑️  Hard-deleted product: ${existing.title}`)
  return { success: true }
}

// ============================================================
// Increment product views
// ============================================================
export const incrementProductViews = async (id) => {
  try {
    const { data } = await supabaseAdmin
      .from('products')
      .select('views_count')
      .eq('id', id)
      .single()

    if (data) {
      await supabaseAdmin
        .from('products')
        .update({ views_count: (data.views_count || 0) + 1 })
        .eq('id', id)
    }
  } catch (err) {
    // silent
  }
}
ENDOFFILE

echo "   ✅ product.service.js (clean version with hard delete)"

# ============================================================
# FRONTEND
# ============================================================
cd "$SCRIPT_DIR/client"

echo ""
echo "📦 [2/3] Updating AdminProducts.jsx..."

cp src/pages/admin/AdminProducts.jsx src/pages/admin/AdminProducts.jsx.backup-$(date +%s) 2>/dev/null || true

cat > src/pages/admin/AdminProducts.jsx << 'ENDOFFILE'
import { useEffect, useState, useMemo } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import {
  Plus,
  Pencil,
  Trash2,
  Search,
  Eye,
  EyeOff,
  CheckCircle2,
  XCircle,
} from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import ConfirmDialog from '../../components/admin/ConfirmDialog'
import Button from '../../components/ui/Button'
import { api } from '../../lib/api'
import { formatCurrency, truncate } from '../../lib/utils'

const FILTERS = [
  { value: 'all', label: 'All' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
]

export default function AdminProducts() {
  const navigate = useNavigate()
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('all')
  const [toggling, setToggling] = useState(null)
  const [confirm, setConfirm] = useState({ open: false, product: null })
  const [deleting, setDeleting] = useState(false)

  const load = () => {
    setLoading(true)
    api.get('/products/admin/list?limit=200')
      .then((res) => {
        const items = res.data.products || []
        console.log('📦 Loaded', items.length, 'products (admin)')
        setProducts(items)
      })
      .catch((err) => {
        console.error(err)
        toast.error('Failed to load products')
      })
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const handleToggle = async (product) => {
    setToggling(product.id)
    try {
      const res = await api.patch(`/products/${product.id}/toggle-active`)
      const updated = res.data.product
      setProducts((prev) =>
        prev.map((p) => (p.id === updated.id ? { ...p, ...updated } : p))
      )
      toast.success(
        updated.is_active ? '✅ Product activated' : '🚫 Product deactivated'
      )
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to toggle')
    } finally {
      setToggling(null)
    }
  }

  const handleDelete = async () => {
    if (!confirm.product) return
    const productId = confirm.product.id
    const productTitle = confirm.product.title
    setDeleting(true)

    try {
      await api.delete(`/products/${productId}`)
      toast.success(`🗑️ Product deleted permanently`)

      // Remove from local state immediately
      setProducts((prev) => prev.filter((p) => p.id !== productId))
      setConfirm({ open: false, product: null })
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to delete')
    } finally {
      setDeleting(false)
    }
  }

  const filtered = useMemo(() => {
    let items = products

    if (filter === 'active') items = items.filter((p) => p.is_active !== false)
    if (filter === 'inactive') items = items.filter((p) => p.is_active === false)

    if (search.trim()) {
      const q = search.toLowerCase()
      items = items.filter(
        (p) =>
          p.title.toLowerCase().includes(q) ||
          (p.brand?.name || '').toLowerCase().includes(q)
      )
    }

    return items
  }, [products, filter, search])

  const counts = useMemo(
    () => ({
      all: products.length,
      active: products.filter((p) => p.is_active !== false).length,
      inactive: products.filter((p) => p.is_active === false).length,
    }),
    [products]
  )

  const columns = [
    {
      header: 'Product',
      cell: (p) => (
        <div className="flex items-center gap-3">
          {p.thumbnail ? (
            <img
              src={p.thumbnail}
              alt=""
              className="w-10 h-10 object-contain rounded bg-gray-50 dark:bg-secondary"
              onError={(e) => { e.target.style.display = 'none' }}
            />
          ) : (
            <div className="w-10 h-10 rounded bg-gray-100 dark:bg-secondary flex items-center justify-center text-xs text-gray-400">
              —
            </div>
          )}
          <div className="min-w-0">
            <div className="font-medium text-secondary dark:text-white line-clamp-1">
              {truncate(p.title, 50)}
            </div>
            <div className="text-xs text-gray-500">
              {p.brand?.name || 'No brand'}
            </div>
          </div>
        </div>
      ),
    },
    {
      header: 'Price',
      cell: (p) => (
        <span className="font-semibold text-secondary dark:text-white">
          {formatCurrency(p.price)}
        </span>
      ),
    },
    {
      header: 'Stock',
      cell: (p) => {
        const stock = p.stock ?? 0
        return (
          <span
            className={`font-semibold ${
              stock === 0 ? 'text-danger' : stock < 5 ? 'text-yellow-600' : 'text-success'
            }`}
          >
            {stock}
          </span>
        )
      },
    },
    {
      header: 'Status',
      cell: (p) => {
        const isActive = p.is_active !== false
        return isActive ? (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300">
            <CheckCircle2 className="h-3 w-3" />
            Active
          </span>
        ) : (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300">
            <XCircle className="h-3 w-3" />
            Inactive
          </span>
        )
      },
    },
    {
      header: 'Actions',
      className: 'text-right',
      cell: (p) => {
        const isActive = p.is_active !== false
        return (
          <div className="flex items-center justify-end gap-1.5">
            <button
              onClick={() => handleToggle(p)}
              disabled={toggling === p.id}
              className={`p-1.5 rounded transition ${
                isActive
                  ? 'text-yellow-600 hover:bg-yellow-50 dark:hover:bg-yellow-900/20'
                  : 'text-success hover:bg-green-50 dark:hover:bg-green-900/20'
              } disabled:opacity-50`}
              title={isActive ? 'Deactivate' : 'Activate'}
            >
              {toggling === p.id ? (
                <div className="h-4 w-4 border-2 border-current border-t-transparent rounded-full animate-spin" />
              ) : isActive ? (
                <EyeOff className="h-4 w-4" />
              ) : (
                <Eye className="h-4 w-4" />
              )}
            </button>
            <button
              onClick={() => navigate(`/admin/products/${p.id}/edit`)}
              className="p-1.5 text-link hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded transition"
              title="Edit"
            >
              <Pencil className="h-4 w-4" />
            </button>
            <button
              onClick={() => setConfirm({ open: true, product: p })}
              className="p-1.5 text-danger hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition"
              title="Delete permanently"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        )
      },
    },
  ]

  return (
    <AdminLayout
      title="Products"
      actions={
        <Link to="/admin/products/new">
          <Button size="sm">
            <Plus className="h-4 w-4" />
            Add Product
          </Button>
        </Link>
      }
    >
      {/* Toolbar: Search + Filter */}
      <div className="flex flex-wrap items-center gap-3 mb-4">
        <div className="relative flex-1 min-w-[200px] max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search products..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>

        <div className="flex items-center gap-1 bg-white dark:bg-secondary-light rounded-lg p-1 border border-gray-200 dark:border-gray-700">
          {FILTERS.map((f) => (
            <button
              key={f.value}
              onClick={() => setFilter(f.value)}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition ${
                filter === f.value
                  ? 'bg-primary text-secondary'
                  : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-secondary'
              }`}
            >
              {f.label}
              {counts[f.value] > 0 && (
                <span
                  className={`ml-1.5 px-1.5 py-0.5 rounded-full text-[10px] ${
                    filter === f.value
                      ? 'bg-secondary/20'
                      : 'bg-gray-100 dark:bg-secondary'
                  }`}
                >
                  {counts[f.value]}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      <AdminTable
        columns={columns}
        data={filtered}
        loading={loading}
        emptyMessage={
          filter === 'inactive'
            ? 'No inactive products'
            : filter === 'active'
              ? 'No active products'
              : 'No products yet. Click "Add Product" to create one.'
        }
      />

      <ConfirmDialog
        open={confirm.open}
        onClose={() => setConfirm({ open: false, product: null })}
        onConfirm={handleDelete}
        loading={deleting}
        title="Delete product permanently?"
        message={`Are you sure you want to PERMANENTLY delete "${confirm.product?.title}"? This action CANNOT be undone.`}
      />
    </AdminLayout>
  )
}
ENDOFFILE

echo "   ✅ AdminProducts.jsx (hard delete)"

echo ""
echo "📦 [3/3] Done!"
echo ""
echo "🎉 Everything fixed!"
echo ""
echo "📋 Next:"
echo "   1. Restart Backend:"
echo "      Ctrl+C → cd ~/Rostam-Full-site/server → npm run dev"
echo ""
echo "   2. Restart Frontend:"
echo "      Ctrl+C → cd ~/Rostam-Full-site/client → npm run dev"
echo ""
