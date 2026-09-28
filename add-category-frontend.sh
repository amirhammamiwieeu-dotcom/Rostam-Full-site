#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🎨 Creating Category Frontend..."
echo ""

mkdir -p src/components/category
mkdir -p src/pages

# ============================================================
# 1. components/category/CategorySidebar.jsx (NEW)
# ============================================================
cat > src/components/category/CategorySidebar.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { ChevronRight } from 'lucide-react'

export default function CategorySidebar({ category, children = [], siblings = [] }) {
  // Decide which list to show:
  // - If we're on a main category, show its children
  // - If we're on a subcategory, show its siblings
  const items = category.parent_id ? siblings : children
  const currentSlug = category.slug

  return (
    <aside className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden lg:sticky lg:top-32">
      {/* Header */}
      <div className="bg-secondary text-white px-4 py-3">
        <h3 className="font-bold text-sm">
          {category.parent_id ? 'In This Category' : 'Subcategories'}
        </h3>
      </div>

      {/* List */}
      <nav className="p-2">
        {/* "All" link */}
        {category.parent_id && (
          <Link
            to={`/category/${siblings[0]?.slug?.replace(/.*/, '') || ''}#`}
            className="hidden"
          >
            All
          </Link>
        )}

        {items.length === 0 ? (
          <p className="text-xs text-gray-500 p-3 text-center">
            No subcategories
          </p>
        ) : (
          items.map((item) => {
            const isActive = item.slug === currentSlug
            return (
              <Link
                key={item.id}
                to={`/products?category=${item.slug}`}
                className={`flex items-center justify-between px-3 py-2.5 rounded-lg text-sm transition ${
                  isActive
                    ? 'bg-primary text-secondary font-semibold'
                    : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-secondary hover:text-primary'
                }`}
              >
                <span className="truncate">{item.name}</span>
                <ChevronRight className="h-4 w-4 flex-shrink-0" />
              </Link>
            )
          })
        )}
      </nav>

      {/* Footer link */}
      {category.parent_id && siblings.length > 0 && (
        <div className="border-t border-gray-200 dark:border-gray-700 p-2">
          <Link
            to={`/products?category=${category.slug}`}
            className="flex items-center justify-center gap-1 px-3 py-2 text-xs text-link hover:text-primary transition"
          >
            View all {category.name}
            <ChevronRight className="h-3 w-3" />
          </Link>
        </div>
      )}
    </aside>
  )
}
ENDOFFILE

echo "✅ CategorySidebar.jsx"

# ============================================================
# 2. pages/Category.jsx (NEW — صفحه‌ی Main Category)
# ============================================================
cat > src/pages/Category.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { ChevronRight, Package } from 'lucide-react'
import toast from 'react-hot-toast'
import CategorySidebar from '../components/category/CategorySidebar'
import ProductGrid from '../components/product/ProductGrid'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'

