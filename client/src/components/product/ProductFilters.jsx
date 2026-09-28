import { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { api } from '../../lib/api'
import { priceRanges, ratingFilters } from '../../lib/productHelpers'
import RatingStars from './RatingStars'

export default function ProductFilters({ filters, onChange, onClose }) {
  const [categories, setCategories] = useState([])
  const [brands, setBrands] = useState([])

  useEffect(() => {
    api.get('/categories').then((res) => setCategories(res.data.categories || []))
    api.get('/brands').then((res) => setBrands(res.data.brands || []))
  }, [])

  const updateFilter = (key, value) => {
    onChange({ ...filters, [key]: value, page: 1 })
  }

  const toggleArrayFilter = (key, value) => {
    const current = filters[key] || ''
    if (current === value) updateFilter(key, '')
    else updateFilter(key, value)
  }

  const clearAll = () => {
    onChange({ q: '', category: '', brand: '', minPrice: '', maxPrice: '', rating: '', prime: false, inStock: false, sort: 'featured', page: 1 })
  }

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-5 shadow-card">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-bold text-secondary dark:text-white">Filters</h3>
        <div className="flex items-center gap-2">
          <button onClick={clearAll} className="text-xs text-link hover:text-primary">Clear all</button>
          {onClose && (
            <button onClick={onClose} className="lg:hidden p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded">
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
      </div>

      {/* Category */}
      <div className="border-t border-gray-200 dark:border-gray-700 pt-4 mb-4">
        <h4 className="text-sm font-semibold mb-2 text-secondary dark:text-white">Category</h4>
        <div className="space-y-1.5 max-h-48 overflow-y-auto">
          <label className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
            <input type="radio" name="category" checked={filters.category === ''} onChange={() => updateFilter('category', '')} className="accent-primary" />
            All Categories
          </label>
          {categories.filter((c) => !c.parent_id).map((c) => (
            <label key={c.id} className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
              <input type="radio" name="category" checked={filters.category === c.slug} onChange={() => updateFilter('category', c.slug)} className="accent-primary" />
              {c.name}
            </label>
          ))}
        </div>
      </div>

      {/* Brand */}
      <div className="border-t border-gray-200 dark:border-gray-700 pt-4 mb-4">
        <h4 className="text-sm font-semibold mb-2 text-secondary dark:text-white">Brand</h4>
        <div className="space-y-1.5 max-h-48 overflow-y-auto">
          <label className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
            <input type="radio" name="brand" checked={filters.brand === ''} onChange={() => updateFilter('brand', '')} className="accent-primary" />
            All Brands
          </label>
          {brands.slice(0, 12).map((b) => (
            <label key={b.id} className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
              <input type="radio" name="brand" checked={filters.brand === b.slug} onChange={() => updateFilter('brand', b.slug)} className="accent-primary" />
              {b.name}
            </label>
          ))}
        </div>
      </div>

      {/* Price */}
      <div className="border-t border-gray-200 dark:border-gray-700 pt-4 mb-4">
        <h4 className="text-sm font-semibold mb-2 text-secondary dark:text-white">Price</h4>
        <div className="space-y-1.5">
          {priceRanges.map((range) => (
            <label key={range.label} className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
              <input
                type="radio"
                name="price"
                checked={
                  String(filters.minPrice) === String(range.min) &&
                  String(filters.maxPrice) === String(range.max || '')
                }
                onChange={() => {
                  onChange({ ...filters, minPrice: range.min, maxPrice: range.max || '', page: 1 })
                }}
                className="accent-primary"
              />
              {range.label}
            </label>
          ))}
        </div>
      </div>

      {/* Rating */}
      <div className="border-t border-gray-200 dark:border-gray-700 pt-4 mb-4">
        <h4 className="text-sm font-semibold mb-2 text-secondary dark:text-white">Customer Review</h4>
        <div className="space-y-1.5">
          {ratingFilters.map((r) => (
            <label key={r.value} className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
              <input
                type="radio"
                name="rating"
                checked={String(filters.rating) === String(r.value)}
                onChange={() => updateFilter('rating', r.value)}
                className="accent-primary"
              />
              <RatingStars rating={r.value} />
              <span>& Up</span>
            </label>
          ))}
        </div>
      </div>

      {/* Prime / Stock */}
      <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
        <label className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary mb-2">
          <input type="checkbox" checked={filters.prime} onChange={(e) => updateFilter('prime', e.target.checked)} className="accent-primary" />
          Prime Only
        </label>
        <label className="flex items-center gap-2 text-sm cursor-pointer hover:text-primary">
          <input type="checkbox" checked={filters.inStock} onChange={(e) => updateFilter('inStock', e.target.checked)} className="accent-primary" />
          In Stock Only
        </label>
      </div>
    </div>
  )
}
