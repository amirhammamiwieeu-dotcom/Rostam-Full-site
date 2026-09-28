#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "👤 Creating User Panel..."
echo "📁 Working dir: $(pwd)"
echo ""

mkdir -p src/components/user
mkdir -p src/pages
mkdir -p src/hooks

# ============================================================
# 1. hooks/useProfile.js
# ============================================================
cat > src/hooks/useProfile.js << 'ENDOFFILE'
import { useState, useEffect } from 'react'
import { api } from '../lib/api'
import { useAuth } from '../context/AuthContext'

export function useProfile() {
  const { user, fetchProfile } = useAuth()
  const [loading, setLoading] = useState(true)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    if (user) {
      fetchProfile().finally(() => setLoading(false))
    } else {
      setLoading(false)
    }
  }, [user])

  const updateProfile = async (updates) => {
    setUpdating(true)
    try {
      const res = await api.put('/auth/me', updates)
      await fetchProfile()
      return res.data
    } finally {
      setUpdating(false)
    }
  }

  const changePassword = async ({ current_password, new_password }) => {
    return await api.post('/auth/change-password', {
      current_password,
      new_password,
    })
  }

  return { loading, updating, updateProfile, changePassword }
}
ENDOFFILE

echo "✅ useProfile.js"

# ============================================================
# 2. components/user/UserSidebar.jsx
# ============================================================
cat > src/components/user/UserSidebar.jsx << 'ENDOFFILE'
import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard,
  User,
  MapPin,
  MessageSquare,
  Settings,
  Package,
  Heart,
  LogOut,
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', to: '/account', end: true },
  { icon: Package, label: 'My Orders', to: '/orders' },
  { icon: Heart, label: 'Wishlist', to: '/wishlist' },
  { icon: User, label: 'Profile', to: '/account/profile' },
  { icon: MapPin, label: 'Addresses', to: '/account/addresses' },
  { icon: MessageSquare, label: 'My Reviews', to: '/account/reviews' },
  { icon: Settings, label: 'Settings', to: '/account/settings' },
]

