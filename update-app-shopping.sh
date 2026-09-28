#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

# Backup
cp src/App.jsx src/App.jsx.backup-$(date +%s) 2>/dev/null || true
cp src/components/layout/Layout.jsx src/components/layout/Layout.jsx.backup-$(date +%s) 2>/dev/null || true

# ============================================================
# App.jsx — با CheckoutProvider و روت‌های Shopping
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

# ============================================================
# Layout.jsx — با CartDrawer
# ============================================================
cat > src/components/layout/Layout.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { Outlet, Link } from 'react-router-dom'
import { Trash2, Plus, Minus } from 'lucide-react'
import Header from './Header'
import Footer from './Footer'
import MegaMenu from './MegaMenu'
import Drawer from '../ui/Drawer'
import { useCart } from '../../context/CartContext'
import { formatCurrency } from '../../lib/utils'

export default function Layout() {
  const [megaOpen, setMegaOpen] = useState(false)
  const [cartOpen, setCartOpen] = useState(false)
  const { items, subtotal, updateCartItem, removeCartItem } = useCart()

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-secondary-dark">
      <Header
        onOpenCart={() => setCartOpen(true)}
        onOpenMega={() => setMegaOpen(true)}
      />

      <main className="flex-1">
        <Outlet />
      </main>

      <Footer />

      <MegaMenu open={megaOpen} onClose={() => setMegaOpen(false)} />

      <Drawer
        open={cartOpen}
        onClose={() => setCartOpen(false)}
        title={`Your Cart (${items.length})`}
      >
        {items.length === 0 ? (
          <div className="text-center py-12 text-gray-500">
            <p>Your cart is empty</p>
          </div>
        ) : (
          <div className="space-y-4">
            {items.map((item) => {
              const p = item.product
              if (!p) return null
              const price = item.variant?.price || p.price
              return (
                <div key={item.id} className="flex gap-3 pb-4 border-b border-gray-200 dark:border-gray-700">
                  <img
                    src={p.thumbnail}
                    alt={p.title}
                    className="w-20 h-20 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
                  />
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm font-medium line-clamp-2 mb-1 text-secondary dark:text-white">
                      {p.title}
                    </h4>
                    <div className="text-primary font-bold text-sm mb-2">
                      {formatCurrency(price)}
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => updateCartItem(item.id, item.quantity - 1)}
                        disabled={item.quantity <= 1}
                        className="w-7 h-7 rounded-full border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:bg-primary hover:text-secondary disabled:opacity-40 transition"
                      >
                        <Minus className="h-3 w-3" />
                      </button>
                      <span className="text-sm font-bold w-6 text-center">
                        {item.quantity}
                      </span>
                      <button
                        onClick={() => updateCartItem(item.id, item.quantity + 1)}
                        className="w-7 h-7 rounded-full border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:bg-primary hover:text-secondary transition"
                      >
                        <Plus className="h-3 w-3" />
                      </button>
                      <button
                        onClick={() => removeCartItem(item.id)}
                        className="ml-auto text-gray-400 hover:text-danger transition"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              )
            })}

            <div className="pt-4">
              <div className="flex justify-between text-lg font-bold mb-4 text-secondary dark:text-white">
                <span>Subtotal:</span>
                <span className="text-primary">{formatCurrency(subtotal)}</span>
              </div>
              <Link
                to="/cart"
                onClick={() => setCartOpen(false)}
                className="block w-full text-center bg-white dark:bg-secondary border border-gray-300 dark:border-gray-700 hover:border-primary text-secondary dark:text-white font-semibold py-3 rounded-lg transition mb-2"
              >
                View Cart
              </Link>
              <Link
                to="/checkout"
                onClick={() => setCartOpen(false)}
                className="block w-full text-center bg-primary hover:bg-primary-dark text-secondary font-bold py-3 rounded-lg transition"
              >
                Checkout
              </Link>
            </div>
          </div>
        )}
      </Drawer>
    </div>
  )
}
ENDOFFILE

echo "✅ Layout.jsx updated"
echo ""
echo "🎉 Done!"
echo ""
echo "📋 Next:"
echo "   cd ~/Rostam-Full-site/client"
echo "   pkill -f vite"
echo "   npm run dev"
echo ""
