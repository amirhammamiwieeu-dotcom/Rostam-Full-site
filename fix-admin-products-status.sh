#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

cp src/pages/admin/AdminProducts.jsx src/pages/admin/AdminProducts.jsx.backup-$(date +%s) 2>/dev/null || true

cat > src/pages/admin/AdminProducts.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Plus, Pencil, Trash2, Search, Eye, EyeOff } from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import ConfirmDialog from '../../components/admin/ConfirmDialog'
import Button from '../../components/ui/Button'
import { api } from '../../lib/api'
import { formatCurrency, truncate } from '../../lib/utils'

export default function AdminProducts() {
  const navigate = useNavigate()
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [confirm, setConfirm] = useState({ open: false, product: null })
  const [deleting, setDeleting] = useState(false)

  const load = () => {
    setLoading(true)
    api.get('/products?limit=100')
      .then((res) => {
        const items = res.data.products || []
        console.log('📦 Products loaded:', items.length)
        items.forEach((p) => {
          console.log(`   - ${p.title}: is_active=${p.is_active}, status=${p.status}, stock=${p.stock}`)
        })
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

  const filtered = search
    ? products.filter((p) =>
        p.title.toLowerCase().includes(search.toLowerCase()) ||
        (p.brand?.name || '').toLowerCase().includes(search.toLowerCase())
      )
    : products

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
              onError={(e) => {
                e.target.style.display = 'none'
              }}
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
              stock === 0
                ? 'text-danger'
                : stock < 5
                  ? 'text-yellow-600'
                  : 'text-success'
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
        // Determine status based on multiple factors
        const isActive = p.is_active !== false
        const isPublished = !p.status || p.status === 'published'

        if (!isActive) {
          return (
            <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300">
              <EyeOff className="h-3 w-3" />
              Hidden
            </span>
          )
        }

        if (!isPublished) {
          return (
            <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
              {p.status || 'Draft'}
            </span>
          )
        }

        return (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300">
            <Eye className="h-3 w-3" />
            Active
          </span>
        )
      },
    },
    {
      header: 'Actions',
      className: 'text-right',
      cell: (p) => (
        <div className="flex items-center justify-end gap-2">
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
      ),
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
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search products..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>
      </div>

      <AdminTable
        columns={columns}
        data={filtered}
        loading={loading}
        emptyMessage="No products yet. Click 'Add Product' to create one."
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

echo "✅ AdminProducts.jsx updated (fixed Status column)"