export default function UserSidebar() {
  const { profile, user, signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  const initials = (profile?.full_name || user?.email || 'U')
    .split(' ')
    .map((n) => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

  return (
    <aside className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden h-fit lg:sticky lg:top-32">
      {/* Profile header */}
      <div className="p-5 border-b border-gray-200 dark:border-gray-700 text-center">
        <div className="w-16 h-16 mx-auto rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xl mb-3">
          {initials}
        </div>
        <h3 className="font-bold text-secondary dark:text-white text-sm">
          {profile?.full_name || 'User'}
        </h3>
        <p className="text-xs text-gray-500 truncate mt-1">{user?.email}</p>
      </div>

      {/* Menu */}
      <nav className="p-2">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                isActive
                  ? 'bg-primary text-secondary'
                  : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-secondary hover:text-primary'
              }`
            }
          >
            <item.icon className="h-4 w-4" />
            {item.label}
          </NavLink>
        ))}

        <button
          onClick={handleSignOut}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-danger hover:bg-red-50 dark:hover:bg-red-900/10 transition mt-1"
        >
          <LogOut className="h-4 w-4" />
          Sign Out
        </button>
      </nav>
    </aside>
  )
}
ENDOFFILE

echo "✅ UserSidebar.jsx"

# ============================================================
# 3. components/user/UserLayout.jsx
# ============================================================
cat > src/components/user/UserLayout.jsx << 'ENDOFFILE'
import UserSidebar from './UserSidebar'

export default function UserLayout({ title, description, children, actions }) {
  return (
    <div className="container-page py-6">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <UserSidebar />

        <div className="min-w-0">
          {(title || actions) && (
            <div className="flex items-center justify-between flex-wrap gap-3 mb-5">
              <div>
                {title && (
                  <h1 className="text-2xl font-bold text-secondary dark:text-white">
                    {title}
                  </h1>
                )}
                {description && (
                  <p className="text-sm text-gray-500 mt-1">{description}</p>
                )}
              </div>
              {actions && <div>{actions}</div>}
            </div>
          )}

          <div>{children}</div>
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ UserLayout.jsx"

# ============================================================
# 4. components/user/UserStats.jsx
# ============================================================
cat > src/components/user/UserStats.jsx << 'ENDOFFILE'
import { Package, Heart, MessageSquare, DollarSign } from 'lucide-react'
import { formatCurrency } from '../../lib/utils'

export default function UserStats({ stats }) {
  const items = [
    {
      label: 'Total Orders',
      value: stats?.orders || 0,
      icon: Package,
      color: 'text-blue-600 bg-blue-100 dark:bg-blue-900/30',
    },
    {
      label: 'Wishlist Items',
      value: stats?.wishlist || 0,
      icon: Heart,
      color: 'text-red-600 bg-red-100 dark:bg-red-900/30',
    },
    {
      label: 'Reviews',
      value: stats?.reviews || 0,
      icon: MessageSquare,
      color: 'text-purple-600 bg-purple-100 dark:bg-purple-900/30',
    },
    {
      label: 'Total Spent',
      value: formatCurrency(stats?.total_spent || 0),
      icon: DollarSign,
      color: 'text-green-600 bg-green-100 dark:bg-green-900/30',
    },
  ]

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {items.map((item, i) => (
        <div
          key={i}
          className="bg-white dark:bg-secondary-light rounded-xl p-4 shadow-card"
        >
          <div className={`w-10 h-10 rounded-lg ${item.color} flex items-center justify-center mb-3`}>
            <item.icon className="h-5 w-5" />
          </div>
          <div className="text-xl font-bold text-secondary dark:text-white">
            {item.value}
          </div>
          <div className="text-xs text-gray-500 mt-1">{item.label}</div>
        </div>
      ))}
    </div>
  )
}
ENDOFFILE

echo "✅ UserStats.jsx"

# ============================================================
# 5. components/user/ProfileForm.jsx
# ============================================================
cat > src/components/user/ProfileForm.jsx << 'ENDOFFILE'
import { useState, useEffect } from 'react'
import { User, Mail, Phone, FileText, Image as ImageIcon } from 'lucide-react'
import toast from 'react-hot-toast'
import Button from '../ui/Button'
import { useAuth } from '../../context/AuthContext'
import { useProfile } from '../../hooks/useProfile'

export default function ProfileForm() {
  const { profile } = useAuth()
  const { updateProfile, updating } = useProfile()

  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    username: '',
    bio: '',
    avatar_url: '',
  })
  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (profile) {
      setForm({
        full_name: profile.full_name || '',
        email: profile.email || '',
        phone: profile.phone || '',
        username: profile.username || '',
        bio: profile.bio || '',
        avatar_url: profile.avatar_url || '',
      })
    }
  }, [profile])

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const newErrors = {}
    if (!form.full_name.trim()) newErrors.full_name = 'Name required'
    if (!form.email.trim()) newErrors.email = 'Email required'
    if (form.phone && !/^\+?[0-9]{10,15}$/.test(form.phone)) {
      newErrors.phone = 'Invalid phone number'
    }
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    try {
      await updateProfile({
        full_name: form.full_name,
        email: form.email,
        phone: form.phone || null,
        username: form.username || null,
        bio: form.bio || null,
        avatar_url: form.avatar_url || null,
      })
      toast.success('Profile updated')
    } catch (err) {
      toast.error(err.message || 'Failed to update')
    }
  }

  const Field = ({ icon: Icon, label, name, placeholder, type = 'text', required = false, disabled = false }) => (
    <div>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} {required && '*'}
      </label>
      <div className="relative">
        <Icon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type={type}
          value={form[name]}
          onChange={(e) => handleChange(name, e.target.value)}
          placeholder={placeholder}
          disabled={disabled}
          className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary disabled:opacity-60 ${
            errors[name]
              ? 'border-danger'
              : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
          }`}
        />
      </div>
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <form onSubmit={handleSubmit} className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 space-y-5">
      <div className="grid md:grid-cols-2 gap-5">
        <Field icon={User} label="Full Name" name="full_name" placeholder="John Doe" required />
        <Field icon={Mail} label="Email" name="email" placeholder="john@example.com" type="email" required disabled />
        <Field icon={Phone} label="Phone" name="phone" placeholder="+1 234 567 8900" />
        <Field icon={User} label="Username" name="username" placeholder="johndoe" />
      </div>

      <div>
        <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
          Bio
        </label>
        <div className="relative">
          <FileText className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
          <textarea
            value={form.bio}
            onChange={(e) => handleChange('bio', e.target.value)}
            placeholder="Tell us about yourself..."
            rows={3}
            maxLength={500}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary focus:border-primary focus:ring-2 focus:ring-primary/20 resize-y"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
          Avatar URL
        </label>
        <div className="relative">
          <ImageIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="url"
            value={form.avatar_url}
            onChange={(e) => handleChange('avatar_url', e.target.value)}
            placeholder="https://example.com/avatar.jpg"
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </div>
      </div>

      <div className="flex justify-end pt-2">
        <Button type="submit" disabled={updating}>
          {updating ? 'Saving...' : 'Save Changes'}
        </Button>
      </div>
    </form>
  )
}
ENDOFFILE

