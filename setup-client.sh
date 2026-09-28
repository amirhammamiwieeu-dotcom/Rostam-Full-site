#!/bin/bash

set -e

echo "🚀 Creating MarketHub client structure..."

# ============================================================
# 1. Create directories
# ============================================================
mkdir -p client/public
mkdir -p client/src/{lib,context,hooks,components/{ui,layout,home},pages}

cd client

# ============================================================
# 2. package.json
# ============================================================
cat > package.json << 'EOF'
{
  "name": "markethub-client",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.45.4",
    "clsx": "^2.1.1",
    "lucide-react": "^0.446.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-hot-toast": "^2.4.1",
    "react-router-dom": "^6.26.2"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.2",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.13",
    "vite": "^5.4.8"
  }
}
EOF

# ============================================================
# 3. vite.config.js
# ============================================================
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
  server: { port: 3000, host: true, open: false },
})
EOF

# ============================================================
# 4. tailwind.config.js
# ============================================================
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#FF9900', light: '#FFB84D', dark: '#E68A00' },
        secondary: { DEFAULT: '#131921', light: '#232F3E', dark: '#0F1419' },
        accent: { DEFAULT: '#F08804', hover: '#F3A847' },
        success: '#00A86B',
        danger: '#CC0C39',
        link: '#007185',
        sale: '#B12704',
      },
      fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
      boxShadow: {
        card: '0 1px 3px rgba(0,0,0,0.06)',
        'card-hover': '0 8px 24px rgba(0,0,0,0.12)',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease',
        'slide-in': 'slideIn 0.3s ease',
      },
      keyframes: {
        fadeIn: { '0%': { opacity: 0 }, '100%': { opacity: 1 } },
        slideIn: { '0%': { transform: 'translateX(100%)' }, '100%': { transform: 'translateX(0)' } },
      },
    },
  },
  plugins: [],
}
EOF

# ============================================================
# 5. postcss.config.js
# ============================================================
cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# ============================================================
# 6. index.html
# ============================================================
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="MarketHub — Your One-Stop Online Store" />
    <meta name="theme-color" content="#FF9900" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />
    <title>MarketHub — Your One-Stop Online Store</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# ============================================================
# 7. .env.example
# ============================================================
cat > .env.example << 'EOF'
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxx
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
VITE_API_URL=http://localhost:5000/api
EOF

