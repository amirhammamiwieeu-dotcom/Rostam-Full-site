#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🔧 Fixing Category..."
echo ""

# ============================================================
# 1. AdminProductForm.jsx — با Category درست
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
  const [loadingMeta, setLoadingMeta] = useState(true)
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState({})

  // Load categories + brands (once)
  useEffect(() => {
    let cancelled = false
    setLoadingMeta(true)

    Promise.all([
      api.get('/categories').catch((err) => {
        console.error('Categories load failed:', err)
        return { data: { categories: [] } }
      }),
      api.get('/brands').catch((err) => {
        console.error('Brands load failed:', err)
        return { data: { brands: [] } }
      }),
    ]).then(([catRes, brandRes]) => {
      if (cancelled) return
      const cats = catRes.data?.categories || []
      const brs = brandRes.data?.brands || []
      console.log('✅ Loaded categories:', cats.length)
      console.log('✅ Loaded brands:', brs.length)
      setCategories(cats)
      setBrands(brs)
      setLoadingMeta(false)
    })

    return () => {
      cancelled = true
    }
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
        console.error(err)
        toast.error('Failed to load product')
        navigate('/admin/products')
      })
      .finally(() => setLoading(false))
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

          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Status
            </label>
            <select
              value={form.status}
              onChange={(e) => handleChange('status', e.target.value)}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              <option value="published">Published</option>
              <option value="draft">Draft</option>
              <option value="archived">Archived</option>
            </select>
          </div>

          {/* Category */}
          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Category
            </label>
            <select
              value={form.category_id}
              onChange={(e) => handleChange('category_id', e.target.value)}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              <option value="">— No Category —</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.parent_id ? `↳ ${c.name}` : c.name}
                </option>
              ))}
            </select>
            {categories.length === 0 && (
              <p className="mt-1 text-xs text-yellow-600">
                ⚠️ No categories loaded. Check the API.
              </p>
            )}
          </div>

          {/* Brand */}
          <div className="md:col-span-1">
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
              Brand
            </label>
            <select
              value={form.brand_id}
              onChange={(e) => handleChange('brand_id', e.target.value)}
              className="w-full px-3.5 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              <option value="">— No Brand —</option>
              {brands.map((b) => (
                <option key={b.id} value={b.id}>{b.name}</option>
              ))}
            </select>
            {brands.length === 0 && (
              <p className="mt-1 text-xs text-yellow-600">
                ⚠️ No brands loaded.
              </p>
            )}
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

echo "✅ AdminProductForm.jsx updated"

# ============================================================
# 2. backend product.service.js — createProduct باید category_id رو قبول کنه
# ============================================================
cd "$SCRIPT_DIR/server"

echo "🔧 Checking backend category support..."
grep -n "category_id" src/services/product.service.js | head -5

echo ""
echo "🎉 Done!"
echo ""
echo "📋 Next:"
echo "   1. Restart Backend (Ctrl+C → npm run dev)"
echo "   2. Restart Frontend (Ctrl+C → npm run dev)"
echo "   3. Test /admin/products/new"
echo ""