echo "✅ ProfileForm.jsx"

# ============================================================
# 6. components/user/AddressCard.jsx
# ============================================================
cat > src/components/user/AddressCard.jsx << 'ENDOFFILE'
import { MapPin, Pencil, Trash2, Check } from 'lucide-react'

export default function AddressCard({ address, onEdit, onDelete, onSetDefault }) {
  return (
    <div
      className={`bg-white dark:bg-secondary-light rounded-xl p-4 border-2 transition ${
        address.is_default ? 'border-primary' : 'border-gray-200 dark:border-gray-700'
      }`}
    >
      <div className="flex items-start gap-3">
        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
          <MapPin className="h-5 w-5 text-primary" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-sm text-secondary dark:text-white">
              {address.title || address.full_name || 'Address'}
            </span>
            {address.is_default && (
              <span className="inline-flex items-center gap-1 bg-primary text-secondary text-[10px] font-bold px-2 py-0.5 rounded-full">
                <Check className="h-3 w-3" />
                Default
              </span>
            )}
          </div>
          <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
            {address.full_name && <>{address.full_name}<br /></>}
            {address.address_line1}
            {address.address_line2 && `, ${address.address_line2}`}
            <br />
            {address.city}, {address.state || ''} {address.zip}
            <br />
            {address.country}
            {address.phone && <><br />{address.phone}</>}
          </p>

          <div className="flex items-center gap-3 mt-3 text-xs">
            <button
              onClick={() => onEdit(address)}
              className="flex items-center gap-1 text-link hover:text-primary transition"
            >
              <Pencil className="h-3 w-3" />
              Edit
            </button>
            <button
              onClick={() => onDelete(address)}
              className="flex items-center gap-1 text-danger hover:underline transition"
            >
              <Trash2 className="h-3 w-3" />
              Delete
            </button>
            {!address.is_default && onSetDefault && (
              <button
                onClick={() => onSetDefault(address)}
                className="text-link hover:text-primary transition ml-auto"
              >
                Set as default
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ AddressCard.jsx"

# ============================================================
# 7. components/user/AddressForm.jsx
# ============================================================
cat > src/components/user/AddressForm.jsx << 'ENDOFFILE'
import { useState, useEffect } from 'react'
import Button from '../ui/Button'
import Modal from '../ui/Modal'

const EMPTY = {
  title: '',
  full_name: '',
  phone: '',
  address_line1: '',
  address_line2: '',
  city: '',
  state: '',
  country: 'US',
  zip: '',
  is_default: false,
}

export default function AddressForm({ open, onClose, onSubmit, initial = null }) {
  const [form, setForm] = useState(EMPTY)
  const [loading, setLoading] = useState(false)
  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (open) {
      setForm(initial ? { ...EMPTY, ...initial } : EMPTY)
      setErrors({})
    }
  }, [open, initial])

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const validate = () => {
    const newErrors = {}
    if (!form.title?.trim()) newErrors.title = 'Title required (e.g. Home)'
    if (!form.full_name.trim()) newErrors.full_name = 'Full name required'
    if (!form.address_line1.trim()) newErrors.address_line1 = 'Address required'
    if (!form.city.trim()) newErrors.city = 'City required'
    if (!form.zip.trim()) newErrors.zip = 'ZIP required'
    return newErrors
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const newErrors = validate()
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    setLoading(true)
    try {
      await onSubmit(form)
      onClose()
    } catch (err) {
      // handled by parent
    } finally {
      setLoading(false)
    }
  }

  const Field = ({ label, name, placeholder, required = false, half = false }) => (
    <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} {required && '*'}
      </label>
      <input
        type="text"
        value={form[name]}
        onChange={(e) => handleChange(name, e.target.value)}
        placeholder={placeholder}
        className={`w-full px-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
          errors[name]
            ? 'border-danger'
            : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
        }`}
      />
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={initial ? 'Edit Address' : 'Add New Address'}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Title" name="title" placeholder="Home / Office" required />
          <Field label="Full Name" name="full_name" placeholder="John Doe" required />
          <Field label="Phone" name="phone" placeholder="+1 234 567 8900" />
          <Field label="Address Line 1" name="address_line1" placeholder="123 Main St" required />
          <Field label="Address Line 2" name="address_line2" placeholder="Apt 4B (optional)" />
          <Field label="City" name="city" placeholder="New York" required half />
          <Field label="State" name="state" placeholder="NY" half />
          <Field label="ZIP" name="zip" placeholder="10001" required half />
          <Field label="Country" name="country" placeholder="US" half />
        </div>

        <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
          <input
            type="checkbox"
            checked={form.is_default}
            onChange={(e) => handleChange('is_default', e.target.checked)}
            className="accent-primary"
          />
          Set as default address
        </label>

        <div className="flex gap-2 justify-end pt-2">
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Saving...' : initial ? 'Update' : 'Add Address'}
          </Button>
        </div>
      </form>
    </Modal>
  )
}
ENDOFFILE

echo "✅ AddressForm.jsx"

# ============================================================
# 8. components/user/RecentOrders.jsx
# ============================================================
cat > src/components/user/RecentOrders.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { ArrowRight, Package } from 'lucide-react'
import OrderStatus from '../order/OrderStatus'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function RecentOrders({ orders = [] }) {
  if (orders.length === 0) {
    return (
      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 text-center">
        <Package className="h-12 w-12 text-gray-300 mx-auto mb-3" />
        <p className="text-sm text-gray-500">No orders yet</p>
        <Link to="/products" className="text-sm text-link hover:text-primary mt-2 inline-block">
          Start shopping →
        </Link>
      </div>
    )
  }

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
      <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <h3 className="font-bold text-secondary dark:text-white">Recent Orders</h3>
        <Link
          to="/orders"
          className="text-xs text-link hover:text-primary flex items-center gap-1"
        >
          View All <ArrowRight className="h-3 w-3" />
        </Link>
      </div>

      <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
        {orders.slice(0, 3).map((order) => (
          <Link
            key={order.id}
            to={`/orders/${order.id}`}
            className="block px-5 py-3 hover:bg-gray-50 dark:hover:bg-secondary transition"
          >
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div className="min-w-0">
                <div className="font-mono text-xs text-gray-500 mb-1">
                  {order.order_number}
                </div>
                <div className="text-xs text-gray-600 dark:text-gray-400">
                  {formatDate(order.created_at)}
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="font-bold text-sm text-primary">
                  {formatCurrency(order.total)}
                </span>
                <OrderStatus status={order.status} />
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ RecentOrders.jsx"

# ============================================================
# 9. pages/Account.jsx (Dashboard)
# ============================================================
cat > src/pages/Account.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Sparkles } from 'lucide-react'
import UserLayout from '../components/user/UserLayout'
import UserStats from '../components/user/UserStats'
import RecentOrders from '../components/user/RecentOrders'
import Spinner from '../components/ui/Spinner'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'

export default function Account() {
  const { profile } = useAuth()
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({ orders: 0, wishlist: 0, reviews: 0, total_spent: 0 })
  const [recentOrders, setRecentOrders] = useState([])

  useEffect(() => {
    Promise.all([
      api.get('/orders').catch(() => ({ data: { orders: [] } })),
      api.get('/wishlist').catch(() => ({ data: { items: [] } })),
      api.get('/comments/my').catch(() => ({ data: { comments: [] } })),
    ])
      .then(([ordersRes, wishlistRes, reviewsRes]) => {
        const orders = ordersRes.data.orders || []
        const totalSpent = orders
          .filter((o) => o.payment_status === 'paid')
          .reduce((sum, o) => sum + Number(o.total || 0), 0)

        setStats({
          orders: orders.length,
          wishlist: (wishlistRes.data.items || []).length,
          reviews: (reviewsRes.data.comments || []).length,
          total_spent: totalSpent,
        })
        setRecentOrders(orders)
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <UserLayout
      title={`Welcome back, ${profile?.full_name?.split(' ')[0] || 'there'} 👋`}
      description="Here's a quick overview of your account"
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : (
        <div className="space-y-6">
          <UserStats stats={stats} />

          <RecentOrders orders={recentOrders} />

          <div className="bg-gradient-to-r from-primary/10 to-primary-dark/10 border-2 border-primary/30 rounded-xl p-5">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                <Sparkles className="h-5 w-5 text-secondary" />
              </div>
              <div className="flex-1">
                <h3 className="font-bold text-sm text-secondary dark:text-white mb-1">
                  Need help choosing?
                </h3>
                <p className="text-xs text-gray-600 dark:text-gray-400 mb-3">
                  Try our AI-powered smart search and product comparison.
                </p>
                <div className="flex gap-2 flex-wrap">
                  <Link
                    to="/products"
                    className="text-xs bg-primary hover:bg-primary-dark text-secondary font-semibold px-4 py-2 rounded-lg inline-flex items-center gap-1 transition"
                  >
                    Browse Products <ArrowRight className="h-3 w-3" />
                  </Link>
                  <Link
                    to="/compare"
                    className="text-xs bg-white dark:bg-secondary border border-gray-300 dark:border-gray-700 hover:border-primary text-secondary dark:text-white font-semibold px-4 py-2 rounded-lg inline-flex items-center gap-1 transition"
                  >
                    Compare Products
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </UserLayout>
  )
}
ENDOFFILE

echo "✅ Account.jsx"

# ============================================================
# 10. pages/AccountProfile.jsx
# ============================================================
cat > src/pages/AccountProfile.jsx << 'ENDOFFILE'
import UserLayout from '../components/user/UserLayout'
import ProfileForm from '../components/user/ProfileForm'

export default function AccountProfile() {
  return (
    <UserLayout
      title="Profile"
      description="Manage your personal information"
    >
      <ProfileForm />
    </UserLayout>
  )
}
ENDOFFILE

echo "✅ AccountProfile.jsx"

# ============================================================
# 11. pages/AccountAddresses.jsx
# ============================================================
cat > src/pages/AccountAddresses.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Plus, MapPin } from 'lucide-react'
import toast from 'react-hot-toast'
import UserLayout from '../components/user/UserLayout'
import AddressCard from '../components/user/AddressCard'
import AddressForm from '../components/user/AddressForm'
import Button from '../components/ui/Button'
import Spinner from '../components/ui/Spinner'
import { supabase } from '../lib/supabase'
import { useAuth } from '../context/AuthContext'

export default function AccountAddresses() {
  const { user } = useAuth()
  const [addresses, setAddresses] = useState([])
  const [loading, setLoading] = useState(true)
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState(null)

  const load = async () => {
    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('addresses')
        .select('*')
        .eq('user_id', user.id)
        .order('is_default', { ascending: false })
        .order('created_at', { ascending: false })
      if (error) throw error
      setAddresses(data || [])
    } catch (err) {
      console.error(err)
      toast.error('Failed to load addresses')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (user) load()
  }, [user])

  const handleAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const handleEdit = (address) => {
    setEditing(address)
    setFormOpen(true)
  }

  const handleDelete = async (address) => {
    if (!confirm('Delete this address?')) return
    try {
      const { error } = await supabase
        .from('addresses')
        .delete()
        .eq('id', address.id)
      if (error) throw error
      toast.success('Address deleted')
      load()
    } catch (err) {
      toast.error('Failed to delete')
    }
  }

  const handleSetDefault = async (address) => {
    try {
      await supabase
        .from('addresses')
        .update({ is_default: false })
        .eq('user_id', user.id)
      const { error } = await supabase
        .from('addresses')
        .update({ is_default: true })
        .eq('id', address.id)
      if (error) throw error
      toast.success('Default address updated')
      load()
    } catch (err) {
      toast.error('Failed')
    }
  }

  const handleSubmit = async (form) => {
    try {
      if (form.is_default) {
        await supabase
          .from('addresses')
          .update({ is_default: false })
          .eq('user_id', user.id)
      }

      if (editing) {
        const { error } = await supabase
          .from('addresses')
          .update(form)
          .eq('id', editing.id)
        if (error) throw error
        toast.success('Address updated')
      } else {
        const { error } = await supabase
          .from('addresses')
          .insert({ ...form, user_id: user.id })
        if (error) throw error
        toast.success('Address added')
      }
      load()
    } catch (err) {
      toast.error(err.message || 'Failed to save')
      throw err
    }
  }

  return (
    <UserLayout
      title="Addresses"
      description="Manage your delivery addresses"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="h-4 w-4" />
          Add Address
        </Button>
      }
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : addresses.length === 0 ? (
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
          <MapPin className="h-12 w-12 text-gray-300 mx-auto mb-3" />
          <h3 className="font-bold mb-2 text-secondary dark:text-white">
            No addresses yet
          </h3>
          <p className="text-sm text-gray-500 mb-5">
            Add your first delivery address
          </p>
          <Button onClick={handleAdd}>
            <Plus className="h-4 w-4" />
            Add Address
          </Button>
        </div>
      ) : (
        <div className="space-y-3">
          {addresses.map((address) => (
            <AddressCard
              key={address.id}
              address={address}
              onEdit={handleEdit}
              onDelete={handleDelete}
              onSetDefault={handleSetDefault}
            />
          ))}
        </div>
      )}

      <AddressForm
        open={formOpen}
        onClose={() => setFormOpen(false)}
        onSubmit={handleSubmit}
        initial={editing}
      />
    </UserLayout>
  )
}
ENDOFFILE

echo "✅ AccountAddresses.jsx"

# ============================================================
# 12. pages/AccountReviews.jsx
# ============================================================
cat > src/pages/AccountReviews.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { MessageSquare, Star } from 'lucide-react'
import UserLayout from '../components/user/UserLayout'
import RatingStars from '../components/product/RatingStars'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'
import { formatRelativeTime } from '../lib/utils'

export default function AccountReviews() {
  const [reviews, setReviews] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/comments/my')
      .then((res) => setReviews(res.data.comments || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  return (
    <UserLayout
      title="My Reviews"
      description="Reviews you've written"
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : reviews.length === 0 ? (
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
          <MessageSquare className="h-12 w-12 text-gray-300 mx-auto mb-3" />
          <h3 className="font-bold mb-2 text-secondary dark:text-white">
            No reviews yet
          </h3>
          <p className="text-sm text-gray-500 mb-5">
            Buy a product and share your thoughts
          </p>
          <Link to="/products" className="text-link hover:text-primary text-sm">
            Browse products →
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {reviews.map((review) => (
            <div
              key={review.id}
              className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-4"
            >
              <div className="flex gap-3">
                <Link to={`/products/${review.product?.slug}`} className="flex-shrink-0">
                  <img
                    src={review.product?.thumbnail}
                    alt=""
                    className="w-16 h-16 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
                  />
                </Link>
                <div className="flex-1 min-w-0">
                  <Link
                    to={`/products/${review.product?.slug}`}
                    className="font-medium text-sm text-secondary dark:text-white hover:text-primary transition line-clamp-2"
                  >
                    {review.product?.title}
                  </Link>
                  <div className="flex items-center gap-2 mt-1.5">
                    <RatingStars rating={review.rating} />
                    <span className="text-xs text-gray-500">
                      {formatRelativeTime(review.created_at)}
                    </span>
                  </div>
                  {review.title && (
                    <div className="font-semibold text-xs mt-2 text-secondary dark:text-white">
                      {review.title}
                    </div>
                  )}
                  <p className="text-xs text-gray-600 dark:text-gray-400 mt-1 leading-relaxed">
                    {review.text}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </UserLayout>
  )
}
ENDOFFILE

echo "✅ AccountReviews.jsx"

# ============================================================
# 13. pages/AccountSettings.jsx
# ============================================================
cat > src/pages/AccountSettings.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { Lock, Bell, Trash2, AlertTriangle } from 'lucide-react'
import toast from 'react-hot-toast'
import UserLayout from '../components/user/UserLayout'
import PasswordInput from '../components/auth/PasswordInput'
import Button from '../components/ui/Button'
import { useProfile } from '../hooks/useProfile'

export default function AccountSettings() {
  const { changePassword } = useProfile()
  const [form, setForm] = useState({
    current_password: '',
    new_password: '',
    confirm_password: '',
  })
  const [errors, setErrors] = useState({})
  const [saving, setSaving] = useState(false)

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handlePasswordSubmit = async (e) => {
    e.preventDefault()
    const newErrors = {}
    if (!form.current_password) newErrors.current_password = 'Current password required'
    if (form.new_password.length < 8) newErrors.new_password = 'Min 8 characters'
    if (form.new_password !== form.confirm_password) {
      newErrors.confirm_password = 'Passwords do not match'
    }
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }

    setSaving(true)
    try {
      await changePassword({
        current_password: form.current_password,
        new_password: form.new_password,
      })
      toast.success('Password changed')
      setForm({ current_password: '', new_password: '', confirm_password: '' })
    } catch (err) {
      toast.error(err.message || 'Failed to change password')
    } finally {
      setSaving(false)
    }
  }

  return (
    <UserLayout
      title="Settings"
      description="Manage your account settings"
    >
      <div className="space-y-6">
        {/* Change Password */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
          <h2 className="font-bold text-secondary dark:text-white mb-1 flex items-center gap-2">
            <Lock className="h-5 w-5 text-primary" />
            Change Password
          </h2>
          <p className="text-xs text-gray-500 mb-5">
            Update your account password
          </p>

          <form onSubmit={handlePasswordSubmit} className="space-y-4 max-w-md">
            <PasswordInput
              value={form.current_password}
              onChange={(e) => handleChange('current_password', e.target.value)}
              error={errors.current_password}
              placeholder="Current password"
              autoComplete="current-password"
            />
            <PasswordInput
              value={form.new_password}
              onChange={(e) => handleChange('new_password', e.target.value)}
              error={errors.new_password}
              placeholder="New password"
              autoComplete="new-password"
            />
            <PasswordInput
              value={form.confirm_password}
              onChange={(e) => handleChange('confirm_password', e.target.value)}
              error={errors.confirm_password}
              placeholder="Confirm new password"
              autoComplete="new-password"
            />
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving...' : 'Change Password'}
            </Button>
          </form>
        </div>

        {/* Notifications (placeholder) */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
          <h2 className="font-bold text-secondary dark:text-white mb-1 flex items-center gap-2">
            <Bell className="h-5 w-5 text-primary" />
            Notifications
          </h2>
          <p className="text-xs text-gray-500 mb-5">
            Choose what emails you want to receive
          </p>
          <div className="space-y-3">
            {['Order updates', 'Promotions', 'New arrivals', 'Price drops on wishlist'].map((label) => (
              <label key={label} className="flex items-center gap-3 text-sm text-secondary dark:text-white cursor-pointer">
                <input
                  type="checkbox"
                  defaultChecked
                  className="accent-primary w-4 h-4"
                />
                {label}
              </label>
            ))}
          </div>
        </div>

        {/* Danger Zone */}
        <div className="bg-red-50 dark:bg-red-900/10 border-2 border-danger/30 rounded-xl p-6">
          <h2 className="font-bold text-danger mb-1 flex items-center gap-2">
            <AlertTriangle className="h-5 w-5" />
            Danger Zone
          </h2>
          <p className="text-xs text-gray-600 dark:text-gray-400 mb-5">
            Once you delete your account, there is no going back.
          </p>
          <Button
            variant="danger"
            onClick={() => toast.error('Account deletion requires support. Contact us.')}
          >
            <Trash2 className="h-4 w-4" />
            Delete Account
          </Button>
        </div>
      </div>
    </UserLayout>
  )
}
ENDOFFILE

echo "✅ AccountSettings.jsx"

# ============================================================
# 14. App.jsx (آپدیت)
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

                  <Route path="/login" element={<Login />} />
                  <Route path="/register" element={<Register />} />
                  <Route path="/forgot-password" element={<ForgotPassword />} />
                  <Route path="/reset-password" element={<ResetPassword />} />
                  <Route path="/auth/callback" element={<AuthCallback />} />
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
echo "🎉 User Panel done!"
echo ""
echo "📋 Next:"
echo "   1. cd ~/Rostam-Full-site/client"
echo "   2. pkill -f vite"
echo "   3. npm run dev"
echo ""
echo "🧪 Test:"
echo "   1. Login"
echo "   2. Go to /account"
echo "   3. Navigate: /account/profile, /account/addresses, /account/reviews, /account/settings"
echo ""