# ============================================================
# 8. .gitignore
# ============================================================
cat > .gitignore << 'EOF'
node_modules/
dist/
dist-ssr/
*.local
.env
.env.local
.env.*.local
.vscode/*
!.vscode/extensions.json
.idea/
.DS_Store
EOF

# ============================================================
# 9. public/favicon.svg
# ============================================================
cat > public/favicon.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" rx="20" fill="#FF9900"/>
  <path d="M30 70V30h10l10 20 10-20h10v40h-8V45l-9 18h-6l-9-18v25z" fill="#131921"/>
</svg>
EOF

# ============================================================
# 10. src/index.css
# ============================================================
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * { @apply box-border; }
  html { scroll-behavior: smooth; -webkit-tap-highlight-color: transparent; }
  body { @apply font-sans bg-gray-50 text-secondary antialiased; }
  .dark body { @apply bg-secondary-dark text-gray-100; }
  ::-webkit-scrollbar { width: 10px; height: 10px; }
  ::-webkit-scrollbar-track { @apply bg-gray-100; }
  ::-webkit-scrollbar-thumb { @apply bg-gray-300 rounded-full; }
  ::-webkit-scrollbar-thumb:hover { @apply bg-gray-400; }
  :focus-visible { @apply outline-none ring-2 ring-primary ring-offset-2; }
}

@layer components {
  .container-page { @apply max-w-[1500px] mx-auto px-4 sm:px-6 lg:px-8; }
  .btn { @apply inline-flex items-center justify-center gap-2 px-4 py-2 rounded-lg font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed; }
  .card { @apply bg-white rounded-xl shadow-card overflow-hidden; }
  .dark .card { @apply bg-secondary-light; }
  .input { @apply w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition text-secondary; }
}

@layer utilities {
  .scrollbar-hide::-webkit-scrollbar { display: none; }
  .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
  .line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
}

@keyframes fadeIn { from { opacity: 0 } to { opacity: 1 } }
@keyframes slideIn { from { transform: translateX(100%) } to { transform: translateX(0) } }
EOF

# ============================================================
# 11. src/main.jsx
# ============================================================
cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 3000,
          style: { background: '#131921', color: '#fff', padding: '12px 16px', borderRadius: '8px', fontSize: '14px' },
          success: { iconTheme: { primary: '#00A86B', secondary: '#fff' } },
          error: { iconTheme: { primary: '#CC0C39', secondary: '#fff' } },
        }}
      />
    </BrowserRouter>
  </React.StrictMode>
)
EOF

# ============================================================
# 12. src/App.jsx
# ============================================================
cat > src/App.jsx << 'EOF'
import { Routes, Route } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import { AuthProvider } from './context/AuthContext'
import { CartProvider } from './context/CartContext'
import { WishlistProvider } from './context/WishlistContext'
import { CompareProvider } from './context/CompareContext'

import Layout from './components/layout/Layout'
import Home from './pages/Home'

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
                </Route>
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
# 13. src/lib/supabase.js
# ============================================================
cat > src/lib/supabase.js << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: true, persistSession: true, detectSessionInUrl: true },
})
EOF

# ============================================================
# 14. src/lib/api.js
# ============================================================
cat > src/lib/api.js << 'EOF'
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api'

class ApiError extends Error {
  constructor(message, status, data) {
    super(message)
    this.status = status
    this.data = data
  }
}

async function request(endpoint, options = {}) {
  const token = localStorage.getItem('token')
  const headers = {
    'Content-Type': 'application/json',
    ...(token && { Authorization: `Bearer ${token}` }),
    ...options.headers,
  }

  const response = await fetch(`${API_URL}${endpoint}`, { ...options, headers })
  const data = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new ApiError(data.message || 'Something went wrong', response.status, data)
  }

  return data
}

export const api = {
  get: (endpoint, options) => request(endpoint, { ...options, method: 'GET' }),
  post: (endpoint, body, options) => request(endpoint, { ...options, method: 'POST', body: JSON.stringify(body) }),
  put: (endpoint, body, options) => request(endpoint, { ...options, method: 'PUT', body: JSON.stringify(body) }),
  patch: (endpoint, body, options) => request(endpoint, { ...options, method: 'PATCH', body: JSON.stringify(body) }),
  delete: (endpoint, options) => request(endpoint, { ...options, method: 'DELETE' }),
}

export { ApiError }
EOF

# ============================================================
# 15. src/lib/utils.js
# ============================================================
cat > src/lib/utils.js << 'EOF'
import { clsx } from 'clsx'

export function cn(...inputs) { return clsx(inputs) }

export function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount)
}

export function formatDate(date) {
  return new Intl.DateTimeFormat('en-US', { year: 'numeric', month: 'short', day: 'numeric' }).format(new Date(date))
}

export function truncate(str, length = 50) {
  if (!str) return ''
  return str.length > length ? str.slice(0, length) + '...' : str
}
EOF

# ============================================================
# 16. src/context/ThemeContext.jsx
# ============================================================
cat > src/context/ThemeContext.jsx << 'EOF'
import { createContext, useContext, useEffect, useState } from 'react'

const ThemeContext = createContext()

export const useTheme = () => {
  const ctx = useContext(ThemeContext)
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider')
  return ctx
}

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(() => localStorage.getItem('markethub-theme') || 'light')

  useEffect(() => {
    document.documentElement.classList.toggle('dark', theme === 'dark')
    localStorage.setItem('markethub-theme', theme)
  }, [theme])

  const toggleTheme = () => setTheme((t) => (t === 'dark' ? 'light' : 'dark'))

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme, isDark: theme === 'dark' }}>
      {children}
    </ThemeContext.Provider>
  )
}
EOF

# ============================================================
# 17. src/context/AuthContext.jsx
# ============================================================
cat > src/context/AuthContext.jsx << 'EOF'
import { createContext, useContext, useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { api } from '../lib/api'

const AuthContext = createContext()

export const useAuth = () => {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      if (session) {
        localStorage.setItem('token', session.access_token)
        fetchProfile()
      }
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      setUser(session?.user ?? null)
      if (session) {
        localStorage.setItem('token', session.access_token)
        fetchProfile()
      } else {
        localStorage.removeItem('token')
        setProfile(null)
      }
    })

    return () => subscription.unsubscribe()
  }, [])

  const fetchProfile = async () => {
    try {
      const res = await api.get('/auth/me')
      setProfile(res.data.profile)
    } catch (err) {
      console.error('Failed to fetch profile:', err)
    }
  }

  const signUp = async (email, password, metadata = {}) => {
    return await supabase.auth.signUp({ email, password, options: { data: metadata } })
  }

  const signIn = async (email, password) => {
    return await supabase.auth.signInWithPassword({ email, password })
  }

  const signInWithGoogle = async () => {
    return await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: `${window.location.origin}/auth/callback` },
    })
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    localStorage.removeItem('token')
    setUser(null)
    setProfile(null)
  }

  return (
    <AuthContext.Provider value={{ user, profile, loading, signUp, signIn, signInWithGoogle, signOut, fetchProfile }}>
      {children}
    </AuthContext.Provider>
  )
}
EOF

# ============================================================
# 18. src/context/CartContext.jsx
# ============================================================
cat > src/context/CartContext.jsx << 'EOF'
import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const CartContext = createContext()

export const useCart = () => {
  const ctx = useContext(CartContext)
  if (!ctx) throw new Error('useCart must be used within CartProvider')
  return ctx
}

export function CartProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])
  const [subtotal, setSubtotal] = useState(0)
  const [count, setCount] = useState(0)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (user) loadCart()
    else { setItems([]); setSubtotal(0); setCount(0) }
  }, [user])

  const loadCart = async () => {
    setLoading(true)
    try {
      const res = await api.get('/cart')
      setItems(res.data.items)
      setSubtotal(res.data.subtotal)
      setCount(res.data.count)
    } catch (err) { console.error(err) }
    finally { setLoading(false) }
  }

  const addToCart = async (productId, quantity = 1) => {
    const res = await api.post('/cart/add', { product_id: productId, quantity })
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
    return res
  }

  const updateCartItem = async (itemId, quantity) => {
    const res = await api.put(`/cart/items/${itemId}`, { quantity })
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
  }

  const removeCartItem = async (itemId) => {
    const res = await api.delete(`/cart/items/${itemId}`)
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
  }

  const clearCart = async () => {
    await api.delete('/cart')
    setItems([]); setSubtotal(0); setCount(0)
  }

  return (
    <CartContext.Provider value={{ items, subtotal, count, loading, addToCart, updateCartItem, removeCartItem, clearCart, reload: loadCart }}>
      {children}
    </CartContext.Provider>
  )
}
EOF

# ============================================================
# 19. src/context/WishlistContext.jsx
# ============================================================
cat > src/context/WishlistContext.jsx << 'EOF'
import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const WishlistContext = createContext()

export const useWishlist = () => {
  const ctx = useContext(WishlistContext)
  if (!ctx) throw new Error('useWishlist must be used within WishlistProvider')
  return ctx
}

export function WishlistProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])

  useEffect(() => {
    if (user) loadWishlist()
    else setItems([])
  }, [user])

  const loadWishlist = async () => {
    try {
      const res = await api.get('/wishlist')
      setItems(res.data.items)
    } catch (err) { console.error(err) }
  }

  const toggleWishlist = async (productId) => {
    const res = await api.post('/wishlist/toggle', { product_id: productId })
    await loadWishlist()
    return res.data
  }

  const isWished = (productId) => items.some((i) => i.product?.id === productId)

  return (
    <WishlistContext.Provider value={{ items, count: items.length, toggleWishlist, isWished, reload: loadWishlist }}>
      {children}
    </WishlistContext.Provider>
  )
}
EOF

# ============================================================
# 20. src/context/CompareContext.jsx
# ============================================================
cat > src/context/CompareContext.jsx << 'EOF'
import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const CompareContext = createContext()

export const useCompare = () => {
  const ctx = useContext(CompareContext)
  if (!ctx) throw new Error('useCompare must be used within CompareProvider')
  return ctx
}

export function CompareProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])

  useEffect(() => {
    if (user) loadCompare()
    else setItems([])
  }, [user])

  const loadCompare = async () => {
    try {
      const res = await api.get('/compare')
      setItems(res.data.items)
    } catch (err) { console.error(err) }
  }

  const addToCompare = async (productId) => {
    const res = await api.post('/compare', { product_id: productId })
    setItems(res.data.items)
    return res.data
  }

  const removeFromCompare = async (productId) => {
    const res = await api.delete(`/compare/${productId}`)
    setItems(res.data.items)
  }

  const isCompared = (productId) => items.some((i) => i.product?.id === productId)

  return (
    <CompareContext.Provider value={{ items, count: items.length, addToCompare, removeFromCompare, isCompared, reload: loadCompare }}>
      {children}
    </CompareContext.Provider>
  )
}
EOF

# ============================================================
# 21. src/hooks/useDebounce.js
# ============================================================
cat > src/hooks/useDebounce.js << 'EOF'
import { useEffect, useState } from 'react'

export function useDebounce(value, delay = 500) {
  const [debouncedValue, setDebouncedValue] = useState(value)
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])
  return debouncedValue
}
EOF

# ============================================================
# 22. src/hooks/useOnClickOutside.js
# ============================================================
cat > src/hooks/useOnClickOutside.js << 'EOF'
import { useEffect } from 'react'

export function useOnClickOutside(ref, handler) {
  useEffect(() => {
    const listener = (event) => {
      if (!ref.current || ref.current.contains(event.target)) return
      handler(event)
    }
    document.addEventListener('mousedown', listener)
    document.addEventListener('touchstart', listener)
    return () => {
      document.removeEventListener('mousedown', listener)
      document.removeEventListener('touchstart', listener)
    }
  }, [ref, handler])
}
EOF

# ============================================================
# 23. src/hooks/useLocalStorage.js
# ============================================================
cat > src/hooks/useLocalStorage.js << 'EOF'
import { useState, useEffect } from 'react'

export function useLocalStorage(key, initial) {
  const [value, setValue] = useState(() => {
    try {
      const stored = localStorage.getItem(key)
      return stored ? JSON.parse(stored) : initial
    } catch { return initial }
  })
  useEffect(() => {
    try { localStorage.setItem(key, JSON.stringify(value)) } catch {}
  }, [key, value])
  return [value, setValue]
}
EOF

# ============================================================
# 23. UI Components
# ============================================================
cat > src/components/ui/Button.jsx << 'EOF'
import { cn } from '../../lib/utils'

export default function Button({ children, variant = 'primary', size = 'md', className, ...props }) {
  const variants = {
    primary: 'bg-primary hover:bg-primary-dark text-secondary font-semibold',
    secondary: 'bg-white border border-gray-300 hover:border-primary hover:text-primary text-secondary',
    ghost: 'hover:bg-gray-100 text-secondary',
    danger: 'bg-danger hover:bg-red-700 text-white',
    outline: 'border-2 border-primary text-primary hover:bg-primary hover:text-secondary',
  }
  const sizes = { sm: 'px-3 py-1.5 text-sm', md: 'px-4 py-2 text-sm', lg: 'px-6 py-3 text-base' }
  return (
    <button className={cn('inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed', variants[variant], sizes[size], className)} {...props}>
      {children}
    </button>
  )
}
EOF

cat > src/components/ui/Input.jsx << 'EOF'
import { forwardRef } from 'react'
import { cn } from '../../lib/utils'

const Input = forwardRef(function Input({ label, error, icon: Icon, className, ...props }, ref) {
  return (
    <div className="w-full">
      {label && <label className="block text-sm font-medium mb-1.5 text-secondary">{label}</label>}
      <div className="relative">
        {Icon && <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none"><Icon className="h-5 w-5 text-gray-400" /></div>}
        <input ref={ref} className={cn('w-full px-4 py-2.5 border border-gray-300 rounded-lg outline-none transition text-secondary', 'focus:border-primary focus:ring-2 focus:ring-primary/20', Icon && 'pl-10', error && 'border-danger', className)} {...props} />
      </div>
      {error && <p className="mt-1 text-sm text-danger">{error}</p>}
    </div>
  )
})

export default Input
EOF

cat > src/components/ui/Modal.jsx << 'EOF'
import { useEffect } from 'react'
import { X } from 'lucide-react'
import { cn } from '../../lib/utils'

export default function Modal({ open, onClose, title, children, size = 'md' }) {
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    return () => { document.body.style.overflow = 'unset' }
  }, [open])

  useEffect(() => {
    const handleEsc = (e) => e.key === 'Escape' && onClose()
    if (open) window.addEventListener('keydown', handleEsc)
    return () => window.removeEventListener('keydown', handleEsc)
  }, [open, onClose])

  if (!open) return null
  const sizes = { sm: 'max-w-md', md: 'max-w-lg', lg: 'max-w-2xl', xl: 'max-w-4xl' }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 animate-fade-in" onClick={onClose}>
      <div className={cn('bg-white dark:bg-secondary-light rounded-2xl shadow-2xl w-full', sizes[size])} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between p-5 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-lg font-bold text-secondary dark:text-white">{title}</h2>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition"><X className="h-5 w-5" /></button>
        </div>
        <div className="p-5">{children}</div>
      </div>
    </div>
  )
}
EOF

cat > src/components/ui/Drawer.jsx << 'EOF'
import { useEffect } from 'react'
import { X } from 'lucide-react'
import { cn } from '../../lib/utils'

export default function Drawer({ open, onClose, title, children, side = 'right' }) {
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    return () => { document.body.style.overflow = 'unset' }
  }, [open])

  return (
    <>
      {open && <div className="fixed inset-0 bg-black/60 z-40 animate-fade-in" onClick={onClose} />}
      <div className={cn('fixed top-0 h-full w-full max-w-md bg-white dark:bg-secondary-light shadow-2xl z-50 transition-transform duration-300', side === 'right' && 'right-0', side === 'left' && 'left-0', open ? 'translate-x-0' : side === 'right' ? 'translate-x-full' : '-translate-x-full')}>
        <div className="flex items-center justify-between p-5 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-lg font-bold text-secondary dark:text-white">{title}</h2>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition"><X className="h-5 w-5" /></button>
        </div>
        <div className="p-5 overflow-y-auto h-[calc(100%-80px)]">{children}</div>
      </div>
    </>
  )
}
EOF

cat > src/components/ui/Skeleton.jsx << 'EOF'
import { cn } from '../../lib/utils'

export default function Skeleton({ className, ...props }) {
  return <div className={cn('animate-pulse bg-gray-200 dark:bg-gray-700 rounded', className)} {...props} />
}
EOF

cat > src/components/ui/Spinner.jsx << 'EOF'
import { cn } from '../../lib/utils'

export default function Spinner({ size = 'md', className }) {
  const sizes = { sm: 'h-4 w-4 border-2', md: 'h-8 w-8 border-2', lg: 'h-12 w-12 border-[3px]' }
  return <div className={cn('animate-spin rounded-full border-primary border-t-transparent', sizes[size], className)} />
}
EOF

cat > src/components/ui/index.js << 'EOF'
export { default as Button } from './Button'
export { default as Input } from './Input'
export { default as Modal } from './Modal'
export { default as Drawer } from './Drawer'
export { default as Skeleton } from './Skeleton'
export { default as Spinner } from './Spinner'
EOF

# ============================================================
# 24. Layout Components
# ============================================================
cat > src/components/layout/Header.jsx << 'EOF'
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Search, ShoppingCart, Heart, User, Menu, Moon, Sun, MapPin } from 'lucide-react'
import { useCart } from '../../context/CartContext'
import { useWishlist } from '../../context/WishlistContext'
import { useTheme } from '../../context/ThemeContext'
import { useAuth } from '../../context/AuthContext'
import { useDebounce } from '../../hooks/useDebounce'
import { api } from '../../lib/api'
import { useEffect } from 'react'

export default function Header({ onOpenCart, onOpenMega }) {
  const navigate = useNavigate()
  const [query, setQuery] = useState('')
  const [suggestions, setSuggestions] = useState([])
  const [showSuggestions, setShowSuggestions] = useState(false)
  const debouncedQuery = useDebounce(query, 300)

  const { count: cartCount } = useCart()
  const { count: wishCount } = useWishlist()
  const { isDark, toggleTheme } = useTheme()
  const { user, profile } = useAuth()

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
          <Link to={user ? '/account' : '/login'} className="hidden sm:flex items-center gap-2 px-3 py-1 hover:border hover:border-white rounded transition">
            <User className="h-5 w-5" />
            <div className="text-xs">
              <div className="text-gray-400">{user ? 'Hello,' : 'Sign in'}</div>
              <div className="font-semibold">{profile?.full_name?.split(' ')[0] || 'Account'}</div>
            </div>
          </Link>
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
          <Link to="/products?category=headphones-audio" className="whitespace-nowrap hover:text-primary transition">Audio</Link>
          <Link to="/products?category=smartwatches" className="whitespace-nowrap hover:text-primary transition">Watches</Link>
          <Link to="/products?category=gaming" className="whitespace-nowrap hover:text-primary transition">Gaming</Link>
        </div>
      </div>
    </header>
  )
}
EOF

cat > src/components/layout/Footer.jsx << 'EOF'
import { Link } from 'react-router-dom'
import { ShoppingCart, Facebook, Instagram, Twitter, Youtube } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="bg-secondary text-gray-300 mt-auto">
      <div className="bg-secondary-light py-4 text-center hover:bg-secondary-light/80 transition cursor-pointer">
        <a href="#" className="text-sm font-medium">Back to top</a>
      </div>
      <div className="container-page py-12 grid grid-cols-2 md:grid-cols-4 gap-8">
        <div>
          <h4 className="text-white font-bold mb-4">Get to Know Us</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/about" className="hover:text-primary transition">About Us</Link></li>
            <li><Link to="/careers" className="hover:text-primary transition">Careers</Link></li>
            <li><Link to="/blog" className="hover:text-primary transition">Blog</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Make Money</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/sell" className="hover:text-primary transition">Sell products</Link></li>
            <li><Link to="/affiliate" className="hover:text-primary transition">Become Affiliate</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Customer Service</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/contact" className="hover:text-primary transition">Contact Us</Link></li>
            <li><Link to="/shipping" className="hover:text-primary transition">Shipping</Link></li>
            <li><Link to="/returns" className="hover:text-primary transition">Returns</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Follow Us</h4>
          <div className="flex gap-3">
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Facebook className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Instagram className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Twitter className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Youtube className="h-4 w-4" /></a>
          </div>
        </div>
      </div>
      <div className="bg-secondary-dark py-6 text-center text-sm text-gray-500">
        <div className="flex items-center justify-center gap-2 mb-2">
          <ShoppingCart className="h-5 w-5 text-primary" />
          <span className="text-white font-bold">Market<span className="text-primary">Hub</span></span>
        </div>
        <p>© {new Date().getFullYear()} MarketHub. All rights reserved.</p>
      </div>
    </footer>
  )
}
EOF

cat > src/components/layout/MegaMenu.jsx << 'EOF'
import { X, ChevronRight } from 'lucide-react'
import { Link } from 'react-router-dom'

const categories = [
  { name: 'Mobiles', slug: 'mobile-phones' },
  { name: 'Laptops', slug: 'laptops' },
  { name: 'Headphones & Audio', slug: 'headphones-audio' },
  { name: 'Cameras', slug: 'cameras' },
  { name: 'Smartwatches', slug: 'smartwatches' },
  { name: 'Gaming', slug: 'gaming' },
  { name: "Men's Clothing", slug: 'mens-clothing' },
  { name: "Women's Clothing", slug: 'womens-clothing' },
  { name: 'Shoes', slug: 'shoes' },
  { name: 'Bags & Accessories', slug: 'bags-accessories' },
]

export default function MegaMenu({ open, onClose }) {
  return (
    <>
      {open && <div className="fixed inset-0 bg-black/60 z-40" onClick={onClose} />}
      <aside className={`fixed top-0 left-0 h-full w-full max-w-sm bg-white dark:bg-secondary-light shadow-2xl z-50 transition-transform duration-300 ${open ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="bg-secondary text-white p-5 flex items-center justify-between">
          <h3 className="text-lg font-bold">Shop by Department</h3>
          <button onClick={onClose} className="p-1 hover:bg-secondary-light rounded-lg"><X className="h-5 w-5" /></button>
        </div>
        <div className="p-4 overflow-y-auto h-[calc(100%-80px)]">
          <Link to="/products" onClick={onClose} className="flex items-center justify-between px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
            <span className="font-medium">All Products</span>
            <ChevronRight className="h-4 w-4" />
          </Link>
          {categories.map((cat) => (
            <Link key={cat.slug} to={`/products?category=${cat.slug}`} onClick={onClose} className="flex items-center justify-between px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
              <span className="font-medium">{cat.name}</span>
              <ChevronRight className="h-4 w-4 text-gray-400" />
            </Link>
          ))}
        </div>
      </aside>
    </>
  )
}
EOF

cat > src/components/layout/Layout.jsx << 'EOF'
import { useState } from 'react'
import { Outlet } from 'react-router-dom'
import Header from './Header'
import Footer from './Footer'
import MegaMenu from './MegaMenu'
import Drawer from '../ui/Drawer'
import { useCart } from '../../context/CartContext'
import { formatCurrency } from '../../lib/utils'
import { Trash2, Plus, Minus } from 'lucide-react'
import { Link } from 'react-router-dom'

export default function Layout() {
  const [megaOpen, setMegaOpen] = useState(false)
  const [cartOpen, setCartOpen] = useState(false)
  const { items, subtotal, updateCartItem, removeCartItem } = useCart()

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-secondary-dark">
      <Header onOpenCart={() => setCartOpen(true)} onOpenMega={() => setMegaOpen(true)} />
      <main className="flex-1"><Outlet /></main>
      <Footer />
      <MegaMenu open={megaOpen} onClose={() => setMegaOpen(false)} />
      <Drawer open={cartOpen} onClose={() => setCartOpen(false)} title={`Your Cart (${items.length})`}>
        {items.length === 0 ? (
          <div className="text-center py-12 text-gray-500"><p>Your cart is empty</p></div>
        ) : (
          <div className="space-y-4">
            {items.map((item) => (
              <div key={item.id} className="flex gap-3 pb-4 border-b border-gray-200 dark:border-gray-700">
                <img src={item.product.thumbnail} alt={item.product.title} className="w-20 h-20 object-contain" />
                <div className="flex-1">
                  <h4 className="text-sm font-medium line-clamp-2 mb-1">{item.product.title}</h4>
                  <div className="text-primary font-bold text-sm mb-2">{formatCurrency(item.product.price)}</div>
                  <div className="flex items-center gap-2">
                    <button onClick={() => updateCartItem(item.id, item.quantity - 1)} className="w-7 h-7 rounded-full border border-gray-300 flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Minus className="h-3 w-3" /></button>
                    <span className="text-sm font-bold w-6 text-center">{item.quantity}</span>
                    <button onClick={() => updateCartItem(item.id, item.quantity + 1)} className="w-7 h-7 rounded-full border border-gray-300 flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Plus className="h-3 w-3" /></button>
                    <button onClick={() => removeCartItem(item.id)} className="ml-auto text-gray-400 hover:text-danger transition"><Trash2 className="h-4 w-4" /></button>
                  </div>
                </div>
              </div>
            ))}
            <div className="pt-4">
              <div className="flex justify-between text-lg font-bold mb-4">
                <span>Subtotal:</span>
                <span className="text-primary">{formatCurrency(subtotal)}</span>
              </div>
              <Link to="/checkout" onClick={() => setCartOpen(false)} className="block w-full bg-primary hover:bg-primary-dark text-secondary font-bold text-center py-3 rounded-lg transition">
                Proceed to Checkout
              </Link>
            </div>
          </div>
        )}
      </Drawer>
    </div>
  )
}
EOF

# ============================================================
# 25. Home components
# ============================================================
cat > src/components/home/Hero.jsx << 'EOF'
import { useState, useEffect } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'

const slides = [
  { title: 'Mega Sale', subtitle: 'Up to 70% OFF', image: 'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1600&h=600&fit=crop', cta: 'Shop Now', link: '/products?sort=discount' },
  { title: 'New Arrivals', subtitle: 'Fresh Picks Weekly', image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600&h=600&fit=crop', cta: 'Browse New', link: '/products?sort=newest' },
  { title: 'Tech Deals', subtitle: 'Save on Electronics', image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1600&h=600&fit=crop', cta: 'Shop Tech', link: '/products?category=electronics' },
]

export default function Hero() {
  const [current, setCurrent] = useState(0)
  useEffect(() => {
    const timer = setInterval(() => setCurrent((c) => (c + 1) % slides.length), 6000)
    return () => clearInterval(timer)
  }, [])
  const next = () => setCurrent((c) => (c + 1) % slides.length)
  const prev = () => setCurrent((c) => (c - 1 + slides.length) % slides.length)

  return (
    <div className="relative h-[500px] overflow-hidden">
      {slides.map((slide, index) => (
        <div key={index} className={`absolute inset-0 transition-opacity duration-1000 ${index === current ? 'opacity-100' : 'opacity-0'}`}>
          <img src={slide.image} alt={slide.title} className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-black/70 via-black/30 to-transparent" />
          <div className="absolute inset-0 flex items-center">
            <div className="container-page">
              <div className="max-w-2xl text-white">
                <h2 className="text-5xl md:text-7xl font-black mb-2">{slide.title}</h2>
                <p className="text-2xl md:text-3xl text-primary font-bold mb-6">{slide.subtitle}</p>
                <a href={slide.link} className="inline-block bg-primary hover:bg-primary-dark text-secondary font-bold px-8 py-3 rounded-lg transition">{slide.cta} →</a>
              </div>
            </div>
          </div>
        </div>
      ))}
      <button onClick={prev} className="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-white/90 hover:bg-white flex items-center justify-center transition z-10"><ChevronLeft className="h-6 w-6 text-secondary" /></button>
      <button onClick={next} className="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-white/90 hover:bg-white flex items-center justify-center transition z-10"><ChevronRight className="h-6 w-6 text-secondary" /></button>
      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex gap-2 z-10">
        {slides.map((_, index) => (
          <button key={index} onClick={() => setCurrent(index)} className={`h-2 rounded-full transition-all ${index === current ? 'bg-primary w-8' : 'bg-white/60 hover:bg-white w-2'}`} />
        ))}
      </div>
    </div>
  )
}
EOF

# ============================================================
# 26. Pages
# ============================================================
cat > src/pages/Home.jsx << 'EOF'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Truck, Shield, RotateCcw, Headphones, ArrowRight } from 'lucide-react'
import Hero from '../components/home/Hero'
import { api } from '../lib/api'
import { formatCurrency } from '../lib/utils'
import Skeleton from '../components/ui/Skeleton'

const services = [
  { icon: Truck, title: 'Free Shipping', desc: 'On orders over $50' },
  { icon: Shield, title: 'Secure Payment', desc: '100% protected' },
  { icon: RotateCcw, title: 'Easy Returns', desc: '30-day guarantee' },
  { icon: Headphones, title: '24/7 Support', desc: 'Always here for you' },
]

const categories = [
  { name: 'Mobiles', slug: 'mobile-phones', emoji: '📱' },
  { name: 'Laptops', slug: 'laptops', emoji: '💻' },
  { name: 'Audio', slug: 'headphones-audio', emoji: '🎧' },
  { name: 'Cameras', slug: 'cameras', emoji: '📷' },
  { name: 'Watches', slug: 'smartwatches', emoji: '⌚' },
  { name: 'Gaming', slug: 'gaming', emoji: '🎮' },
  { name: 'Fashion', slug: 'fashion', emoji: '👕' },
  { name: 'Home', slug: 'home-kitchen', emoji: '🏠' },
]

export default function Home() {
  const [featured, setFeatured] = useState([])
  const [newArrivals, setNewArrivals] = useState([])
  const [bestSellers, setBestSellers] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([
      api.get('/products/featured?limit=8').catch(() => ({ data: { products: [] } })),
      api.get('/products/new?limit=8').catch(() => ({ data: { products: [] } })),
      api.get('/products/best-sellers?limit=8').catch(() => ({ data: { products: [] } })),
    ])
      .then(([feat, newArr, best]) => {
        setFeatured(feat.data.products || [])
        setNewArrivals(newArr.data.products || [])
        setBestSellers(best.data.products || [])
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <div>
      <Hero />

      <section className="container-page py-8">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {services.map((s, i) => (
            <div key={i} className="bg-white dark:bg-secondary-light rounded-xl p-5 flex items-center gap-3 shadow-card hover:shadow-card-hover transition">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary"><s.icon className="h-6 w-6" /></div>
              <div>
                <h4 className="font-bold text-sm text-secondary dark:text-white">{s.title}</h4>
                <p className="text-xs text-gray-500">{s.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="container-page pb-8">
        <div className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card">
          <h3 className="text-xl font-bold mb-6 text-center text-secondary dark:text-white">Shop by Category</h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-8 gap-4">
            {categories.map((cat) => (
              <Link key={cat.slug} to={`/products?category=${cat.slug}`} className="flex flex-col items-center gap-2 group">
                <div className="w-20 h-20 rounded-full bg-gradient-to-br from-gray-50 to-gray-200 dark:from-secondary dark:to-secondary-dark flex items-center justify-center text-3xl group-hover:shadow-lg group-hover:shadow-primary/20 group-hover:scale-105 transition">{cat.emoji}</div>
                <span className="text-xs text-center font-medium text-secondary dark:text-white">{cat.name}</span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <ProductSection title="Featured Products" products={featured} loading={loading} viewAllLink="/products?sort=featured" />
      <ProductSection title="New Arrivals" products={newArrivals} loading={loading} viewAllLink="/products?sort=newest" />
      <ProductSection title="Best Sellers" products={bestSellers} loading={loading} viewAllLink="/products?sort=popular" />
    </div>
  )
}

function ProductSection({ title, products, loading, viewAllLink }) {
  return (
    <section className="container-page pb-8">
      <div className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-xl font-bold text-secondary dark:text-white">{title}</h3>
          <Link to={viewAllLink} className="text-sm text-link hover:text-primary flex items-center gap-1 transition">View All <ArrowRight className="h-4 w-4" /></Link>
        </div>
        {loading ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-72 rounded-xl" />)}
          </div>
        ) : products.length === 0 ? (
          <p className="text-center text-gray-500 py-8">No products yet</p>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {products.map((p) => <ProductCard key={p.id} product={p} />)}
          </div>
        )}
      </div>
    </section>
  )
}

function ProductCard({ product }) {
  const discount = product.old_price ? Math.round((1 - product.price / product.old_price) * 100) : 0
  return (
    <Link to={`/products/${product.slug}`} className="group bg-white dark:bg-secondary rounded-xl p-3 hover:shadow-card-hover hover:-translate-y-1 transition border border-transparent hover:border-gray-200 dark:hover:border-gray-700">
      <div className="relative">
        <img src={product.thumbnail} alt={product.title} className="w-full h-40 object-contain mb-3" />
        {discount > 0 && <span className="absolute top-2 left-2 bg-primary text-secondary text-xs font-bold px-2 py-0.5 rounded-full">-{discount}%</span>}
      </div>
      <h4 className="text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-2 min-h-[40px]">{product.title}</h4>
      <div className="flex items-baseline gap-2">
        <span className="text-lg font-bold text-secondary dark:text-white">{formatCurrency(product.price)}</span>
        {product.old_price && <span className="text-xs text-gray-400 line-through">{formatCurrency(product.old_price)}</span>}
      </div>
    </Link>
  )
}
EOF

echo ""
echo "✅ ✅ ✅  All 35 files created successfully!"
echo ""
echo "📁 Structure:"
echo ""
find . -type f -not -path './node_modules/*' | sort
echo ""
echo "🚀 Next steps:"
echo "  1. cp .env.example .env"
echo "  2. nano .env  (fill in your keys)"
echo "  3. npm install"
echo "  4. npm run dev"
echo ""
