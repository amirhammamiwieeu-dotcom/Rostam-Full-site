#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up Admin Products (backend + frontend)..."
echo ""

# ============================================================
# BACKEND
# ============================================================
cd "$SCRIPT_DIR/server"

echo "📦 [1/5] Updating product.service.js..."
cp src/services/product.service.js src/services/product.service.js.backup-$(date +%s) 2>/dev/null || true

# Check if getAdminProducts already exists
if grep -q "getAdminProducts" src/services/product.service.js; then
  echo "   ℹ️  getAdminProducts already exists"
else
  # Append to end of file
  cat >> src/services/product.service.js << 'ENDOFFILE'

// ============================================================
// 🆕 Get ALL products (including inactive) — for admin
// ============================================================
export const getAdminProducts = async (query = {}) => {
  const {
    page = 1,
    limit = 200,
    q,
    status,
    filter, // 'all' | 'active' | 'inactive'
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

  // No is_active filter here — admin sees everything
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
ENDOFFILE
  echo "   ✅ getAdminProducts added"
fi

# ============================================================
echo ""
echo "📦 [2/5] Updating product.controller.js..."
cp src/controllers/product.controller.js src/controllers/product.controller.js.backup-$(date +%s) 2>/dev/null || true

# Replace entire controller file (cleaner)
cat > src/controllers/product.controller.js << 'ENDOFFILE'
import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import {
  getProducts,
  getProductById,
  getProductBySlug,
  getRelatedProducts,
  getFeaturedProducts,
  getNewArrivals,
  getBestSellers,
  searchProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  toggleProductActive,
  getAdminProducts,
  incrementProductViews,
} from '../services/product.service.js'

// ============================================================
// Public
// ============================================================
export const list = asyncHandler(async (req, res) => {
  const result = await getProducts(req.query)
  return ApiResponse.success(res, result, 'Products retrieved')
})

export const getOne = asyncHandler(async (req, res) => {
  const product = await getProductById(req.params.id)
  incrementProductViews(req.params.id).catch(() => {})
  return ApiResponse.success(res, { product }, 'Product retrieved')
})

export const getBySlug = asyncHandler(async (req, res) => {
  const product = await getProductBySlug(req.params.slug)
  incrementProductViews(product.id).catch(() => {})
  return ApiResponse.success(res, { product }, 'Product retrieved')
})

export const related = asyncHandler(async (req, res) => {
  const products = await getRelatedProducts(req.params.id, 8)
  return ApiResponse.success(res, { products }, 'Related products')
})

export const featured = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getFeaturedProducts(limit)
  return ApiResponse.success(res, { products }, 'Featured products')
})

export const newArrivals = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getNewArrivals(limit)
  return ApiResponse.success(res, { products }, 'New arrivals')
})

export const bestSellers = asyncHandler(async (req, res) => {
  const limit = parseInt(req.query.limit) || 12
  const products = await getBestSellers(limit)
  return ApiResponse.success(res, { products }, 'Best sellers')
})

export const search = asyncHandler(async (req, res) => {
  const q = req.query.q || ''
  const limit = parseInt(req.query.limit) || 10
  const products = await searchProducts(q, limit)
  return ApiResponse.success(res, { products }, 'Search results')
})

// ============================================================
// 🆕 Admin
// ============================================================
export const adminList = asyncHandler(async (req, res) => {
  const result = await getAdminProducts(req.query)
  return ApiResponse.success(res, result, 'Products retrieved')
})

export const create = asyncHandler(async (req, res) => {
  const product = await createProduct(req.body)
  return ApiResponse.created(res, { product }, 'Product created')
})

export const update = asyncHandler(async (req, res) => {
  const product = await updateProduct(req.params.id, req.body)
  return ApiResponse.success(res, { product }, 'Product updated')
})

export const remove = asyncHandler(async (req, res) => {
  await deleteProduct(req.params.id)
  return ApiResponse.success(res, null, 'Product deleted')
})

export const toggleActive = asyncHandler(async (req, res) => {
  const product = await toggleProductActive(req.params.id)
  return ApiResponse.success(
    res,
    { product },
    product.is_active ? 'Product activated' : 'Product deactivated'
  )
})
ENDOFFILE
echo "   ✅ product.controller.js updated"

# ============================================================
echo ""
echo "📦 [3/5] Updating product.routes.js..."
cp src/routes/product.routes.js src/routes/product.routes.js.backup-$(date +%s) 2>/dev/null || true

cat > src/routes/product.routes.js << 'ENDOFFILE'
import { Router } from 'express'
import {
  list,
  getOne,
  getBySlug,
  related,
  featured,
  newArrivals,
  bestSellers,
  search,
  adminList,
  create,
  update,
  remove,
  toggleActive,
} from '../controllers/product.controller.js'
import { requireAuth } from '../middleware/auth.js'
import { requireAdmin } from '../middleware/admin.js'
import { validateBody, validateQuery } from '../middleware/validate.js'
import {
  productQuerySchema,
  createProductSchema,
  updateProductSchema,
} from '../validators/product.schema.js'

const router = Router()

// ============================================================
// Public routes
// ============================================================
router.get('/', validateQuery(productQuerySchema), list)
router.get('/featured', featured)
router.get('/new', newArrivals)
router.get('/best-sellers', bestSellers)
router.get('/search', search)
router.get('/slug/:slug', getBySlug)

// ============================================================
// Admin routes (must be before /:id)
// ============================================================
router.get('/admin/list', requireAuth, requireAdmin, adminList)
router.post('/', requireAuth, requireAdmin, validateBody(createProductSchema), create)

// ============================================================
// Dynamic routes (must be after specific routes)
// ============================================================
router.get('/:id', getOne)
router.get('/:id/related', related)
router.put('/:id', requireAuth, requireAdmin, validateBody(updateProductSchema), update)
router.delete('/:id', requireAuth, requireAdmin, remove)
router.patch('/:id/toggle-active', requireAuth, requireAdmin, toggleActive)

export default router
ENDOFFILE
echo "   ✅ product.routes.js updated"

# ============================================================
# FRONTEND
# ============================================================
cd "$SCRIPT_DIR/client"

echo ""
echo "📦 [4/5] Updating AdminProducts.jsx..."

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
    // 🆕 Use admin endpoint that includes inactive products
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

  const handleDelete = async () => {
    if (!confirm.product) return
    setDeleting(true)
    try {
      await api.delete(`/products/${confirm.product.id}`)
      toast.success('Product deleted')
      setConfirm({ open: false, product: null })
      load()
    } catch (err) {
      toast.error(err.message || 'Failed')
    } finally {
      setDeleting(false)
    }
  }

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
              title="Delete"
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
        title="Delete product?"
        message={`Are you sure you want to delete "${confirm.product?.title}"? This action cannot be undone.`}
      />
    </AdminLayout>
  )
}
ENDOFFILE
echo "   ✅ AdminProducts.jsx updated"

# ============================================================
echo ""
echo "📦 [5/5] Done!"
echo ""
echo "🎉 Admin Products setup complete!"
echo ""
echo "📋 Next:"
echo "   1. Restart Backend:"
echo "      Ctrl+C → cd ~/Rostam-Full-site/server → npm run dev"
echo ""
echo "   2. Restart Frontend:"
echo "      Ctrl+C → cd ~/Rostam-Full-site/client → npm run dev"
echo ""
echo "🧪 Test:"
echo "   - Go to http://localhost:3000/admin/products"
echo "   - You should see Filter tabs: All / Active / Inactive"
echo "   - iPhone should appear with 'Inactive' red badge"
echo "   - Click 👁️ to toggle active/inactive"
echo ""
