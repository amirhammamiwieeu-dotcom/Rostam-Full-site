#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "👨‍💼 Creating Admin Panel..."
echo "📁 Working dir: $(pwd)"
echo ""

mkdir -p src/components/admin
mkdir -p src/pages/admin

# ============================================================
# 1. components/admin/AdminSidebar.jsx
# ============================================================
cat > src/components/admin/AdminSidebar.jsx << 'ENDOFFILE'
import { NavLink, useNavigate, Link } from 'react-router-dom'
import {
  LayoutDashboard,
  Package,
  FolderTree,
  ShoppingCart,
  Users,
  MessageSquare,
  Tag,
  BarChart3,
  Home,
  LogOut,
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', to: '/admin', end: true },
  { icon: Package, label: 'Products', to: '/admin/products' },
  { icon: FolderTree, label: 'Categories', to: '/admin/categories' },
  { icon: ShoppingCart, label: 'Orders', to: '/admin/orders' },
  { icon: Users, label: 'Users', to: '/admin/users' },
  { icon: MessageSquare, label: 'Reviews', to: '/admin/comments' },
  { icon: Tag, label: 'Coupons', to: '/admin/coupons' },
  { icon: BarChart3, label: 'Reports', to: '/admin/reports' },
]

export default function AdminSidebar({ open, onClose }) {
  const { signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black/60 z-30 lg:hidden" onClick={onClose} />
      )}
      <aside
        className={`fixed lg:sticky top-0 left-0 h-screen lg:h-[calc(100vh-0px)] w-64 bg-secondary text-white z-40 overflow-y-auto transition-transform ${
          open ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        }`}
      >
        {/* Logo */}
        <div className="p-5 border-b border-secondary-light">
          <Link to="/admin" className="flex items-center gap-2 text-xl font-black">
            <span className="text-primary">Market</span>
            <span className="text-white">Hub</span>
            <span className="text-[10px] bg-primary text-secondary px-1.5 py-0.5 rounded font-bold">
              ADMIN
            </span>
          </Link>
        </div>

        {/* Menu */}
        <nav className="p-3 space-y-1">
          {menuItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                  isActive
                    ? 'bg-primary text-secondary'
                    : 'text-gray-300 hover:bg-secondary-light hover:text-white'
                }`
              }
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </NavLink>
          ))}
        </nav>

        {/* Footer */}
        <div className="absolute bottom-0 left-0 right-0 p-3 border-t border-secondary-light bg-secondary space-y-1">
          <Link
            to="/"
            className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-gray-300 hover:bg-secondary-light hover:text-white transition"
          >
            <Home className="h-4 w-4" />
            Back to Store
          </Link>
          <button
            onClick={handleSignOut}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-red-400 hover:bg-red-900/20 transition"
          >
            <LogOut className="h-4 w-4" />
            Sign Out
          </button>
        </div>
      </aside>
    </>
  )
}
ENDOFFILE

echo "✅ AdminSidebar.jsx"

# ============================================================
# 2. components/admin/AdminHeader.jsx
# ============================================================
cat > src/components/admin/AdminHeader.jsx << 'ENDOFFILE'
import { Menu, Bell, Moon, Sun, ExternalLink } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { useAuth } from '../../context/AuthContext'

export default function AdminHeader({ title, onMenuClick, actions }) {
  const { isDark, toggleTheme } = useTheme()
  const { profile } = useAuth()

  return (
    <header className="bg-white dark:bg-secondary-light border-b border-gray-200 dark:border-gray-700 px-4 sm:px-6 py-3 sticky top-0 z-20">
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 min-w-0">
          <button
            onClick={onMenuClick}
            className="lg:hidden p-2 hover:bg-gray-100 dark:hover:bg-secondary rounded-lg transition"
          >
            <Menu className="h-5 w-5" />
          </button>
          <h1 className="text-lg font-bold text-secondary dark:text-white truncate">
            {title || 'Admin'}
          </h1>
        </div>

        <div className="flex items-center gap-2">
          {actions}

          <Link
            to="/"
            className="hidden sm:flex items-center gap-1.5 px-3 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 hover:text-primary border border-gray-300 dark:border-gray-700 rounded-lg transition"
          >
            <ExternalLink className="h-3.5 w-3.5" />
            View Store
          </Link>

          <button
            onClick={toggleTheme}
            className="p-2 hover:bg-gray-100 dark:hover:bg-secondary rounded-lg transition text-secondary dark:text-white"
          >
            {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xs">
            {(profile?.full_name || 'A').charAt(0).toUpperCase()}
          </div>
        </div>
      </div>
    </header>
  )
}
ENDOFFILE

echo "✅ AdminHeader.jsx"

# ============================================================
# 3. components/admin/AdminLayout.jsx
# ============================================================
cat > src/components/admin/AdminLayout.jsx << 'ENDOFFILE'
import { useState } from 'react'
import AdminSidebar from './AdminSidebar'
import AdminHeader from './AdminHeader'

export default function AdminLayout({ title, children, actions }) {
  const [sidebarOpen, setSidebarOpen] = useState(false)

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-secondary-dark flex">
      <AdminSidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      <div className="flex-1 min-w-0 flex flex-col">
        <AdminHeader
          title={title}
          onMenuClick={() => setSidebarOpen(true)}
          actions={actions}
        />

        <main className="flex-1 p-4 sm:p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ AdminLayout.jsx"

# ============================================================
# 4. components/admin/StatsCard.jsx
# ============================================================
cat > src/components/admin/StatsCard.jsx << 'ENDOFFILE'
import { TrendingUp, TrendingDown } from 'lucide-react'

export default function StatsCard({ icon: Icon, label, value, trend, color = 'primary' }) {
  const colorMap = {
    primary: 'bg-primary/10 text-primary',
    blue: 'bg-blue-100 text-blue-600 dark:bg-blue-900/30',
    green: 'bg-green-100 text-green-600 dark:bg-green-900/30',
    purple: 'bg-purple-100 text-purple-600 dark:bg-purple-900/30',
    red: 'bg-red-100 text-red-600 dark:bg-red-900/30',
    yellow: 'bg-yellow-100 text-yellow-600 dark:bg-yellow-900/30',
  }

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-5 shadow-card">
      <div className="flex items-start justify-between mb-3">
        <div className={`w-11 h-11 rounded-xl ${colorMap[color]} flex items-center justify-center`}>
          <Icon className="h-5 w-5" />
        </div>
        {trend !== undefined && (
          <div
            className={`flex items-center gap-1 text-xs font-semibold ${
              trend >= 0 ? 'text-success' : 'text-danger'
            }`}
          >
            {trend >= 0 ? (
              <TrendingUp className="h-3 w-3" />
            ) : (
              <TrendingDown className="h-3 w-3" />
            )}
            {Math.abs(trend)}%
          </div>
        )}
      </div>
      <div className="text-2xl font-bold text-secondary dark:text-white mb-1">
        {value}
      </div>
      <div className="text-xs text-gray-500">{label}</div>
    </div>
  )
}
ENDOFFILE

echo "✅ StatsCard.jsx"

# ============================================================
# 5. components/admin/AdminTable.jsx
# ============================================================
cat > src/components/admin/AdminTable.jsx << 'ENDOFFILE'
export default function AdminTable({ columns, data, loading, emptyMessage = 'No data' }) {
  if (loading) {
    return (
      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
        <div className="animate-spin rounded-full h-8 w-8 border-2 border-primary border-t-transparent mx-auto mb-3" />
        <p className="text-sm text-gray-500">Loading...</p>
      </div>
    )
  }

  if (!data || data.length === 0) {
    return (
      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
        <p className="text-sm text-gray-500">{emptyMessage}</p>
      </div>
    )
  }

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full min-w-[600px]">
          <thead className="bg-gray-50 dark:bg-secondary border-b border-gray-200 dark:border-gray-700">
            <tr>
              {columns.map((col, i) => (
                <th
                  key={i}
                  className={`px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider ${
                    col.className || ''
                  }`}
                  style={{ width: col.width }}
                >
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 dark:divide-gray-700/50">
            {data.map((row, rowIdx) => (
              <tr
                key={row.id || rowIdx}
                className="hover:bg-gray-50 dark:hover:bg-secondary transition"
              >
                {columns.map((col, colIdx) => (
                  <td key={colIdx} className={`px-4 py-3 text-sm ${col.cellClass || ''}`}>
                    {col.cell ? col.cell(row) : row[col.accessor]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ AdminTable.jsx"

# ============================================================
# 6. components/admin/ConfirmDialog.jsx
# ============================================================
cat > src/components/admin/ConfirmDialog.jsx << 'ENDOFFILE'
import { AlertTriangle } from 'lucide-react'
import Button from '../ui/Button'

export default function ConfirmDialog({ open, onClose, onConfirm, title, message, loading, variant = 'danger' }) {
  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60"
      onClick={onClose}
    >
      <div
        className="bg-white dark:bg-secondary-light rounded-2xl shadow-2xl max-w-md w-full p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <div className={`w-12 h-12 mx-auto mb-4 rounded-full flex items-center justify-center ${
          variant === 'danger' ? 'bg-red-100 dark:bg-red-900/30' : 'bg-yellow-100 dark:bg-yellow-900/30'
        }`}>
          <AlertTriangle className={`h-6 w-6 ${variant === 'danger' ? 'text-danger' : 'text-yellow-600'}`} />
        </div>
        <h3 className="text-lg font-bold text-center mb-2 text-secondary dark:text-white">
          {title || 'Are you sure?'}
        </h3>
        <p className="text-sm text-gray-500 text-center mb-6">
          {message || 'This action cannot be undone.'}
        </p>
        <div className="flex gap-3 justify-center">
          <Button variant="secondary" onClick={onClose} disabled={loading}>
            Cancel
          </Button>
          <Button variant={variant} onClick={onConfirm} disabled={loading}>
            {loading ? 'Processing...' : 'Confirm'}
          </Button>
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ ConfirmDialog.jsx"

# ============================================================
# 7. components/admin/AdminPagination.jsx
# ============================================================
cat > src/components/admin/AdminPagination.jsx << 'ENDOFFILE'
import { ChevronLeft, ChevronRight } from 'lucide-react'

export default function AdminPagination({ page, pages, total, onPageChange }) {
  if (pages <= 1) return null

  return (
    <div className="flex items-center justify-between mt-4 flex-wrap gap-3">
      <div className="text-xs text-gray-500">
        Page {page} of {pages} · {total} items
      </div>
      <div className="flex items-center gap-2">
        <button
          onClick={() => onPageChange(page - 1)}
          disabled={page === 1}
          className="px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        <span className="text-sm font-medium text-secondary dark:text-white px-2">
          {page} / {pages}
        </span>
        <button
          onClick={() => onPageChange(page + 1)}
          disabled={page === pages}
          className="px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ AdminPagination.jsx"

# ============================================================
# 8. components/admin/ImageUpload.jsx
# ============================================================
cat > src/components/admin/ImageUpload.jsx << 'ENDOFFILE'
import { useState, useRef } from 'react'
import { Upload, X, Image as ImageIcon, Loader } from 'lucide-react'
import toast from 'react-hot-toast'
import { api } from '../../lib/api'

export default function ImageUpload({ value, onChange, multiple = false, max = 5 }) {
  const [uploading, setUploading] = useState(false)
  const inputRef = useRef(null)

  const images = multiple ? (Array.isArray(value) ? value : []) : (value ? [value] : [])

  const handleFiles = async (files) => {
    if (!files || files.length === 0) return

    setUploading(true)
    try {
      const formData = new FormData()
      if (multiple) {
        Array.from(files).slice(0, max - images.length).forEach((f) => {
          formData.append('files', f)
        })
        const res = await api.post('/upload/images', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
        const urls = (res.data.files || []).map((f) => f.url)
        onChange([...images, ...urls])
      } else {
        formData.append('file', files[0])
        const res = await api.post('/upload/image', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
        onChange(res.data.url)
      }
      toast.success('Uploaded successfully')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Upload failed')
    } finally {
      setUploading(false)
      if (inputRef.current) inputRef.current.value = ''
    }
  }

  const handleRemove = (url) => {
    if (multiple) {
      onChange(images.filter((u) => u !== url))
    } else {
      onChange('')
    }
  }

  return (
    <div>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        multiple={multiple}
        onChange={(e) => handleFiles(e.target.files)}
        className="hidden"
      />

      <div className="flex flex-wrap gap-3">
        {images.map((url, i) => (
          <div
            key={i}
            className="relative w-24 h-24 rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-secondary"
          >
            <img src={url} alt="" className="w-full h-full object-contain" />
            <button
              type="button"
              onClick={() => handleRemove(url)}
              className="absolute top-1 right-1 w-5 h-5 rounded-full bg-danger text-white flex items-center justify-center hover:bg-red-700 transition"
            >
              <X className="h-3 w-3" />
            </button>
          </div>
        ))}

        {(!multiple ? images.length === 0 : images.length < max) && (
          <button
            type="button"
            onClick={() => inputRef.current?.click()}
            disabled={uploading}
            className="w-24 h-24 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-700 flex flex-col items-center justify-center gap-1 hover:border-primary hover:bg-primary/5 transition text-gray-400 hover:text-primary disabled:opacity-50"
          >
            {uploading ? (
              <Loader className="h-5 w-5 animate-spin" />
            ) : (
              <>
                <Upload className="h-5 w-5" />
                <span className="text-[10px] font-medium">Upload</span>
              </>
            )}
          </button>
        )}
      </div>

      {multiple && (
        <p className="text-xs text-gray-500 mt-2">
          {images.length} / {max} images
        </p>
      )}
    </div>
  )
}
ENDOFFILE

echo "✅ ImageUpload.jsx"

# ============================================================
# 9. pages/admin/AdminDashboard.jsx
# ============================================================
cat > src/pages/admin/AdminDashboard.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import {
  Users,
  Package,
  ShoppingCart,
  DollarSign,
  TrendingUp,
  ArrowRight,
} from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatsCard from '../../components/admin/StatsCard'
import Spinner from '../../components/ui/Spinner'
import OrderStatus from '../../components/order/OrderStatus'
import { api } from '../../lib/api'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function AdminDashboard() {
  const [stats, setStats] = useState(null)
  const [recentOrders, setRecentOrders] = useState([])
  const [lowStock, setLowStock] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([
      api.get('/admin/dashboard').catch(() => ({ data: {} })),
      api.get('/admin/orders?limit=5').catch(() => ({ data: { orders: [] } })),
      api.get('/admin/reports/low-stock').catch(() => ({ data: { products: [] } })),
    ])
      .then(([statsRes, ordersRes, lowStockRes]) => {
        setStats(statsRes.data)
        setRecentOrders(ordersRes.data.orders || [])
        setLowStock(lowStockRes.data.products || [])
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <AdminLayout title="Dashboard">
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : (
        <div className="space-y-6">
          {/* Stats */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <StatsCard icon={Users} label="Total Users" value={stats?.totalUsers || 0} color="blue" />
            <StatsCard icon={Package} label="Products" value={stats?.totalProducts || 0} color="purple" />
            <StatsCard icon={ShoppingCart} label="Orders" value={stats?.totalOrders || 0} color="yellow" />
            <StatsCard
              icon={DollarSign}
              label="Total Revenue"
              value={formatCurrency(stats?.totalRevenue || 0)}
              color="green"
              trend={12}
            />
          </div>

          <div className="grid lg:grid-cols-2 gap-6">
            {/* Recent Orders */}
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                <h3 className="font-bold text-secondary dark:text-white">Recent Orders</h3>
                <Link to="/admin/orders" className="text-xs text-link hover:text-primary flex items-center gap-1">
                  View All <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
              {recentOrders.length === 0 ? (
                <div className="p-6 text-center text-sm text-gray-500">No orders yet</div>
              ) : (
                <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
                  {recentOrders.map((order) => (
                    <Link
                      key={order.id}
                      to={`/admin/orders/${order.id}`}
                      className="block px-5 py-3 hover:bg-gray-50 dark:hover:bg-secondary transition"
                    >
                      <div className="flex items-center justify-between gap-2 flex-wrap">
                        <div className="min-w-0">
                          <div className="font-mono text-xs text-gray-500 mb-0.5">
                            {order.order_number}
                          </div>
                          <div className="text-xs text-gray-600 dark:text-gray-400">
                            {order.customer_name || order.customer_email}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-sm text-primary">
                            {formatCurrency(order.total)}
                          </span>
                          <OrderStatus status={order.status} />
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </div>

            {/* Low Stock */}
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                <h3 className="font-bold text-secondary dark:text-white flex items-center gap-2">
                  Low Stock Alert
                  {lowStock.length > 0 && (
                    <span className="bg-danger text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                      {lowStock.length}
                    </span>
                  )}
                </h3>
                <Link to="/admin/products" className="text-xs text-link hover:text-primary flex items-center gap-1">
                  Manage <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
              {lowStock.length === 0 ? (
                <div className="p-6 text-center text-sm text-gray-500">
                  All products are well-stocked ✅
                </div>
              ) : (
                <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
                  {lowStock.slice(0, 5).map((p) => (
                    <div key={p.id} className="px-5 py-3 flex items-center gap-3">
                      <img src={p.thumbnail} alt="" className="w-10 h-10 object-contain rounded bg-gray-50 dark:bg-secondary" />
                      <div className="flex-1 min-w-0">
                        <div className="text-xs font-medium text-secondary dark:text-white line-clamp-1">
                          {p.title}
                        </div>
                      </div>
                      <span className={`text-sm font-bold ${p.stock === 0 ? 'text-danger' : 'text-yellow-600'}`}>
                        {p.stock} left
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminDashboard.jsx"

# ============================================================
# 10. pages/admin/AdminProducts.jsx
# ============================================================
cat > src/pages/admin/AdminProducts.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
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
      .then((res) => setProducts(res.data.products || []))
      .catch(console.error)
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
          <img src={p.thumbnail} alt="" className="w-10 h-10 object-contain rounded bg-gray-50 dark:bg-secondary" />
          <div className="min-w-0">
            <div className="font-medium text-secondary dark:text-white line-clamp-1">
              {truncate(p.title, 50)}
            </div>
            <div className="text-xs text-gray-500">{p.brand?.name || '—'}</div>
          </div>
        </div>
      ),
    },
    { header: 'Price', cell: (p) => <span className="font-semibold">{formatCurrency(p.price)}</span> },
    {
      header: 'Stock',
      cell: (p) => (
        <span className={`font-semibold ${p.stock === 0 ? 'text-danger' : p.stock < 5 ? 'text-yellow-600' : 'text-success'}`}>
          {p.stock}
        </span>
      ),
    },
    {
      header: 'Status',
      cell: (p) => (
        <span className={`px-2 py-1 rounded text-xs font-semibold ${p.is_active ? 'bg-green-100 text-green-700 dark:bg-green-900/30' : 'bg-gray-100 text-gray-600 dark:bg-gray-700'}`}>
          {p.is_active ? 'Active' : 'Inactive'}
        </span>
      ),
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
        emptyMessage="No products yet"
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

echo "✅ AdminProducts.jsx"

# ============================================================
# 11. pages/admin/AdminProductForm.jsx
# ============================================================
cat > src/pages/admin/AdminProductForm.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Save, ArrowLeft } from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../components/admin/AdminLayout'
import ImageUpload from '../../components/admin/ImageUpload'
import Button from '../../components/ui/Button'
import Spinner from '../../components/ui/Spinner'
import { api } from '../../lib/api'

const EMPTY = {
  title: '',
  short_description: '',
  description: '',
  price: '',
  old_price: '',
  stock: '',
  category_id: '',
  brand_id: '',
  thumbnail: '',
  images: [],
  features: [],
  is_active: true,
  is_featured: false,
  is_prime: false,
  status: 'published',
}

export default function AdminProductForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const isEdit = !!id

  const [form, setForm] = useState(EMPTY)
  const [categories, setCategories] = useState([])
  const [brands, setBrands] = useState([])
  const [featuresText, setFeaturesText] = useState('')
  const [loading, setLoading] = useState(isEdit)
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState({})

  useEffect(() => {
    Promise.all([
      api.get('/categories').catch(() => ({ data: { categories: [] } })),
      api.get('/brands').catch(() => ({ data: { brands: [] } })),
    ]).then(([catRes, brandRes]) => {
      setCategories(catRes.data.categories || [])
      setBrands(brandRes.data.brands || [])
    })
  }, [])

  useEffect(() => {
    if (isEdit) {
      api.get(`/products/${id}`)
        .then((res) => {
          const p = res.data.product
          setForm({
            title: p.title || '',
            short_description: p.short_description || '',
            description: p.description || '',
            price: p.price ?? '',
            old_price: p.old_price ?? '',
            stock: p.stock ?? 0,
            category_id: p.category_id || '',
            brand_id: p.brand_id || '',
            thumbnail: p.thumbnail || '',
            images: p.images || [],
            features: p.features || [],
            is_active: p.is_active ?? true,
            is_featured: p.is_featured ?? false,
            is_prime: p.is_prime ?? false,
            status: p.status || 'published',
          })
          setFeaturesText((p.features || []).join('\n'))
        })
        .catch((err) => {
          toast.error('Failed to load product')
          navigate('/admin/products')
        })
        .finally(() => setLoading(false))
    }
  }, [id, isEdit, navigate])

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const validate = () => {
    const newErrors = {}
    if (!form.title.trim()) newErrors.title = 'Title required'
    if (!form.price || Number(form.price) <= 0) newErrors.price = 'Valid price required'
    if (form.stock === '' || Number(form.stock) < 0) newErrors.stock = 'Valid stock required'
    return newErrors
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const newErrors = validate()
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      toast.error('Please fix the errors')
      return
    }

    setSaving(true)
    try {
      const payload = {
        ...form,
        price: Number(form.price),
        old_price: form.old_price ? Number(form.old_price) : null,
        stock: Number(form.stock),
        category_id: form.category_id || null,
        brand_id: form.brand_id || null,
        features: featuresText.split('\n').map((f) => f.trim()).filter(Boolean),
      }

      if (isEdit) {
        await api.put(`/products/${id}`, payload)
        toast.success('Product updated')
      } else {
        await api.post('/products', payload)
        toast.success('Product created')
      }
      navigate('/admin/products')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <AdminLayout title="Loading...">
        <div className="flex justify-center py-16">
          <Spinner size="lg" />
        </div>
      </AdminLayout>
    )
  }

  const Field = ({ label, name, type = 'text', placeholder = '', required = false, half = false, as = 'input', rows = 3 }) => (
    <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} {required && <span className="text-danger">*</span>}
      </label>
      {as === 'textarea' ? (
        <textarea
          value={form[name]}
          onChange={(e) => handleChange(name, e.target.value)}
          placeholder={placeholder}
          rows={rows}
          className={`w-full px-3.5 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
            errors[name] ? 'border-danger' : 'border-gray-300 dark:border-gray-700 focus:border-primary'
          }`}
        />
      ) : (
        <input
          type={type}
          value={form[name]}
          onChange={(e) => handleChange(name, e.target.value)}
          placeholder={placeholder}
          className={`w-full px-3.5 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
            errors[name] ? 'border-danger' : 'border-gray-300 dark:border-gray-700 focus:border-primary'
          }`}
        />
      )}
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <AdminLayout
      title={isEdit ? 'Edit Product' : 'New Product'}
      actions={
        <button
          onClick={() => navigate('/admin/products')}
          className="flex items-center gap-1 text-sm text-link hover:text-primary"
        >
          <ArrowLeft className="h-4 w-4" />
          Back
        </button>
      }
    >
      <form onSubmit={handleSubmit} className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
        <div className="grid md:grid-cols-2 gap-5 mb-6">
          <Field label="Title" name="title" placeholder="Product title" required />
          <Field label="Short Description" name="short_description" placeholder="Brief description" as="textarea" rows={2} />
          <Field label="Description" name="description" placeholder="Full description" as="textarea" rows={4} />

          <Field label="Price ($)" name="price" type="number" placeholder="99.99" required half />
          <Field label="Old Price ($)" name="old_price" type="number" placeholder="129.99" half />
          <Field label="Stock" name="stock" type="number" placeholder="10" required half />
          <Field label="Status" name="status" as="select" half>
            <option value="published">Published</option>
            <option value="draft">Draft</option>
            <option value="archived">Archived</option>
          </Field>

          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">Category</label>
            <select
              value={form.category_id}
              onChange={(e) => handleChange('category_id', e.target.value)}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              <option value="">— Select —</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>

          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">Brand</label>
            <select
              value={form.brand_id}
              onChange={(e) => handleChange('brand_id', e.target.value)}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              <option value="">— Select —</option>
              {brands.map((b) => (
                <option key={b.id} value={b.id}>{b.name}</option>
              ))}
            </select>
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Features (one per line)
            </label>
            <textarea
              value={featuresText}
              onChange={(e) => setFeaturesText(e.target.value)}
              placeholder={'A17 Pro chip\nTitanium frame\n48MP camera'}
              rows={4}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary focus:border-primary"
            />
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Thumbnail
            </label>
            <ImageUpload
              value={form.thumbnail}
              onChange={(url) => handleChange('thumbnail', url)}
            />
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Gallery Images (up to 6)
            </label>
            <ImageUpload
              value={form.images}
              onChange={(urls) => handleChange('images', urls)}
              multiple
              max={6}
            />
          </div>
        </div>

        <div className="flex flex-wrap gap-4 mb-6 pb-6 border-b border-gray-200 dark:border-gray-700">
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input type="checkbox" checked={form.is_active} onChange={(e) => handleChange('is_active', e.target.checked)} className="accent-primary w-4 h-4" />
            Active
          </label>
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input type="checkbox" checked={form.is_featured} onChange={(e) => handleChange('is_featured', e.target.checked)} className="accent-primary w-4 h-4" />
            Featured
          </label>
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input type="checkbox" checked={form.is_prime} onChange={(e) => handleChange('is_prime', e.target.checked)} className="accent-primary w-4 h-4" />
            Prime (Fast shipping)
          </label>
        </div>

        <div className="flex justify-end gap-2">
          <Button type="button" variant="secondary" onClick={() => navigate('/admin/products')}>
            Cancel
          </Button>
          <Button type="submit" disabled={saving}>
            <Save className="h-4 w-4" />
            {saving ? 'Saving...' : isEdit ? 'Save Changes' : 'Create Product'}
          </Button>
        </div>
      </form>
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminProductForm.jsx"

# ============================================================
# 12. pages/admin/AdminCategories.jsx
# ============================================================
cat > src/pages/admin/AdminCategories.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'

export default function AdminCategories() {
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/categories')
      .then((res) => setCategories(res.data.categories || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    { header: 'Name', cell: (c) => <span className="font-medium text-secondary dark:text-white">{c.name}</span> },
    { header: 'Slug', cell: (c) => <span className="font-mono text-xs text-gray-500">{c.slug}</span> },
    { header: 'Type', cell: (c) => <span className={`px-2 py-0.5 rounded text-xs font-medium ${!c.parent_id ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'}`}>{!c.parent_id ? 'Main' : 'Sub'}</span> },
    { header: 'Products', cell: (c) => c.product_count || 0 },
    { header: 'Status', cell: (c) => c.is_active ? '✅' : '❌' },
  ]

  return (
    <AdminLayout title="Categories">
      <AdminTable columns={columns} data={categories} loading={loading} emptyMessage="No categories" />
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminCategories.jsx"

# ============================================================
# 13. pages/admin/AdminOrders.jsx
# ============================================================
cat > src/pages/admin/AdminOrders.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Eye, Search } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import OrderStatus from '../../components/order/OrderStatus'
import { api } from '../../lib/api'
import { formatCurrency, formatDate, truncate } from '../../lib/utils'