export default function Category() {
  const { slug } = useParams()
  const navigate = useNavigate()

  const [categoryData, setCategoryData] = useState(null)
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [productsLoading, setProductsLoading] = useState(true)

  // Load category + children
  useEffect(() => {
    setLoading(true)
    api.get(`/categories/${slug}/with-children`)
      .then((res) => {
        setCategoryData(res.data)
      })
      .catch((err) => {
        console.error(err)
        toast.error('Category not found')
        navigate('/products')
      })
      .finally(() => setLoading(false))
  }, [slug, navigate])

  // Load products for this category (and its children)
  useEffect(() => {
    if (!categoryData) return

    setProductsLoading(true)

    // Build list of slugs to fetch: this category + all its children
    const slugs = [categoryData.category.slug]
    if (categoryData.children && categoryData.children.length > 0) {
      categoryData.children.forEach((c) => slugs.push(c.slug))
    }

    // Fetch products for this category
    // Backend accepts ?category=slug, but we want products from children too.
    // Strategy: fetch each child's products and merge, OR fetch the parent.
    // For simplicity, if parent has children, fetch all children products.
    if (categoryData.children && categoryData.children.length > 0) {
      Promise.all(
        categoryData.children.map((c) =>
          api.get(`/products?category=${c.slug}&limit=8`).catch(() => ({ data: { products: [] } }))
        )
      )
        .then((results) => {
          const allProducts = results.flatMap((r) => r.data.products || [])
          // Deduplicate by id
          const unique = []
          const seen = new Set()
          for (const p of allProducts) {
            if (!seen.has(p.id)) {
              seen.add(p.id)
              unique.push(p)
            }
          }
          setProducts(unique)
        })
        .finally(() => setProductsLoading(false))
    } else {
      api.get(`/products?category=${categoryData.category.slug}&limit=20`)
        .then((res) => setProducts(res.data.products || []))
        .catch(() => setProducts([]))
        .finally(() => setProductsLoading(false))
    }
  }, [categoryData])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!categoryData) return null

  const { category, children, parent } = categoryData

  return (
    <div className="container-page py-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-xs text-gray-500 mb-5 flex-wrap">
        <Link to="/" className="hover:text-primary">Home</Link>
        <ChevronRight className="h-3 w-3" />
        {parent && (
          <>
            <Link to={`/category/${parent.slug}`} className="hover:text-primary">
              {parent.name}
            </Link>
            <ChevronRight className="h-3 w-3" />
          </>
        )}
        <span className="text-secondary dark:text-white font-medium">
          {category.name}
        </span>
      </nav>

      {/* Hero */}
      <div className="bg-gradient-to-r from-primary/10 to-primary-dark/10 border-2 border-primary/30 rounded-xl p-6 mb-6">
        <div className="flex items-center gap-4">
          {category.icon && (
            <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center text-secondary flex-shrink-0">
              <i className={`fas ${category.icon} text-2xl`} />
            </div>
          )}
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-secondary dark:text-white mb-1">
              {category.name}
            </h1>
            {category.description && (
              <p className="text-sm text-gray-600 dark:text-gray-400">
                {category.description}
              </p>
            )}
            {children.length > 0 && (
              <p className="text-xs text-gray-500 mt-2">
                {children.length} subcategories
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Main grid */}
      <div className="grid lg:grid-cols-[240px_1fr] gap-6">
        {/* Sidebar */}
        <CategorySidebar
          category={category}
          children={children}
          siblings={categoryData.siblings || []}
        />

        {/* Products */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-bold text-lg text-secondary dark:text-white flex items-center gap-2">
              <Package className="h-5 w-5 text-primary" />
              {children.length > 0 ? 'Products in this category' : 'Products'}
            </h2>
            {children.length > 0 && (
              <Link
                to={`/products?category=${category.slug}`}
                className="text-sm text-link hover:text-primary"
              >
                View all →
              </Link>
            )}
          </div>

          <ProductGrid
            products={products}
            loading={productsLoading}
            columns={4}
          />

          {!productsLoading && products.length === 0 && (
            <div className="text-center py-16 bg-white dark:bg-secondary-light rounded-xl">
              <Package className="h-12 w-12 text-gray-300 mx-auto mb-3" />
              <h3 className="font-bold text-secondary dark:text-white mb-2">
                No products in this category yet
              </h3>
              <p className="text-sm text-gray-500 mb-4">
                Check back soon, or browse other categories
              </p>
              <Link
                to="/products"
                className="text-link hover:text-primary text-sm"
              >
                Browse all products →
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ Category.jsx"

# ============================================================
# 3. components/layout/Header.jsx (آپدیت — Main categories از API)
# ============================================================
cat > src/components/layout/Header.jsx << 'ENDOFFILE'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Search, ShoppingCart, Heart, Menu, Moon, Sun, MapPin } from 'lucide-react'
import UserMenu from '../auth/UserMenu'
import { useCart } from '../../context/CartContext'
import { useWishlist } from '../../context/WishlistContext'
import { useTheme } from '../../context/ThemeContext'
import { useDebounce } from '../../hooks/useDebounce'
import { api } from '../../lib/api'

export default function Header({ onOpenCart, onOpenMega }) {
  const navigate = useNavigate()
  const [query, setQuery] = useState('')
  const [suggestions, setSuggestions] = useState([])
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [categories, setCategories] = useState([])
  const debouncedQuery = useDebounce(query, 300)

  const { count: cartCount } = useCart()
  const { count: wishCount } = useWishlist()
  const { isDark, toggleTheme } = useTheme()

  // Load main categories
  useEffect(() => {
    api.get('/categories/main')
      .then((res) => setCategories(res.data.categories || []))
      .catch(() => setCategories([]))
  }, [])

  // Live search
  useEffect(() => {
    if (!debouncedQuery || debouncedQuery.length < 2) {
      setSuggestions([])
      return
    }
    api.get(`/products/search?q=${encodeURIComponent(debouncedQuery)}`)
      .then((res) => setSuggestions(res.data.products || []))
      .catch(() => setSuggestions([]))
  }, [debouncedQuery])

  const handleSearch = (e) => {
    e.preventDefault()
    if (query.trim()) {
      navigate(`/products?q=${encodeURIComponent(query)}`)
      setShowSuggestions(false)
    }
  }

  return (
    <header className="bg-secondary text-white sticky top-0 z-50 shadow-lg">
      <div className="container-page py-2 flex items-center gap-4">
        <button onClick={onOpenMega} className="lg:hidden p-2 hover:bg-secondary-light rounded-lg transition">
          <Menu className="h-5 w-5" />
        </button>

        <Link to="/" className="flex items-center gap-2 text-2xl font-black whitespace-nowrap">
          <ShoppingCart className="h-7 w-7 text-primary" />
          <span className="text-white">Market</span>
          <span className="text-primary">Hub</span>
        </Link>

        <div className="hidden lg:flex items-center gap-2 text-sm px-3 py-1 hover:border hover:border-white rounded transition cursor-pointer">
          <MapPin className="h-4 w-4 text-primary" />
          <div>
            <div className="text-xs text-gray-400">Deliver to</div>
            <div className="font-semibold">New York 10001</div>
          </div>
        </div>

        <div className="flex-1 relative max-w-3xl hidden md:block">
          <form onSubmit={handleSearch} className="flex h-10 rounded-lg overflow-hidden bg-white">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onFocus={() => setShowSuggestions(true)}
              onBlur={() => setTimeout(() => setShowSuggestions(false), 200)}
              placeholder="Search MarketHub..."
              className="flex-1 px-4 text-secondary outline-none text-sm"
            />
            <button type="submit" className="bg-primary hover:bg-primary-dark px-4 flex items-center justify-center transition">
              <Search className="h-5 w-5 text-secondary" />
            </button>
          </form>
          {showSuggestions && suggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-lg shadow-2xl overflow-hidden z-50">
              {suggestions.map((p) => (
                <Link
                  key={p.id}
                  to={`/products/${p.slug}`}
                  className="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 border-b last:border-0 transition"
                >
                  <img src={p.thumbnail} alt={p.title} className="w-10 h-10 object-contain" />
                  <div className="flex-1">
                    <div className="text-sm text-secondary font-medium line-clamp-1">{p.title}</div>
                    <div className="text-sm text-primary font-bold">${p.price}</div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>

        <div className="flex items-center gap-2 ml-auto">
          <button onClick={toggleTheme} className="p-2 hover:bg-secondary-light rounded-lg transition">
            {isDark ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
          </button>
          <UserMenu />
          <Link to="/wishlist" className="relative p-2 hover:bg-secondary-light rounded-lg transition">
            <Heart className="h-5 w-5" />
            {wishCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                {wishCount}
              </span>
            )}
          </Link>
          <button onClick={onOpenCart} className="relative p-2 hover:bg-secondary-light rounded-lg transition">
            <ShoppingCart className="h-6 w-6" />
            {cartCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                {cartCount}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* Main Categories Nav */}
      <div className="bg-secondary-light">
        <div className="container-page py-2 flex items-center gap-1 text-sm overflow-x-auto scrollbar-hide">
          <Link
            to="/products"
            className="whitespace-nowrap px-3 py-1.5 hover:text-primary hover:bg-secondary rounded transition font-medium"
          >
            All Products
          </Link>

          {categories.map((cat) => (
            <Link
              key={cat.id}
              to={`/category/${cat.slug}`}
              className="whitespace-nowrap px-3 py-1.5 hover:text-primary hover:bg-secondary rounded transition"
            >
              {cat.name}
            </Link>
          ))}
        </div>
      </div>
    </header>
  )
}
ENDOFFILE

echo "✅ Header.jsx"

# ============================================================
# 4. App.jsx (آپدیت — Category رو با lazy import کنار بذار)
# ============================================================
# یه check کوچیک: اگه Category.jsx قبلاً import شده بود، دوباره اضافه نکن
if grep -q "import Category from './pages/Category'" src/App.jsx; then
  echo "ℹ️  App.jsx already has Category import"
else
  sed -i "s|import ProductDetail from './pages/ProductDetail'|import ProductDetail from './pages/ProductDetail'\nimport Category from './pages/Category'|" src/App.jsx
fi

# اضافه کردن route اگه نیست
if grep -q '<Route path="/category/:slug"' src/App.jsx; then
  echo "ℹ️  App.jsx already has /category/:slug route"
else
  sed -i 's|<Route path="/products/:slug" element={<ProductDetail />} />|<Route path="/products/:slug" element={<ProductDetail />} />\n                    <Route path="/category/:slug" element={<Category />} />|' src/App.jsx
fi

echo "✅ App.jsx updated"
echo ""
echo "🎉 Category Frontend done!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Frontend terminal"
echo "   2. cd ~/Rostam-Full-site/client"
echo "   3. npm run dev"
echo ""
echo "🧪 Test:"
echo "   1. Header → on 'Electronics'"
echo "   2. Should go to /category/electronics"
echo "   3. Should show sidebar with subcategories"
echo "   4. Click 'Mobile Phones' → /products?category=mobile-phones"
echo ""
