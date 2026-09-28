#!/bin/bash

set -e

echo "🚀 Creating Products pages..."

cd client

# ساخت پوشه‌ها
mkdir -p src/components/product
mkdir -p src/pages
mkdir -p src/lib

# ============================================================
# 1. lib/productHelpers.js
# ============================================================
cat > src/lib/productHelpers.js << 'EOF'
export const calculateDiscount = (price, oldPrice) => {
  if (!oldPrice || oldPrice <= price) return 0
  return Math.round((1 - price / oldPrice) * 100)
}

export const buildQueryString = (params) => {
  const query = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    if (value !== null && value !== undefined && value !== '') {
      query.append(key, value)
    }
  })
  return query.toString()
}

export const parseFiltersFromURL = (searchParams) => {
  return {
    q: searchParams.get('q') || '',
    category: searchParams.get('category') || '',
    brand: searchParams.get('brand') || '',
    minPrice: searchParams.get('minPrice') || '',
    maxPrice: searchParams.get('maxPrice') || '',
    rating: searchParams.get('rating') || '',
    prime: searchParams.get('prime') === 'true',
    inStock: searchParams.get('inStock') === 'true',
    sort: searchParams.get('sort') || 'featured',
    page: parseInt(searchParams.get('page')) || 1,
  }
}

export const sortOptions = [
  { value: 'featured', label: 'Featured' },
  { value: 'price-asc', label: 'Price: Low to High' },
  { value: 'price-desc', label: 'Price: High to Low' },
  { value: 'rating', label: 'Avg. Customer Review' },
  { value: 'newest', label: 'Newest Arrivals' },
  { value: 'discount', label: 'Biggest Discount' },
  { value: 'popular', label: 'Best Sellers' },
]

export const ratingFilters = [
  { value: 4, label: '4 Stars & Up' },
  { value: 3, label: '3 Stars & Up' },
  { value: 2, label: '2 Stars & Up' },
  { value: 1, label: '1 Star & Up' },
]

export const priceRanges = [
  { min: 0, max: 25, label: 'Under $25' },
  { min: 25, max: 50, label: '$25 to $50' },
  { min: 50, max: 100, label: '$50 to $100' },
  { min: 100, max: 200, label: '$100 to $200' },
  { min: 200, max: 500, label: '$200 to $500' },
  { min: 500, max: null, label: '$500 & Above' },
]
EOF

# ============================================================
# 2. RatingStars.jsx
# ============================================================
cat > src/components/product/RatingStars.jsx << 'EOF'
import { Star } from 'lucide-react'

export default function RatingStars({ rating = 0, size = 'sm', showValue = false, count = null }) {
  const sizes = { sm: 'h-3.5 w-3.5', md: 'h-4 w-4', lg: 'h-5 w-5' }
  const starSize = sizes[size] || sizes.sm

  return (
    <div className="flex items-center gap-1">
      <div className="flex">
        {[1, 2, 3, 4, 5].map((star) => {
          const fill = Math.min(Math.max(rating - star + 1, 0), 1)
          return (
            <div key={star} className="relative">
              <Star className={`${starSize} text-gray-300`} />
              <div
                className="absolute inset-0 overflow-hidden"
                style={{ width: `${fill * 100}%` }}
              >
                <Star className={`${starSize} text-yellow-500 fill-yellow-500`} />
              </div>
            </div>
          )
        })}
      </div>
      {showValue && (
        <span className="text-xs text-link hover:text-primary cursor-pointer">
          {rating.toFixed(1)}
        </span>
      )}
      {count !== null && (
        <span className="text-xs text-gray-500">({count.toLocaleString()})</span>
      )}
    </div>
  )
}
EOF

# ============================================================
# 3. ProductCard.jsx
# ============================================================
cat > src/components/product/ProductCard.jsx << 'EOF'
import { Link, useNavigate } from 'react-router-dom'
import { Heart, ShoppingCart, TrendingUp } from 'lucide-react'
import toast from 'react-hot-toast'
import RatingStars from './RatingStars'
import { formatCurrency } from '../../lib/utils'
import { calculateDiscount } from '../../lib/productHelpers'
import { useCart } from '../../context/CartContext'
import { useWishlist } from '../../context/WishlistContext'
import { useAuth } from '../../context/AuthContext'

