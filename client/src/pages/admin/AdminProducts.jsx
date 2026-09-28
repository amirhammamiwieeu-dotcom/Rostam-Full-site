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