export default function AdminOrders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  useEffect(() => {
    api.get('/admin/orders?limit=100')
      .then((res) => setOrders(res.data.orders || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const filtered = search
    ? orders.filter((o) =>
        o.order_number.toLowerCase().includes(search.toLowerCase()) ||
        (o.customer_email || '').toLowerCase().includes(search.toLowerCase())
      )
    : orders

  const columns = [
    { header: 'Order #', cell: (o) => <span className="font-mono text-xs text-secondary dark:text-white">{o.order_number}</span> },
    { header: 'Customer', cell: (o) => (
      <div className="text-xs">
        <div className="font-medium text-secondary dark:text-white">{o.customer_name || '—'}</div>
        <div className="text-gray-500">{truncate(o.customer_email, 25)}</div>
      </div>
    )},
    { header: 'Date', cell: (o) => <span className="text-xs text-gray-500">{formatDate(o.created_at)}</span> },
    { header: 'Total', cell: (o) => <span className="font-bold text-primary">{formatCurrency(o.total)}</span> },
    { header: 'Status', cell: (o) => <OrderStatus status={o.status} /> },
    { header: 'Actions', className: 'text-right', cell: (o) => (
      <Link to={`/admin/orders/${o.id}`} className="inline-flex p-1.5 text-link hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded transition" title="View">
        <Eye className="h-4 w-4" />
      </Link>
    )},
  ]

  return (
    <AdminLayout title="Orders">
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by order # or email..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>
      </div>

      <AdminTable columns={columns} data={filtered} loading={loading} emptyMessage="No orders yet" />
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminOrders.jsx"

# ============================================================
# 14. pages/admin/AdminOrderDetail.jsx
# ============================================================
cat > src/pages/admin/AdminOrderDetail.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeft, Save, MapPin, User } from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../components/admin/AdminLayout'
import OrderStatus from '../../components/order/OrderStatus'
import Button from '../../components/ui/Button'
import Spinner from '../../components/ui/Spinner'
import { api } from '../../lib/api'
import { formatCurrency, formatDate } from '../../lib/utils'

const STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded']

export default function AdminOrderDetail() {
  const { id } = useParams()
  const [order, setOrder] = useState(null)
  const [loading, setLoading] = useState(true)
  const [status, setStatus] = useState('')
  const [tracking, setTracking] = useState('')
  const [note, setNote] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    api.get(`/orders/${id}`)
      .then((res) => {
        setOrder(res.data.order)
        setStatus(res.data.order.status)
        setTracking(res.data.order.tracking_number || '')
        setNote(res.data.order.admin_note || '')
      })
      .catch(() => {
        toast.error('Order not found')
      })
      .finally(() => setLoading(false))
  }, [id])

  const handleSave = async () => {
    setSaving(true)
    try {
      await api.put(`/orders/${id}/status`, {
        status,
        tracking_number: tracking || undefined,
        note: note || undefined,
      })
      toast.success('Order updated')
      const res = await api.get(`/orders/${id}`)
      setOrder(res.data.order)
    } catch (err) {
      toast.error(err.message || 'Failed')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <AdminLayout title="Loading...">
        <div className="flex justify-center py-16"><Spinner size="lg" /></div>
      </AdminLayout>
    )
  }

  if (!order) {
    return (
      <AdminLayout title="Order not found">
        <Link to="/admin/orders" className="text-link hover:text-primary">
          ← Back to orders
        </Link>
      </AdminLayout>
    )
  }

  const address = order.shipping_address || {}

  return (
    <AdminLayout
      title={`Order #${order.order_number}`}
      actions={
        <Link to="/admin/orders" className="flex items-center gap-1 text-sm text-link hover:text-primary">
          <ArrowLeft className="h-4 w-4" /> Back
        </Link>
      }
    >
      <div className="grid lg:grid-cols-[1fr_320px] gap-6">
        {/* Main */}
        <div className="space-y-6">
          {/* Items */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Items</h3>
            <div className="space-y-3">
              {(order.items || []).map((item) => (
                <div key={item.id} className="flex gap-3 pb-3 border-b border-gray-100 dark:border-gray-700/50 last:border-0 last:pb-0">
                  <img src={item.image} alt="" className="w-14 h-14 object-contain rounded bg-gray-50 dark:bg-secondary" />
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium text-secondary dark:text-white line-clamp-2">{item.title}</div>
                    <div className="text-xs text-gray-500 mt-1">Qty: {item.quantity} × {formatCurrency(item.price)}</div>
                  </div>
                  <div className="font-bold text-secondary dark:text-white">{formatCurrency(item.price * item.quantity)}</div>
                </div>
              ))}
            </div>

            <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700 space-y-1.5 text-sm">
              <div className="flex justify-between text-gray-500"><span>Subtotal</span><span>{formatCurrency(order.subtotal)}</span></div>
              {order.discount > 0 && <div className="flex justify-between text-success"><span>Discount</span><span>−{formatCurrency(order.discount)}</span></div>}
              <div className="flex justify-between text-gray-500"><span>Shipping</span><span>{formatCurrency(order.shipping_cost || 0)}</span></div>
              <div className="flex justify-between text-gray-500"><span>Tax</span><span>{formatCurrency(order.tax || 0)}</span></div>
              <div className="flex justify-between font-bold text-secondary dark:text-white pt-2 border-t border-gray-200 dark:border-gray-700"><span>Total</span><span className="text-primary">{formatCurrency(order.total)}</span></div>
            </div>
          </div>

          {/* Customer & Address */}
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
              <h3 className="font-bold mb-3 text-secondary dark:text-white flex items-center gap-2">
                <User className="h-4 w-4 text-primary" /> Customer
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                <strong className="text-secondary dark:text-white">{address.full_name}</strong><br />
                {order.customer_email}<br />
                {address.phone}
              </p>
            </div>

            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
              <h3 className="font-bold mb-3 text-secondary dark:text-white flex items-center gap-2">
                <MapPin className="h-4 w-4 text-primary" /> Shipping Address
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                {address.address_line1}<br />
                {address.address_line2 && <>{address.address_line2}<br /></>}
                {address.city}, {address.state} {address.zip}<br />
                {address.country}
              </p>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Manage Order</h3>

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Status</label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4"
            >
              {STATUSES.map((s) => (
                <option key={s} value={s} className="capitalize">{s}</option>
              ))}
            </select>

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Tracking Number</label>
            <input
              type="text"
              value={tracking}
              onChange={(e) => setTracking(e.target.value)}
              placeholder="TRK123456789"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4"
            />

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Admin Note</label>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              rows={3}
              placeholder="Internal note..."
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4 resize-y"
            />

            <Button onClick={handleSave} disabled={saving} className="w-full">
              <Save className="h-4 w-4" />
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>

          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5 text-sm">
            <div className="flex justify-between mb-2"><span className="text-gray-500">Payment</span><span className="font-medium text-secondary dark:text-white capitalize">{order.payment_status}</span></div>
            <div className="flex justify-between mb-2"><span className="text-gray-500">Placed</span><span className="text-secondary dark:text-white">{formatDate(order.created_at)}</span></div>
            {order.paid_at && <div className="flex justify-between mb-2"><span className="text-gray-500">Paid</span><span className="text-secondary dark:text-white">{formatDate(order.paid_at)}</span></div>}
            {order.shipped_at && <div className="flex justify-between mb-2"><span className="text-gray-500">Shipped</span><span className="text-secondary dark:text-white">{formatDate(order.shipped_at)}</span></div>}
            {order.delivered_at && <div className="flex justify-between"><span className="text-gray-500">Delivered</span><span className="text-secondary dark:text-white">{formatDate(order.delivered_at)}</span></div>}
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminOrderDetail.jsx"

# ============================================================
# 15. pages/admin/AdminUsers.jsx
# ============================================================
cat > src/pages/admin/AdminUsers.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Search } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'
import { formatDate } from '../../lib/utils'

export default function AdminUsers() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  useEffect(() => {
    api.get('/admin/users?limit=100')
      .then((res) => setUsers(res.data.users || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const filtered = search
    ? users.filter((u) =>
        (u.email || '').toLowerCase().includes(search.toLowerCase()) ||
        (u.full_name || '').toLowerCase().includes(search.toLowerCase())
      )
    : users

  const columns = [
    {
      header: 'User',
      cell: (u) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xs">
            {(u.full_name || u.email || 'U').charAt(0).toUpperCase()}
          </div>
          <div>
            <div className="font-medium text-secondary dark:text-white">{u.full_name || '—'}</div>
            <div className="text-xs text-gray-500">{u.email}</div>
          </div>
        </div>
      ),
    },
    {
      header: 'Role',
      cell: (u) => (
        <span className={`px-2 py-0.5 rounded text-xs font-semibold ${
          u.role === 'admin' ? 'bg-primary text-secondary' :
          u.role === 'seller' ? 'bg-blue-100 text-blue-700' :
          'bg-gray-100 text-gray-600'
        }`}>
          {u.role}
        </span>
      ),
    },
    { header: 'Joined', cell: (u) => <span className="text-xs text-gray-500">{formatDate(u.created_at)}</span> },
    { header: 'Status', cell: (u) => u.is_active ? '✅ Active' : '❌ Inactive' },
  ]

  return (
    <AdminLayout title="Users">
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search users..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>
      </div>
      <AdminTable columns={columns} data={filtered} loading={loading} emptyMessage="No users" />
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminUsers.jsx"

# ============================================================
# 16. pages/admin/AdminComments.jsx
# ============================================================
cat > src/pages/admin/AdminComments.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import RatingStars from '../../components/product/RatingStars'
import { api } from '../../lib/api'
import { formatRelativeTime, truncate } from '../../lib/utils'

export default function AdminComments() {
  const [comments, setComments] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/admin/comments?limit=100')
      .then((res) => setComments(res.data.comments || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    {
      header: 'Product',
      cell: (c) => (
        <div className="flex items-center gap-2">
          <img src={c.product?.thumbnail} alt="" className="w-8 h-8 object-contain rounded" />
          <span className="text-xs text-secondary dark:text-white">{truncate(c.product?.title, 30)}</span>
        </div>
      ),
    },
    { header: 'User', cell: (c) => <span className="text-xs">{c.user?.full_name || c.user?.email}</span> },
    { header: 'Rating', cell: (c) => <RatingStars rating={c.rating} /> },
    { header: 'Review', cell: (c) => <span className="text-xs text-gray-500">{truncate(c.text, 60)}</span> },
    { header: 'Date', cell: (c) => <span className="text-xs text-gray-500">{formatRelativeTime(c.created_at)}</span> },
    {
      header: 'Status',
      cell: (c) => (
        <span className={`px-2 py-0.5 rounded text-xs font-semibold ${c.is_approved ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
          {c.is_approved ? 'Approved' : 'Pending'}
        </span>
      ),
    },
  ]

  return (
    <AdminLayout title="Reviews">
      <AdminTable columns={columns} data={comments} loading={loading} emptyMessage="No reviews" />
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminComments.jsx"

# ============================================================
# 17. pages/admin/AdminCoupons.jsx
# ============================================================
cat > src/pages/admin/AdminCoupons.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'
import { formatDate } from '../../lib/utils'

export default function AdminCoupons() {
  const [coupons, setCoupons] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/coupons')
      .then((res) => setCoupons(res.data.coupons || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    { header: 'Code', cell: (c) => <span className="font-mono font-bold text-secondary dark:text-white">{c.code}</span> },
    { header: 'Type', cell: (c) => <span className="capitalize">{c.discount_type}</span> },
    { header: 'Value', cell: (c) => c.discount_type === 'percent' ? `${c.discount_value}%` : `$${c.discount_value}` },
    { header: 'Min Order', cell: (c) => `$${c.min_order || 0}` },
    { header: 'Used', cell: (c) => `${c.used_count || 0} / ${c.max_uses || '∞'}` },
    { header: 'Expires', cell: (c) => c.expires_at ? formatDate(c.expires_at) : 'Never' },
    { header: 'Status', cell: (c) => c.is_active ? '✅ Active' : '❌ Inactive' },
  ]

  return (
    <AdminLayout title="Coupons">
      <AdminTable columns={columns} data={coupons} loading={loading} emptyMessage="No coupons" />
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminCoupons.jsx"

# ============================================================
# 18. pages/admin/AdminReports.jsx
# ============================================================
cat > src/pages/admin/AdminReports.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { DollarSign, ShoppingCart, TrendingUp } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatsCard from '../../components/admin/StatsCard'
import Spinner from '../../components/ui/Spinner'
import { api } from '../../lib/api'
import { formatCurrency } from '../../lib/utils'

export default function AdminReports() {
  const [report, setReport] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/admin/reports/sales')
      .then((res) => setReport(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const avgOrder = report?.totalOrders > 0 ? report.totalRevenue / report.totalOrders : 0

  return (
    <AdminLayout title="Reports">
      {loading ? (
        <div className="flex justify-center py-12"><Spinner size="lg" /></div>
      ) : (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <StatsCard icon={DollarSign} label="Total Revenue" value={formatCurrency(report?.totalRevenue || 0)} color="green" />
            <StatsCard icon={ShoppingCart} label="Total Orders" value={report?.totalOrders || 0} color="blue" />
            <StatsCard icon={TrendingUp} label="Avg. Order Value" value={formatCurrency(avgOrder)} color="purple" />
          </div>

          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Sales by Day</h3>
            {!report?.byDay || Object.keys(report.byDay).length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-6">No sales data yet</p>
            ) : (
              <div className="space-y-3">
                {Object.entries(report.byDay).slice(-7).reverse().map(([day, data]) => (
                  <div key={day} className="flex items-center gap-3">
                    <div className="text-xs text-gray-500 w-24">{day}</div>
                    <div className="flex-1 bg-gray-100 dark:bg-secondary rounded-full h-6 overflow-hidden">
                      <div
                        className="h-full bg-primary rounded-full flex items-center justify-end pr-2 text-[10px] font-bold text-secondary"
                        style={{ width: `${Math.min(100, (data.revenue / report.totalRevenue) * 100 * 3)}%` }}
                      >
                        {data.count}
                      </div>
                    </div>
                    <div className="text-xs font-bold text-secondary dark:text-white w-24 text-right">
                      {formatCurrency(data.revenue)}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
ENDOFFILE

echo "✅ AdminReports.jsx"

# ============================================================
# 19. App.jsx (آپدیت نهایی)
# ============================================================
cat > src/App.jsx << 'ENDOFFILE'
import { Routes, Route } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import { AuthProvider } from './context/AuthContext'
import { CartProvider } from './context/CartContext'
import { WishlistProvider } from './context/WishlistContext'
import { CompareProvider } from './context/CompareContext'
import { CheckoutProvider } from './context/CheckoutContext'

import Layout from './components/layout/Layout'
import ProtectedRoute from './components/auth/ProtectedRoute'

import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import ForgotPassword from './pages/ForgotPassword'
import ResetPassword from './pages/ResetPassword'
import AuthCallback from './pages/AuthCallback'
import Products from './pages/Products'
import ProductDetail from './pages/ProductDetail'
import Search from './pages/Search'
import Category from './pages/Category'
import Cart from './pages/Cart'
import Wishlist from './pages/Wishlist'
import Compare from './pages/Compare'
import Checkout from './pages/Checkout'
import OrderSuccess from './pages/OrderSuccess'
import Orders from './pages/Orders'
import OrderDetail from './pages/OrderDetail'
import Account from './pages/Account'
import AccountProfile from './pages/AccountProfile'
import AccountAddresses from './pages/AccountAddresses'
import AccountReviews from './pages/AccountReviews'
import AccountSettings from './pages/AccountSettings'

import AdminDashboard from './pages/admin/AdminDashboard'
import AdminProducts from './pages/admin/AdminProducts'
import AdminProductForm from './pages/admin/AdminProductForm'
import AdminCategories from './pages/admin/AdminCategories'
import AdminOrders from './pages/admin/AdminOrders'
import AdminOrderDetail from './pages/admin/AdminOrderDetail'
import AdminUsers from './pages/admin/AdminUsers'
import AdminComments from './pages/admin/AdminComments'
import AdminCoupons from './pages/admin/AdminCoupons'
import AdminReports from './pages/admin/AdminReports'

import NotFound from './pages/NotFound'

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <WishlistProvider>
          <CompareProvider>
            <CartProvider>
              <CheckoutProvider>
                <Routes>
                  {/* Store */}
                  <Route element={<Layout />}>
                    <Route path="/" element={<Home />} />
                    <Route path="/products" element={<Products />} />
                    <Route path="/products/:slug" element={<ProductDetail />} />
                    <Route path="/search" element={<Search />} />
                    <Route path="/category/:slug" element={<Category />} />

                    <Route element={<ProtectedRoute />}>
                      <Route path="/cart" element={<Cart />} />
                      <Route path="/wishlist" element={<Wishlist />} />
                      <Route path="/compare" element={<Compare />} />
                      <Route path="/checkout" element={<Checkout />} />
                      <Route path="/order-success" element={<OrderSuccess />} />
                      <Route path="/orders" element={<Orders />} />
                      <Route path="/orders/:id" element={<OrderDetail />} />
                      <Route path="/account" element={<Account />} />
                      <Route path="/account/profile" element={<AccountProfile />} />
                      <Route path="/account/addresses" element={<AccountAddresses />} />
                      <Route path="/account/reviews" element={<AccountReviews />} />
                      <Route path="/account/settings" element={<AccountSettings />} />
                    </Route>

                    <Route path="*" element={<NotFound />} />
                  </Route>

                  {/* Auth */}
                  <Route path="/login" element={<Login />} />
                  <Route path="/register" element={<Register />} />
                  <Route path="/forgot-password" element={<ForgotPassword />} />
                  <Route path="/reset-password" element={<ResetPassword />} />
                  <Route path="/auth/callback" element={<AuthCallback />} />

                  {/* Admin */}
                  <Route element={<ProtectedRoute requireAdmin />}>
                    <Route path="/admin" element={<AdminDashboard />} />
                    <Route path="/admin/products" element={<AdminProducts />} />
                    <Route path="/admin/products/new" element={<AdminProductForm />} />
                    <Route path="/admin/products/:id/edit" element={<AdminProductForm />} />
                    <Route path="/admin/categories" element={<AdminCategories />} />
                    <Route path="/admin/orders" element={<AdminOrders />} />
                    <Route path="/admin/orders/:id" element={<AdminOrderDetail />} />
                    <Route path="/admin/users" element={<AdminUsers />} />
                    <Route path="/admin/comments" element={<AdminComments />} />
                    <Route path="/admin/coupons" element={<AdminCoupons />} />
                    <Route path="/admin/reports" element={<AdminReports />} />
                  </Route>
                </Routes>
              </CheckoutProvider>
            </CartProvider>
          </CompareProvider>
        </WishlistProvider>
      </AuthProvider>
    </ThemeProvider>
  )
}
ENDOFFILE

echo "✅ App.jsx updated"

echo ""
echo "🎉 Admin Panel done!"
echo ""
echo "📋 Next:"
echo "   1. cd ~/Rostam-Full-site/client"
echo "   2. pkill -f vite"
echo "   3. npm run dev"
echo ""
echo "🧪 Test:"
echo "   1. Login with admin user (test4@example.com)"
echo "   2. Go to /admin"
echo "   3. Navigate to all sections"
echo ""