export default function ProductCard({ product, compact = false }) {
  const navigate = useNavigate()
  const { addToCart } = useCart()
  const { toggleWishlist, isWished } = useWishlist()
  const { user } = useAuth()

  const discount = calculateDiscount(product.price, product.old_price)
  const wished = isWished(product.id)

  const handleAddToCart = async (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (!user) {
      toast.error('Please sign in to add items')
      navigate('/login')
      return
    }
    try {
      await addToCart(product.id, 1)
      toast.success('Added to cart')
    } catch (err) {
      toast.error(err.message || 'Failed to add to cart')
    }
  }

  const handleWishlist = async (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      const result = await toggleWishlist(product.id)
      toast.success(result.added ? 'Added to wishlist' : 'Removed from wishlist')
    } catch (err) {
      toast.error('Failed to update wishlist')
    }
  }

  return (
    <Link
      to={`/products/${product.slug}`}
      className="group bg-white dark:bg-secondary-light rounded-xl p-3 hover:shadow-xl hover:-translate-y-1 transition-all duration-200 border border-gray-100 dark:border-gray-800"
    >
      <div className="relative">
        <div className="w-full h-40 flex items-center justify-center overflow-hidden rounded-lg bg-gray-50 dark:bg-secondary mb-3">
          <img
            src={product.thumbnail}
            alt={product.title}
            className="max-h-full max-w-full object-contain group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        </div>

        {discount > 0 && (
          <span className="absolute top-2 left-2 bg-primary text-secondary text-xs font-bold px-2 py-0.5 rounded-full">
            -{discount}%
          </span>
        )}

        <button
          onClick={handleWishlist}
          className={`absolute top-2 right-2 w-8 h-8 rounded-full bg-white/90 dark:bg-secondary flex items-center justify-center transition shadow ${
            wished ? 'text-danger' : 'text-gray-400 hover:text-danger'
          }`}
          aria-label="Add to wishlist"
        >
          <Heart className={`h-4 w-4 ${wished ? 'fill-danger' : ''}`} />
        </button>
      </div>

      <div>
        <h3 className="text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-1.5 min-h-[40px]">
          {product.title}
        </h3>

        <div className="mb-2">
          <RatingStars
            rating={product.rating || 0}
            showValue
            count={product.num_reviews}
          />
        </div>

        <div className="flex items-baseline gap-2 mb-2">
          <span className="text-lg font-bold text-secondary dark:text-white">
            {formatCurrency(product.price)}
          </span>
          {product.old_price && (
            <span className="text-xs text-gray-400 line-through">
              {formatCurrency(product.old_price)}
            </span>
          )}
        </div>

        {product.is_prime && (
          <div className="flex items-center gap-1 text-xs text-link mb-2">
            <TrendingUp className="h-3 w-3" />
            <span className="font-semibold">Prime</span>
          </div>
        )}

        {!compact && (
          <button
            onClick={handleAddToCart}
            className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-semibold text-sm py-2 rounded-lg transition"
          >
            <ShoppingCart className="h-4 w-4" />
            Add to Cart
          </button>
        )}
      </div>
    </Link>
  )
}
EOF

# ============================================================
# 4. ProductSkeleton.jsx
# ============================================================
cat > src/components/product/ProductSkeleton.jsx << 'EOF'
export default function ProductSkeleton() {
  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-3 animate-pulse">
      <div className="w-full h-40 bg-gray-200 dark:bg-gray-700 rounded-lg mb-3" />
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2" />
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 mb-2" />
      <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-1/2 mb-2" />
      <div className="h-5 bg-gray-200 dark:bg-gray-700 rounded w-1/3 mb-3" />
      <div className="h-9 bg-gray-200 dark:bg-gray-700 rounded" />
    </div>
  )
}
EOF

# ============================================================
# 5. ProductGrid.jsx
# ============================================================
cat > src/components/product/ProductGrid.jsx << 'EOF'
import ProductCard from './ProductCard'
import ProductSkeleton from './ProductSkeleton'

