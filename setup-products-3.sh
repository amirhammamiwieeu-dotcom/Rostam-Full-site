#!/bin/bash

set -e

echo "🚀 Creating Products pages - Part 3 (Pages)..."

cd client

mkdir -p src/pages

# ============================================================
# 1. Products.jsx (Listing page)
# ============================================================
cat > src/pages/Products.jsx << 'EOF'
import { useState, useEffect } from 'react'
import { useSearchParams } from 'react-router-dom'
import { SlidersHorizontal } from 'lucide-react'
import toast from 'react-hot-toast'
import ProductGrid from '../components/product/ProductGrid'
import ProductFilters from '../components/product/ProductFilters'
import ProductSort from '../components/product/ProductSort'
import ProductPagination from '../components/product/ProductPagination'
import { api } from '../lib/api'
import { buildQueryString, parseFiltersFromURL } from '../lib/productHelpers'

export default function Products() {
  const [searchParams, setSearchParams] = useSearchParams()
  const [filters, setFilters] = useState(() => parseFiltersFromURL(searchParams))
  const [products, setProducts] = useState([])
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 })
  const [loading, setLoading] = useState(true)
  const [showMobileFilters, setShowMobileFilters] = useState(false)

  useEffect(() => {
    const query = buildQueryString(filters)
    setSearchParams(query, { replace: true })
  }, [filters, setSearchParams])

  useEffect(() => {
    setLoading(true)
    const query = buildQueryString(filters)
    api.get(`/products?${query}`)
      .then((res) => {
        setProducts(res.data.products || [])
        setPagination(res.data.pagination || { page: 1, pages: 1, total: 0 })
      })
      .catch((err) => {
        toast.error('Failed to load products')
        console.error(err)
      })
      .finally(() => setLoading(false))
  }, [filters])

  return (
    <div className="container-page py-6">
      <div className="mb-5">
        <h1 className="text-2xl font-bold text-secondary dark:text-white mb-1">
          {filters.category ? 'Category Products' : filters.q ? `Results for "${filters.q}"` : 'All Products'}
        </h1>
        <p className="text-sm text-gray-500">
          {loading ? 'Loading...' : `${pagination.total.toLocaleString()} products found`}
        </p>
      </div>

      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        {/* Desktop Filters */}
        <aside className="hidden lg:block">
          <div className="sticky top-32">
            <ProductFilters filters={filters} onChange={setFilters} />
          </div>
        </aside>

        {/* Mobile Filters Modal */}
        {showMobileFilters && (
          <div className="fixed inset-0 z-50 lg:hidden">
            <div className="absolute inset-0 bg-black/60" onClick={() => setShowMobileFilters(false)} />
            <div className="absolute right-0 top-0 h-full w-full max-w-sm bg-white dark:bg-secondary-light overflow-y-auto p-4">
              <ProductFilters
                filters={filters}
                onChange={setFilters}
                onClose={() => setShowMobileFilters(false)}
              />
            </div>
          </div>
        )}

        {/* Products */}
        <div>
          <div className="flex items-center justify-between mb-4 bg-white dark:bg-secondary-light rounded-xl p-3 shadow-card">
            <button
              onClick={() => setShowMobileFilters(true)}
              className="lg:hidden flex items-center gap-2 px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary transition"
            >
              <SlidersHorizontal className="h-4 w-4" />
              Filters
            </button>
            <div className="hidden lg:block text-sm text-gray-500">
              Showing {products.length} of {pagination.total} products
            </div>
            <ProductSort value={filters.sort} onChange={(v) => setFilters({ ...filters, sort: v, page: 1 })} />
          </div>

          <ProductGrid products={products} loading={loading} columns={4} />

          {!loading && products.length > 0 && (
            <ProductPagination
              page={pagination.page}
              pages={pagination.pages}
              onPageChange={(p) => {
                setFilters({ ...filters, page: p })
                window.scrollTo({ top: 0, behavior: 'smooth' })
              }}
            />
          )}
        </div>
      </div>
    </div>
  )
}
EOF

