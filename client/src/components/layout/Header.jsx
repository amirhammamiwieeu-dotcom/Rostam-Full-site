import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Search, ShoppingCart, Heart, Menu, Moon, Sun, MapPin, X } from 'lucide-react'
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
  const [mobileSearchOpen, setMobileSearchOpen] = useState(false)
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
      setMobileSearchOpen(false)
    }
  }

  return (
    <header className="bg-secondary text-white sticky top-0 z-50 shadow-lg">
      {/* ===== Top Row ===== */}
      <div className="container-page py-2 flex items-center gap-2 sm:gap-3">
        {/* Mobile menu button */}
        <button
          onClick={onOpenMega}
          className="lg:hidden p-1.5 sm:p-2 hover:bg-secondary-light rounded-lg transition shrink-0"
          aria-label="Open menu"
        >
          <Menu className="h-5 w-5" />
        </button>

        {/* Logo - smaller on mobile */}
        <Link to="/" className="flex items-center gap-1 sm:gap-2 text-lg sm:text-2xl font-black whitespace-nowrap shrink-0">
          <ShoppingCart className="h-5 w-5 sm:h-7 sm:w-7 text-primary" />
          <span className="text-white">Market</span>
          <span className="text-primary">Hub</span>
        </Link>

        {/* Deliver to - desktop only */}
        <div className="hidden lg:flex items-center gap-2 text-sm px-3 py-1 hover:border hover:border-white rounded transition cursor-pointer">
          <MapPin className="h-4 w-4 text-primary" />
          <div>
            <div className="text-xs text-gray-400">Deliver to</div>
            <div className="font-semibold">New York 10001</div>
          </div>
        </div>

        {/* Search - desktop */}
        <div className="hidden md:block flex-1 relative max-w-3xl">
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

        {/* Right icons */}
        <div className="flex items-center gap-0.5 sm:gap-2 ml-auto shrink-0">
          {/* Mobile search toggle */}
          <button
            onClick={() => setMobileSearchOpen((v) => !v)}
            className="md:hidden p-1.5 sm:p-2 hover:bg-secondary-light rounded-lg transition"
            aria-label="Search"
          >
            <Search className="h-5 w-5" />
          </button>

          <button onClick={toggleTheme} className="p-1.5 sm:p-2 hover:bg-secondary-light rounded-lg transition">
            {isDark ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
          </button>

          <UserMenu />

          <Link to="/wishlist" className="relative p-1.5 sm:p-2 hover:bg-secondary-light rounded-lg transition">
            <Heart className="h-5 w-5" />
            {wishCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                {wishCount}
              </span>
            )}
          </Link>

          <button onClick={onOpenCart} className="relative p-1.5 sm:p-2 hover:bg-secondary-light rounded-lg transition">
            <ShoppingCart className="h-5 w-5 sm:h-6 sm:w-6" />
            {cartCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-primary text-secondary text-xs font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                {cartCount}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* ===== Mobile search bar (toggle) ===== */}
      {mobileSearchOpen && (
        <div className="md:hidden bg-secondary-light border-t border-secondary px-2 py-2">
          <div className="relative">
            <form onSubmit={handleSearch} className="flex h-10 rounded-lg overflow-hidden bg-white">
              <input
                autoFocus
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
                    onClick={() => setMobileSearchOpen(false)}
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
        </div>
      )}

      {/* ===== Main Categories Nav ===== */}
      <div className="bg-secondary-light">
        <div className="container-page py-2 flex items-center gap-1 text-sm overflow-x-auto scrollbar-hide">
          <Link
            to="/products"
            className="whitespace-nowrap px-3 py-1.5 hover:text-primary hover:bg-secondary rounded transition font-medium shrink-0"
          >
            All Products
          </Link>

          {categories.map((cat) => (
            <Link
              key={cat.id}
              to={`/category/${cat.slug}`}
              className="whitespace-nowrap px-3 py-1.5 hover:text-primary hover:bg-secondary rounded transition shrink-0"
            >
              {cat.name}
            </Link>
          ))}
        </div>
      </div>
    </header>
  )
}