export default function ProductGrid({ products, loading, columns = 4 }) {
  const cols = {
    2: 'grid-cols-1 sm:grid-cols-2',
    3: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3',
    4: 'grid-cols-2 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4',
    5: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5',
  }

  if (loading) {
    return (
      <div className={`grid ${cols[columns]} gap-4`}>
        {Array.from({ length: 8 }).map((_, i) => (
          <ProductSkeleton key={i} />
        ))}
      </div>
    )
  }

  if (!products || products.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500">No products found</p>
      </div>
    )
  }

  return (
    <div className={`grid ${cols[columns]} gap-4`}>
      {products.map((p) => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  )
}
EOF

# ============================================================
# 6. ProductFilters.jsx
# ============================================================
cat > src/components/product/ProductFilters.jsx << 'EOF'
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
EOF

# ============================================================
# 7. ProductSort.jsx
# ============================================================
cat > src/components/product/ProductSort.jsx << 'EOF'
import { sortOptions } from '../../lib/productHelpers'

export default function ProductSort({ value, onChange }) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
    >
      {sortOptions.map((opt) => (
        <option key={opt.value} value={opt.value}>
          {opt.label}
        </option>
      ))}
    </select>
  )
}
EOF

# ============================================================
# 8. ProductPagination.jsx
# ============================================================
cat > src/components/product/ProductPagination.jsx << 'EOF'
import { ChevronLeft, ChevronRight } from 'lucide-react'

export default function ProductPagination({ page, pages, onPageChange }) {
  if (pages <= 1) return null

  const getPages = () => {
    const arr = []
    const maxShow = 5
    let start = Math.max(1, page - Math.floor(maxShow / 2))
    let end = Math.min(pages, start + maxShow - 1)
    if (end - start + 1 < maxShow) start = Math.max(1, end - maxShow + 1)
    for (let i = start; i <= end; i++) arr.push(i)
    return arr
  }

  return (
    <div className="flex items-center justify-center gap-2 mt-8">
      <button
        onClick={() => onPageChange(page - 1)}
        disabled={page === 1}
        className="w-9 h-9 rounded-lg border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
      >
        <ChevronLeft className="h-4 w-4" />
      </button>

      {getPages().map((p) => (
        <button
          key={p}
          onClick={() => onPageChange(p)}
          className={`w-9 h-9 rounded-lg border text-sm font-medium transition ${
            p === page
              ? 'bg-primary text-secondary border-primary'
              : 'border-gray-300 dark:border-gray-700 hover:border-primary hover:text-primary'
          }`}
        >
          {p}
        </button>
      ))}

      <button
        onClick={() => onPageChange(page + 1)}
        disabled={page === pages}
        className="w-9 h-9 rounded-lg border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
      >
        <ChevronRight className="h-4 w-4" />
      </button>
    </div>
  )
}
EOF

# ============================================================
# 9. ProductGallery.jsx
# ============================================================
cat > src/components/product/ProductGallery.jsx << 'EOF'
import { useState } from 'react'

