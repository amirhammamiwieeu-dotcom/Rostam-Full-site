#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

cp src/pages/admin/AdminProductForm.jsx src/pages/admin/AdminProductForm.jsx.backup-$(date +%s) 2>/dev/null || true

cat > src/pages/admin/AdminProductForm.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Save, ArrowLeft, Tag } from 'lucide-react'
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
  brand_name: '',
  thumbnail: '',
  images: [],
  features: [],
  is_active: true,
  is_featured: false,
  is_prime: false,
  status: 'published',
}

// ============================================================
// 🎯 OUTSIDE components — prevents re-mounting on every render
// ============================================================
const InputField = ({ label, name, type = 'text', placeholder = '', value, onChange, error, required, half }) => (
  <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
    <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
      {label} {required && <span className="text-danger">*</span>}
    </label>
    <input
      type={type}
      name={name}
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      className={`w-full px-3.5 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
        error ? 'border-danger' : 'border-gray-300 dark:border-gray-700 focus:border-primary'
      }`}
    />
    {error && <p className="mt-1 text-xs text-danger">{error}</p>}
  </div>
)

const TextareaField = ({ label, name, placeholder = '', value, onChange, error, rows = 3 }) => (
  <div className="md:col-span-2">
    <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
      {label}
    </label>
    <textarea
      name={name}
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      rows={rows}
      className={`w-full px-3.5 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
        error ? 'border-danger' : 'border-gray-300 dark:border-gray-700 focus:border-primary'
      }`}
    />
    {error && <p className="mt-1 text-xs text-danger">{error}</p>}
  </div>
)

const SelectField = ({ label, name, value, onChange, options, half }) => (
  <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
    <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
      {label}
    </label>
    <select
      name={name}
      value={value}
      onChange={onChange}
      className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
    >
      {options.map((opt) => (
        <option key={opt.value} value={opt.value}>
          {opt.label}
        </option>
      ))}
    </select>
  </div>
)

// ============================================================
// Main component
// ============================================================
export default function AdminProductForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const isEdit = !!id

  const [form, setForm] = useState(EMPTY)
  const [categories, setCategories] = useState([])
  const [featuresText, setFeaturesText] = useState('')
  const [loading, setLoading] = useState(isEdit)
  const [loadingMeta, setLoadingMeta] = useState(true)
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState({})

  // Load categories
  useEffect(() => {
    let cancelled = false
    setLoadingMeta(true)

    api.get('/categories')
      .then((res) => {
        if (!cancelled) {
          const cats = res.data.categories || []
          console.log('✅ Loaded categories:', cats.length)
          setCategories(cats)
        }
      })
      .catch((err) => {
        console.error('❌ Categories load failed:', err)
        if (!cancelled) setCategories([])
      })
      .finally(() => {
        if (!cancelled) setLoadingMeta(false)
      })

    return () => { cancelled = true }
  }, [])

  // Load product if editing
  useEffect(() => {
    if (!isEdit) {
      setLoading(false)
      return
    }

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
          brand_name: p.brand?.name || '',
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
        console.error(err)
        toast.error('Failed to load product')
        navigate('/admin/products')
      })
      .finally(() => setLoading(false))
  }, [id, isEdit, navigate])

  // 🎯 Stable onChange handler
  const handleChange = (e) => {
    const { name, value } = e.target
    setForm((f) => ({ ...f, [name]: value }))
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: null }))
  }

  // For custom fields (ImageUpload, features)
  const setField = (name, value) => {
    setForm((f) => ({ ...f, [name]: value }))
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: null }))
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
        title: form.title,
        short_description: form.short_description,
        description: form.description,
        price: Number(form.price),
        old_price: form.old_price ? Number(form.old_price) : undefined,
        stock: Number(form.stock),
        category_id: form.category_id || undefined,
        brand_name: form.brand_name.trim() || undefined,
        thumbnail: form.thumbnail || undefined,
        images: form.images,
        features: featuresText.split('\n').map((f) => f.trim()).filter(Boolean),
        is_active: form.is_active,
        is_featured: form.is_featured,
        is_prime: form.is_prime,
        status: form.status,
      }

      console.log('📤 Submitting product:', payload)

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

  if (loading || loadingMeta) {
    return (
      <AdminLayout title="Loading...">
        <div className="flex flex-col items-center justify-center py-16">
          <Spinner size="lg" />
          <p className="text-sm text-gray-500 mt-4">Loading form data...</p>
        </div>
      </AdminLayout>
    )
  }

  const categoryOptions = [
    { value: '', label: '— No Category —' },
    ...categories.map((c) => ({
      value: c.id,
      label: c.parent_id ? `↳ ${c.name}` : c.name,
    })),
  ]

  const statusOptions = [
    { value: 'published', label: 'Published' },
    { value: 'draft', label: 'Draft' },
    { value: 'archived', label: 'Archived' },
  ]

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
          <InputField
            label="Title"
            name="title"
            placeholder="Product title"
            value={form.title}
            onChange={handleChange}
            error={errors.title}
            required
          />
          <TextareaField
            label="Short Description"
            name="short_description"
            placeholder="Brief description"
            value={form.short_description}
            onChange={handleChange}
            rows={2}
          />
          <TextareaField
            label="Description"
            name="description"
            placeholder="Full description"
            value={form.description}
            onChange={handleChange}
            rows={4}
          />

          <InputField
            label="Price ($)"
            name="price"
            type="number"
            placeholder="99.99"
            value={form.price}
            onChange={handleChange}
            error={errors.price}
            required
            half
          />
          <InputField
            label="Old Price ($)"
            name="old_price"
            type="number"
            placeholder="129.99"
            value={form.old_price}
            onChange={handleChange}
            half
          />
          <InputField
            label="Stock"
            name="stock"
            type="number"
            placeholder="10"
            value={form.stock}
            onChange={handleChange}
            error={errors.stock}
            required
            half
          />
          <SelectField
            label="Status"
            name="status"
            value={form.status}
            onChange={handleChange}
            options={statusOptions}
            half
          />

          <SelectField
            label="Category"
            name="category_id"
            value={form.category_id}
            onChange={handleChange}
            options={categoryOptions}
            half
          />

          {/* Brand — text input */}
          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Brand
            </label>
            <div className="relative">
              <Tag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
              <input
                type="text"
                name="brand_name"
                value={form.brand_name}
                onChange={handleChange}
                placeholder="Apple, Samsung, Sony..."
                className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
              />
            </div>
            <p className="mt-1 text-xs text-gray-500">
              New brands are created automatically
            </p>
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
              onChange={(url) => setField('thumbnail', url)}
            />
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Gallery Images (up to 6)
            </label>
            <ImageUpload
              value={form.images}
              onChange={(urls) => setField('images', urls)}
              multiple
              max={6}
            />
          </div>
        </div>

        <div className="flex flex-wrap gap-4 mb-6 pb-6 border-b border-gray-200 dark:border-gray-700">
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input
              type="checkbox"
              checked={form.is_active}
              onChange={(e) => setField('is_active', e.target.checked)}
              className="accent-primary w-4 h-4"
            />
            Active
          </label>
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input
              type="checkbox"
              checked={form.is_featured}
              onChange={(e) => setField('is_featured', e.target.checked)}
              className="accent-primary w-4 h-4"
            />
            Featured
          </label>
          <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
            <input
              type="checkbox"
              checked={form.is_prime}
              onChange={(e) => setField('is_prime', e.target.checked)}
              className="accent-primary w-4 h-4"
            />
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

echo "✅ AdminProductForm.jsx rewritten (no input lag)"