# ============================================================
# 2. ProductDetail.jsx
# ============================================================
cat > src/pages/ProductDetail.jsx << 'EOF'
import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { ChevronRight, ShoppingCart, Zap } from 'lucide-react'
import toast from 'react-hot-toast'
import ProductGallery from '../components/product/ProductGallery'
import ProductInfo from '../components/product/ProductInfo'
import ProductReviews from '../components/product/ProductReviews'
import RelatedProducts from '../components/product/RelatedProducts'
import AddToCartButton from '../components/product/AddToCartButton'
import WishlistButton from '../components/product/WishlistButton'
import CompareButton from '../components/product/CompareButton'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'

export default function ProductDetail() {
  const { slug } = useParams()
  const [product, setProduct] = useState(null)
  const [loading, setLoading] = useState(true)
  const [quantity, setQuantity] = useState(1)
  const [activeTab, setActiveTab] = useState('description')

  useEffect(() => {
    setLoading(true)
    api.get(`/products/slug/${slug}`)
      .then((res) => setProduct(res.data.product))
      .catch((err) => {
        toast.error('Product not found')
        console.error(err)
      })
      .finally(() => setLoading(false))
  }, [slug])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!product) {
    return (
      <div className="container-page py-16 text-center">
        <h1 className="text-2xl font-bold mb-4 text-secondary dark:text-white">Product not found</h1>
        <Link to="/products" className="text-link hover:text-primary">
          ← Back to products
        </Link>
      </div>
    )
  }

  return (
    <div className="container-page py-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-xs text-gray-500 mb-5 flex-wrap">
        <Link to="/" className="hover:text-primary">Home</Link>
        <ChevronRight className="h-3 w-3" />
        <Link to="/products" className="hover:text-primary">Products</Link>
        {product.category && (
          <>
            <ChevronRight className="h-3 w-3" />
            <Link to={`/products?category=${product.category.slug}`} className="hover:text-primary">
              {product.category.name}
            </Link>
          </>
        )}
        <ChevronRight className="h-3 w-3" />
        <span className="truncate max-w-xs">{product.title}</span>
      </nav>

      {/* Main grid */}
      <div className="grid lg:grid-cols-[400px_1fr_300px] gap-6 mb-8">
        {/* Gallery */}
        <div className="bg-white dark:bg-secondary-light rounded-xl p-4 shadow-card">
          <ProductGallery images={product.images} thumbnail={product.thumbnail} />
        </div>

        {/* Info */}
        <div className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card">
          <ProductInfo product={product} />
        </div>

        {/* Buy box */}
        <aside className="bg-white dark:bg-secondary-light rounded-xl p-5 shadow-card h-fit lg:sticky lg:top-32">
          <div className="mb-4">
            <div className="text-sm text-gray-500 mb-2">Quantity</div>
            <select
              value={quantity}
              onChange={(e) => setQuantity(parseInt(e.target.value))}
              className="w-full px-3 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
            >
              {Array.from({ length: Math.min(product.stock || 10, 10) }).map((_, i) => (
                <option key={i + 1} value={i + 1}>Qty: {i + 1}</option>
              ))}
            </select>
          </div>

          <AddToCartButton
            productId={product.id}
            stock={product.stock}
            quantity={quantity}
          />

          <div className="grid grid-cols-2 gap-2 mt-3">
            <WishlistButton productId={product.id} />
            <CompareButton productId={product.id} />
          </div>

          <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
            <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
              <Zap className="h-3.5 w-3.5 text-primary" />
              Ships within 24 hours
            </div>
            <div className="text-xs text-gray-500">
              Sold by <span className="text-link hover:text-primary cursor-pointer">MarketHub</span>
            </div>
          </div>
        </aside>
      </div>

      {/* Tabs */}
      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card mb-8">
        <div className="flex border-b border-gray-200 dark:border-gray-700 overflow-x-auto scrollbar-hide">
          <button
            onClick={() => setActiveTab('description')}
            className={`px-6 py-4 text-sm font-semibold whitespace-nowrap border-b-2 transition ${
              activeTab === 'description'
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-500 hover:text-primary'
            }`}
          >
            Description
          </button>
          <button
            onClick={() => setActiveTab('reviews')}
            className={`px-6 py-4 text-sm font-semibold whitespace-nowrap border-b-2 transition ${
              activeTab === 'reviews'
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-500 hover:text-primary'
            }`}
          >
            Reviews ({product.num_reviews || 0})
          </button>
          <button
            onClick={() => setActiveTab('shipping')}
            className={`px-6 py-4 text-sm font-semibold whitespace-nowrap border-b-2 transition ${
              activeTab === 'shipping'
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-500 hover:text-primary'
            }`}
          >
            Shipping & Returns
          </button>
        </div>

        <div className="p-6">
          {activeTab === 'description' && (
            <div className="prose dark:prose-invert max-w-none text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
              {product.description || 'No description available for this product.'}
            </div>
          )}

          {activeTab === 'reviews' && <ProductReviews productId={product.id} />}

          {activeTab === 'shipping' && (
            <div className="text-sm text-gray-700 dark:text-gray-300 space-y-2">
              <p><strong>Shipping:</strong> Standard delivery within 5-7 business days.</p>
              <p><strong>Express:</strong> 2-3 business days available at checkout.</p>
              <p><strong>Returns:</strong> Free returns within 30 days of delivery.</p>
              <p><strong>Warranty:</strong> 12-month manufacturer warranty included.</p>
            </div>
          )}
        </div>
      </div>

      {/* Related products */}
      <RelatedProducts productId={product.id} />
    </div>
  )
}
EOF