export default function ProductGallery({ images = [], thumbnail }) {
  const allImages = images.length > 0 ? images : [thumbnail]
  const [selected, setSelected] = useState(0)

  return (
    <div className="flex flex-col gap-4">
      <div className="w-full aspect-square bg-gray-50 dark:bg-secondary rounded-xl overflow-hidden flex items-center justify-center">
        <img
          src={allImages[selected]}
          alt="Product"
          className="max-w-full max-h-full object-contain"
        />
      </div>

      {allImages.length > 1 && (
        <div className="flex gap-2 overflow-x-auto pb-2">
          {allImages.map((img, i) => (
            <button
              key={i}
              onClick={() => setSelected(i)}
              className={`flex-shrink-0 w-16 h-16 rounded-lg overflow-hidden border-2 transition ${
                i === selected
                  ? 'border-primary'
                  : 'border-gray-200 dark:border-gray-700 hover:border-primary'
              }`}
            >
              <img src={img} alt="" className="w-full h-full object-cover" />
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
EOF

# ============================================================
# 10. ProductPrice.jsx
# ============================================================
cat > src/components/product/ProductPrice.jsx << 'EOF'
import { formatCurrency } from '../../lib/utils'
import { calculateDiscount } from '../../lib/productHelpers'

export default function ProductPrice({ price, oldPrice, size = 'md' }) {
  const discount = calculateDiscount(price, oldPrice)
  const sizes = {
    sm: 'text-base',
    md: 'text-2xl',
    lg: 'text-3xl',
  }

  return (
    <div className="flex flex-wrap items-baseline gap-2">
      <span className={`${sizes[size]} font-bold text-secondary dark:text-white`}>
        {formatCurrency(price)}
      </span>
      {oldPrice && discount > 0 && (
        <>
          <span className="text-sm text-gray-400 line-through">
            {formatCurrency(oldPrice)}
          </span>
          <span className="text-sm font-bold text-primary">
            Save {discount}%
          </span>
        </>
      )}
    </div>
  )
}
EOF

# ============================================================
# 11. AddToCartButton.jsx
# ============================================================
cat > src/components/product/AddToCartButton.jsx << 'EOF'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ShoppingCart, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { useCart } from '../../context/CartContext'
import { useAuth } from '../../context/AuthContext'

export default function AddToCartButton({ productId, stock = 10, disabled = false, quantity = 1 }) {
  const navigate = useNavigate()
  const { addToCart } = useCart()
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)
  const [added, setAdded] = useState(false)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }

    if (stock <= 0) {
      toast.error('Out of stock')
      return
    }

    setLoading(true)
    try {
      await addToCart(productId, quantity)
      toast.success('Added to cart')
      setAdded(true)
      setTimeout(() => setAdded(false), 2000)
    } catch (err) {
      toast.error(err.message || 'Failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <button
      onClick={handleClick}
      disabled={disabled || loading || stock <= 0}
      className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-bold py-3 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {added ? (
        <>
          <Check className="h-5 w-5" />
          Added to Cart
        </>
      ) : (
        <>
          <ShoppingCart className="h-5 w-5" />
          {loading ? 'Adding...' : stock <= 0 ? 'Out of Stock' : 'Add to Cart'}
        </>
      )}
    </button>
  )
}
EOF

# ============================================================
# 12. WishlistButton.jsx
# ============================================================
cat > cat > src/components/product/WishlistButton.jsx << 'EOF'
import { useNavigate } from 'react-router-dom'
import { Heart } from 'lucide-react'
import toast from 'react-hot-toast'
import { useWishlist } from '../../context/WishlistContext'
import { useAuth } from '../../context/AuthContext'

export default function WishlistButton({ productId }) {
  const navigate = useNavigate()
  const { isWished, toggleWishlist } = useWishlist()
  const { user } = useAuth()
  const wished = isWished(productId)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      const result = await toggleWishlist(productId)
      toast.success(result.added ? 'Added to wishlist' : 'Removed from wishlist')
    } catch (err) {
      toast.error('Failed')
    }
  }

  return (
    <button
      onClick={handleClick}
      className={`flex items-center gap-2 px-4 py-3 border rounded-lg transition font-medium ${
        wished
          ? 'border-danger text-danger bg-red-50 dark:bg-red-900/10'
          : 'border-gray-300 dark:border-gray-700 text-secondary dark:text-white hover:border-danger hover:text-danger'
      }`}
    >
      <Heart className={`h-5 w-5 ${wished ? 'fill-danger' : ''}`} />
      {wished ? 'Saved' : 'Wishlist'}
    </button>
  )
}
EOF

# ============================================================
# 13. CompareButton.jsx
# ============================================================
cat > src/components/product/CompareButton.jsx << 'EOF'
import { useNavigate } from 'react-router-dom'
import { BarChart3, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { useCompare } from '../../context/CompareContext'
import { useAuth } from '../../context/AuthContext'

export default function CompareButton({ productId }) {
  const navigate = useNavigate()
  const { isCompared, addToCompare, removeFromCompare } = useCompare()
  const { user } = useAuth()
  const compared = isCompared(productId)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      if (compared) {
        await removeFromCompare(productId)
        toast.success('Removed from compare')
      } else {
        await addToCompare(productId)
        toast.success('Added to compare')
      }
    } catch (err) {
      toast.error(err.message || 'Failed')
    }
  }

  return (
    <button
      onClick={handleClick}
      className={`flex items-center gap-2 px-4 py-3 border rounded-lg transition font-medium ${
        compared
          ? 'border-link text-link bg-blue-50 dark:bg-blue-900/10'
          : 'border-gray-300 dark:border-gray-700 text-secondary dark:text-white hover:border-link hover:text-link'
      }`}
    >
      {compared ? <Check className="h-5 w-5" /> : <BarChart3 className="h-5 w-5" />}
      {compared ? 'Comparing' : 'Compare'}
    </button>
  )
}
EOF

echo ""
echo "✅ First batch of Product files created!"
echo ""
