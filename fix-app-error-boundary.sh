#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🔧 Fixing App.jsx + main.jsx with Error Boundary..."
echo "📁 Working dir: $(pwd)"
echo ""

# بکاپ
cp src/App.jsx src/App.jsx.backup-$(date +%s)
cp src/main.jsx src/main.jsx.backup-$(date +%s)
echo "✅ Backups created"
echo ""

# ============================================================
# main.jsx با Error Boundary
# ============================================================
cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import App from './App'
import './index.css'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { error: null, errorInfo: null }
  }

  componentDidCatch(error, errorInfo) {
    console.error('❌ REACT ERROR:', error)
    console.error('📍 Component Stack:', errorInfo.componentStack)
    this.setState({ error, errorInfo })
  }

  render() {
    if (this.state.error) {
      return (
        <div style={{
          padding: '20px',
          fontFamily: 'monospace',
          background: '#1a1a1a',
          color: '#ff6b6b',
          minHeight: '100vh',
          overflow: 'auto'
        }}>
          <h1 style={{ color: '#ff6b6b', marginBottom: '16px' }}>
            ❌ React Error Caught
          </h1>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Error Message:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '13px',
            overflow: 'auto',
            marginBottom: '16px',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.error.toString()}
          </pre>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Stack Trace:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '12px',
            overflow: 'auto',
            marginBottom: '16px',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.error.stack}
          </pre>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Component Stack:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '12px',
            overflow: 'auto',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.errorInfo?.componentStack}
          </pre>
        </div>
      )
    }
    return this.props.children
  }
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ErrorBoundary>
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
    </ErrorBoundary>
  </React.StrictMode>
)
EOF

echo "✅ main.jsx updated"
echo ""

# ============================================================
# App.jsx کامل
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

echo "✅ App.jsx updated"
echo ""
echo "🎉 All done!"
echo ""
echo "📋 Next steps:"
echo "   1. Ctrl+C in your frontend terminal (to stop old server)"
echo "   2. cd ~/Rostam-Full-site/client"
echo "   3. npm run dev"
echo "   4. Open http://localhost:3000/"
echo ""
echo "🎯 If there's an error, you'll now SEE it on screen (not white page)"
echo ""
