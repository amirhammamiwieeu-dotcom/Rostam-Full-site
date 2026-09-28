#!/bin/bash

set -e

echo "🔄 Updating Header.jsx and App.jsx..."

cd client

# ============================================================
# App.jsx
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

# ============================================================
# Header.jsx
# ============================================================
cat > src/components/layout/Header.jsx << 'EOF'
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
  const debouncedQuery = useDebounce(query, 300)

  const { count: cartCount } = useCart()
  const { count: wishCount } = useWishlist()
  const { isDark, toggleTheme } = useTheme()

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
        <button onClick={onOpenMega} className="lg:hidden p-2 hover:bg-secondary-light rounded-lg transition"><Menu className="h-5 w-5" /></button>
        <Link to="/" className="flex items-center gap-2 text-2xl font-black whitespace-nowrap">
          <ShoppingCart className="h-7 w-7 text-primary" />
          <span className="text-white">Market</span>
          <span className="text-primary">Hub</span>
        </Link>
        <div className="hidden lg:flex items-center gap-2 text-sm px-3 py-1 hover:border hover:border-white rounded transition cursor-pointer">
          <MapPin className="h-4 w-4 text-primary" />
          <div><div className="text-xs text-gray-400">Deliver to</div><div className="font-semibold">New York 10001</div></div>
        </div>
        <div className="flex-1 relative max-w-3xl hidden md:block">
          <form onSubmit={handleSearch} className="flex h-10 rounded-lg overflow-hidden bg-white">
            <input type="text" value={query} onChange={(e) => setQuery(e.target.value)} onFocus={() => setShowSuggestions(true)} onBlur={() => setTimeout(() => setShowSuggestions(false), 200)} placeholder="Search MarketHub..." className="flex-1 px-4 text-secondary outline-none text-sm" />
            <button type="submit" className="bg-primary hover:bg-primary-dark px-4 flex items-center justify-center transition"><Search className="h-5 w-5 text-secondary" /></button>
          </form>
          {showSuggestions && suggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-lg shadow-2xl overflow-hidden z-50">
              {suggestions.map((p) => (
                <Link key={p.id} to={`/products/${p.slug}`} className="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 border-b last:border-0 transition">
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
          <button onClick={toggleTheme} className="p-2 hover:bg-secondary-light rounded-lg transition">{isDark ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}</button>
          <UserMenu />
          <Link to="/wishlist" className="relative p-2 hover:bg-secondary-light rounded-lg transition">
            <Heart className="h-5 w-5" />
            {wishCount > 0 && <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">{wishCount}</span>}
          </Link>
          <button onClick={onOpenCart} className="relative p-2 hover:bg-secondary-light rounded-lg transition">
            <ShoppingCart className="h-6 w-6" />
            {cartCount > 0 && <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">{cartCount}</span>}
          </button>
        </div>
      </div>
      <div className="bg-secondary-light">
        <div className="container-page py-2 flex items-center gap-6 text-sm overflow-x-auto scrollbar-hide">
          <Link to="/products" className="whitespace-nowrap hover:text-primary transition">All Products</Link>
          <Link to="/products?category=mobile-phones" className="whitespace-nowrap hover:text-primary transition">Mobiles</Link>
          <Link to="/products?category=laptops" className="whitespace-nowrap hover:text-primary transition">Laptops</Link>
          <Link to="/products?category=headphones-audio" className="whitespace-nowrap hover:text-primary transition">Headphones</Link>
          <Link to="/products?category=smartwatches" className="whitespace-nowrap hover:text-primary transition">Watches</Link>
          <Link to="/products?category=gaming" className="whitespace-nowrap hover:text-primary transition">Gaming</Link>
        </div>
      </div>
    </header>
  )
}
EOF

echo ""
echo "✅ Files updated:"
echo "  ✅ src/App.jsx"
echo "  ✅ src/components/layout/Header.jsx"
echo ""