# ============================================================
# 3. Search.jsx
# ============================================================
cat > src/pages/Search.jsx << 'EOF'
import { useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'

export default function Search() {
  const [params] = useSearchParams()
  const navigate = useNavigate()

  useEffect(() => {
    const q = params.get('q') || ''
    navigate(`/products?q=${encodeURIComponent(q)}`, { replace: true })
  }, [params, navigate])

  return null
}
EOF

# ============================================================
# 4. Category.jsx
# ============================================================
cat > src/pages/Category.jsx << 'EOF'
import { useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'

export default function Category() {
  const { slug } = useParams()
  const navigate = useNavigate()

  useEffect(() => {
    navigate(`/products?category=${slug}`, { replace: true })
  }, [slug, navigate])

  return null
}
EOF

# ============================================================
# 5. App.jsx (آپدیت)
# ============================================================
cat > src/App.jsx << 'EOF'
import { Routes, Route } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import { AuthProvider } from './context/AuthContext'
import { CartProvider } from './context/CartContext'
import { WishlistProvider } from './context/WishlistContext'
import { CompareProvider } from './context/CompareContext'

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
import NotFound from './pages/NotFound'

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <WishlistProvider>
          <CompareProvider>
            <CartProvider>
              <Routes>
                <Route element={<Layout />}>
                  <Route path="/" element={<Home />} />
                  <Route path="/products" element={<Products />} />
                  <Route path="/products/:slug" element={<ProductDetail />} />
                  <Route path="/search" element={<Search />} />
                  <Route path="/category/:slug" element={<Category />} />

                  <Route element={<ProtectedRoute />}>
                    {/* Future: /account, /wishlist, /cart, /checkout, /orders */}
                  </Route>

                  <Route element={<ProtectedRoute requireAdmin />}>
                    {/* Future: /admin */}
                  </Route>

                  <Route path="*" element={<NotFound />} />
                </Route>

                <Route path="/login" element={<Login />} />
                <Route path="/register" element={<Register />} />
                <Route path="/forgot-password" element={<ForgotPassword />} />
                <Route path="/reset-password" element={<ResetPassword />} />
                <Route path="/auth/callback" element={<AuthCallback />} />
              </Routes>
            </CartProvider>
          </CompareProvider>
        </WishlistProvider>
      </AuthProvider>
    </ThemeProvider>
  )
}
EOF

echo ""
echo "✅ Products Pages created!"
echo "  ✅ src/pages/Products.jsx"
echo "  ✅ src/pages/ProductDetail.jsx"
echo "  ✅ src/pages/Search.jsx"
echo "  ✅ src/pages/Category.jsx"
echo "  ✅ src/App.jsx (updated)"
echo ""
