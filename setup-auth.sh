#!/bin/bash

set -e

echo "🚀 Creating Auth pages..."

cd client

# ============================================================
# ساخت پوشه‌ها ← این بخش جدید
# ============================================================
mkdir -p src/components/auth
mkdir -p src/pages
mkdir -p src/lib

# ============================================================
# 1. validators.js
# ============================================================
cat > src/lib/validators.js << 'EOF'
export const validators = {
  email: (value) => {
    if (!value) return 'Email is required'
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!re.test(value)) return 'Invalid email address'
    return null
  },

  password: (value) => {
    if (!value) return 'Password is required'
    if (value.length < 8) return 'Password must be at least 8 characters'
    if (!/[A-Z]/.test(value)) return 'Must contain an uppercase letter'
    if (!/[a-z]/.test(value)) return 'Must contain a lowercase letter'
    if (!/[0-9]/.test(value)) return 'Must contain a number'
    return null
  },

  simplePassword: (value) => {
    if (!value) return 'Password is required'
    if (value.length < 6) return 'Password must be at least 6 characters'
    return null
  },

  fullName: (value) => {
    if (!value) return 'Full name is required'
    if (value.length < 2) return 'Name must be at least 2 characters'
    if (value.length > 100) return 'Name is too long'
    return null
  },

  phone: (value) => {
    if (!value) return null
    const re = /^\+?[0-9]{10,15}$/
    if (!re.test(value)) return 'Invalid phone number'
    return null
  },
}

export const validateForm = (values, rules) => {
  const errors = {}
  for (const field in rules) {
    const error = rules[field](values[field])
    if (error) errors[field] = error
  }
  return errors
}
EOF

# ============================================================
# 2. AuthLayout.jsx
# ============================================================
cat > src/components/auth/AuthLayout.jsx << 'EOF'
import { Link } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'

export default function AuthLayout({ title, subtitle, children, footer }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-secondary-dark dark:to-secondary flex flex-col">
      <div className="py-8 text-center">
        <Link to="/" className="inline-flex items-center gap-2 text-3xl font-black">
          <ShoppingCart className="h-8 w-8 text-primary" />
          <span className="text-secondary dark:text-white">Market</span>
          <span className="text-primary">Hub</span>
        </Link>
      </div>

      <div className="flex-1 flex items-start justify-center px-4 pb-12">
        <div className="w-full max-w-md bg-white dark:bg-secondary-light rounded-2xl shadow-xl p-8">
          {title && (
            <div className="mb-6">
              <h1 className="text-2xl font-bold text-secondary dark:text-white mb-1">{title}</h1>
              {subtitle && <p className="text-sm text-gray-500">{subtitle}</p>}
            </div>
          )}

          {children}

          {footer && (
            <div className="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700 text-center text-sm">
              {footer}
            </div>
          )}
        </div>
      </div>

      <div className="bg-secondary-dark py-6 text-center text-xs text-gray-500">
        <div className="flex justify-center gap-6 mb-2">
          <a href="#" className="hover:text-primary transition">Conditions of Use</a>
          <a href="#" className="hover:text-primary transition">Privacy Notice</a>
          <a href="#" className="hover:text-primary transition">Help</a>
        </div>
        <p>© {new Date().getFullYear()} MarketHub. All rights reserved.</p>
      </div>
    </div>
  )
}
EOF

# ============================================================
# 3. PasswordInput.jsx
# ============================================================
cat > src/components/auth/PasswordInput.jsx << 'EOF'
import { useState } from 'react'
import { Lock, Eye, EyeOff } from 'lucide-react'

export default function PasswordInput({ value, onChange, error, placeholder = 'Password', ...props }) {
  const [show, setShow] = useState(false)

  return (
    <div>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        Password
      </label>
      <div className="relative">
        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
        <input
          type={show ? 'text' : 'password'}
          value={value}
          onChange={onChange}
          placeholder={placeholder}
          className={`w-full pl-10 pr-10 py-2.5 border rounded-lg outline-none transition text-secondary dark:text-white dark:bg-secondary ${
            error
              ? 'border-danger focus:border-danger focus:ring-2 focus:ring-danger/20'
              : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
          }`}
          {...props}
        />
        <button
          type="button"
          onClick={() => setShow((s) => !s)}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
        >
          {show ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
        </button>
      </div>
      {error && <p className="mt-1 text-xs text-danger">{error}</p>}
    </div>
  )
}
EOF

# ============================================================
# 4. GoogleButton.jsx
# ============================================================
cat > src/components/auth/GoogleButton.jsx << 'EOF'
import { useState } from 'react'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

export default function GoogleButton({ label = 'Continue with Google' }) {
  const { signInWithGoogle } = useAuth()
  const [loading, setLoading] = useState(false)

  const handleClick = async () => {
    setLoading(true)
    try {
      const { error } = await signInWithGoogle()
      if (error) throw error
    } catch (err) {
      console.error(err)
      toast.error('Google sign-in failed')
      setLoading(false)
    }
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={loading}
      className="w-full flex items-center justify-center gap-3 px-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg hover:border-primary hover:bg-gray-50 dark:hover:bg-secondary transition disabled:opacity-50"
    >
      <svg className="w-5 h-5" viewBox="0 0 24 24">
        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
      </svg>
      <span className="text-sm font-medium text-secondary dark:text-white">
        {loading ? 'Redirecting...' : label}
      </span>
    </button>
  )
}
EOF

# ============================================================
# 5. UserMenu.jsx
# ============================================================
cat > src/components/auth/UserMenu.jsx << 'EOF'
import { useState, useRef } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { User, Package, Heart, LogOut, Settings, ShoppingBag } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { useOnClickOutside } from '../../hooks/useOnClickOutside'
import toast from 'react-hot-toast'

export default function UserMenu() {
  const { user, profile, signOut } = useAuth()
  const [open, setOpen] = useState(false)
  const ref = useRef(null)
  const navigate = useNavigate()

  useOnClickOutside(ref, () => setOpen(false))

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  if (!user) {
    return (
      <Link
        to="/login"
        className="hidden sm:flex items-center gap-2 px-3 py-1 hover:border hover:border-white rounded transition"
      >
        <User className="h-5 w-5" />
        <div className="text-xs">
          <div className="text-gray-400">Sign in</div>
          <div className="font-semibold">Account</div>
        </div>
      </Link>
    )
  }

  const initials = (profile?.full_name || user.email || 'U')
    .split(' ')
    .map((n) => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

  const menuItems = [
    { icon: User, label: 'Your Account', to: '/account' },
    { icon: Package, label: 'Your Orders', to: '/account/orders' },
    { icon: Heart, label: 'Your Wishlist', to: '/wishlist' },
    { icon: Settings, label: 'Settings', to: '/account/profile' },
  ]

  if (profile?.role === 'admin') {
    menuItems.push({ icon: ShoppingBag, label: 'Admin Dashboard', to: '/admin' })
  }

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-2 px-3 py-1 hover:border hover:border-white rounded transition"
      >
        <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-sm">
          {initials}
        </div>
        <div className="text-xs hidden sm:block">
          <div className="text-gray-400">Hello,</div>
          <div className="font-semibold">{profile?.full_name?.split(' ')[0] || 'Account'}</div>
        </div>
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-64 bg-white dark:bg-secondary-light rounded-xl shadow-2xl overflow-hidden z-50">
          <div className="p-4 bg-gray-50 dark:bg-secondary border-b border-gray-200 dark:border-gray-700">
            <p className="font-semibold text-sm text-secondary dark:text-white">
              {profile?.full_name || 'User'}
            </p>
            <p className="text-xs text-gray-500 truncate">{user.email}</p>
          </div>

          <div className="py-2">
            {menuItems.map((item) => (
              <Link
                key={item.to}
                to={item.to}
                onClick={() => setOpen(false)}
                className="flex items-center gap-3 px-4 py-2.5 text-sm text-secondary dark:text-white hover:bg-gray-50 dark:hover:bg-secondary transition"
              >
                <item.icon className="h-4 w-4 text-gray-500" />
                {item.label}
              </Link>
            ))}
          </div>

          <div className="border-t border-gray-200 dark:border-gray-700">
            <button
              onClick={handleSignOut}
              className="flex items-center gap-3 w-full px-4 py-3 text-sm text-danger hover:bg-red-50 dark:hover:bg-red-900/10 transition"
            >
              <LogOut className="h-4 w-4" />
              Sign Out
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
EOF

# ============================================================
# 6. ProtectedRoute.jsx
# ============================================================
cat > src/components/auth/ProtectedRoute.jsx << 'EOF'
import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import Spinner from '../ui/Spinner'

export default function ProtectedRoute({ requireAdmin = false }) {
  const { user, profile, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  if (requireAdmin && profile?.role !== 'admin') {
    return <Navigate to="/" replace />
  }

  return <Outlet />
}
EOF

# ============================================================
# 7. Login.jsx
# ============================================================
cat > src/pages/Login.jsx << 'EOF'
import { useState } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { Mail } from 'lucide-react'
import toast from 'react-hot-toast'
import AuthLayout from '../components/auth/AuthLayout'
import PasswordInput from '../components/auth/PasswordInput'
import GoogleButton from '../components/auth/GoogleButton'
import Button from '../components/ui/Button'
import { useAuth } from '../context/AuthContext'
import { validators } from '../lib/validators'

export default function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const { signIn } = useAuth()

  const [form, setForm] = useState({ email: '', password: '' })
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  const from = location.state?.from?.pathname || '/'

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    const newErrors = {
      email: validators.email(form.email),
      password: validators.simplePassword(form.password),
    }

    const cleanErrors = Object.fromEntries(
      Object.entries(newErrors).filter(([_, v]) => v)
    )

    if (Object.keys(cleanErrors).length) {
      setErrors(cleanErrors)
      return
    }

    setLoading(true)
    try {
      const { error } = await signIn(form.email, form.password)
      if (error) throw error

      toast.success('Welcome back!')
      navigate(from, { replace: true })
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthLayout
      title="Sign in"
      subtitle="Welcome back to MarketHub"
      footer={
        <>
          New to MarketHub?{' '}
          <Link to="/register" className="text-link hover:text-primary font-medium">
            Create an account
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
            Email
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="email"
              value={form.email}
              onChange={(e) => handleChange('email', e.target.value)}
              placeholder="you@example.com"
              autoComplete="email"
              className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-secondary dark:text-white dark:bg-secondary ${
                errors.email
                  ? 'border-danger'
                  : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
              }`}
            />
          </div>
          {errors.email && <p className="mt-1 text-xs text-danger">{errors.email}</p>}
        </div>

        <PasswordInput
          value={form.password}
          onChange={(e) => handleChange('password', e.target.value)}
          error={errors.password}
          autoComplete="current-password"
        />

        <div className="flex justify-end">
          <Link to="/forgot-password" className="text-sm text-link hover:text-primary transition">
            Forgot password?
          </Link>
        </div>

        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? 'Signing in...' : 'Sign In'}
        </Button>
      </form>

      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-gray-200 dark:border-gray-700" />
        </div>
        <div className="relative flex justify-center text-xs">
          <span className="px-2 bg-white dark:bg-secondary-light text-gray-500">OR</span>
        </div>
      </div>

      <GoogleButton />
    </AuthLayout>
  )
}
EOF

# ============================================================
# 8. Register.jsx
# ============================================================
cat > src/pages/Register.jsx << 'EOF'
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Mail, User } from 'lucide-react'
import toast from 'react-hot-toast'
import AuthLayout from '../components/auth/AuthLayout'
import PasswordInput from '../components/auth/PasswordInput'
import GoogleButton from '../components/auth/GoogleButton'
import Button from '../components/ui/Button'
import { useAuth } from '../context/AuthContext'
import { validators } from '../lib/validators'

export default function Register() {
  const navigate = useNavigate()
  const { signUp } = useAuth()

  const [form, setForm] = useState({ full_name: '', email: '', password: '' })
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    const newErrors = {
      full_name: validators.fullName(form.full_name),
      email: validators.email(form.email),
      password: validators.password(form.password),
    }

    const cleanErrors = Object.fromEntries(
      Object.entries(newErrors).filter(([_, v]) => v)
    )

    if (Object.keys(cleanErrors).length) {
      setErrors(cleanErrors)
      return
    }

    setLoading(true)
    try {
      const { error } = await signUp(form.email, form.password, {
        full_name: form.full_name,
      })
      if (error) throw error

      toast.success('Account created! Please sign in.')
      navigate('/login')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthLayout
      title="Create account"
      subtitle="Join millions of happy shoppers"
      footer={
        <>
          Already have an account?{' '}
          <Link to="/login" className="text-link hover:text-primary font-medium">
            Sign in
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
            Full Name
          </label>
          <div className="relative">
            <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              value={form.full_name}
              onChange={(e) => handleChange('full_name', e.target.value)}
              placeholder="John Doe"
              autoComplete="name"
              className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-secondary dark:text-white dark:bg-secondary ${
                errors.full_name
                  ? 'border-danger'
                  : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
              }`}
            />
          </div>
          {errors.full_name && <p className="mt-1 text-xs text-danger">{errors.full_name}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
            Email
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="email"
              value={form.email}
              onChange={(e) => handleChange('email', e.target.value)}
              placeholder="you@example.com"
              autoComplete="email"
              className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-secondary dark:text-white dark:bg-secondary ${
                errors.email
                  ? 'border-danger'
                  : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
              }`}
            />
          </div>
          {errors.email && <p className="mt-1 text-xs text-danger">{errors.email}</p>}
        </div>

        <div>
          <PasswordInput
            value={form.password}
            onChange={(e) => handleChange('password', e.target.value)}
            error={errors.password}
            autoComplete="new-password"
          />
          <p className="mt-1 text-xs text-gray-500">
            At least 8 characters with uppercase, lowercase, and number
          </p>
        </div>

        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? 'Creating account...' : 'Create Account'}
        </Button>
      </form>

      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-gray-200 dark:border-gray-700" />
        </div>
        <div className="relative flex justify-center text-xs">
          <span className="px-2 bg-white dark:bg-secondary-light text-gray-500">OR</span>
        </div>
      </div>

      <GoogleButton label="Sign up with Google" />
    </AuthLayout>
  )
}
EOF

# ============================================================
# 9. ForgotPassword.jsx
# ============================================================
cat > src/pages/ForgotPassword.jsx << 'EOF'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Mail } from 'lucide-react'
import toast from 'react-hot-toast'
import AuthLayout from '../components/auth/AuthLayout'
import Button from '../components/ui/Button'
import { api } from '../lib/api'
import { validators } from '../lib/validators'

export default function ForgotPassword() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)
  const [sent, setSent] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()

    const err = validators.email(email)
    if (err) { setError(err); return }

    setLoading(true)
    try {
      await api.post('/auth/forgot-password', { email })
      setSent(true)
      toast.success('Reset link sent to your email')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to send reset link')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthLayout
      title="Forgot password?"
      subtitle="We'll send a reset link to your email"
      footer={
        <>
          Remember your password?{' '}
          <Link to="/login" className="text-link hover:text-primary font-medium">Sign in</Link>
        </>
      }
    >
      {sent ? (
        <div className="text-center py-6">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-green-100 dark:bg-green-900/20 flex items-center justify-center">
            <Mail className="h-8 w-8 text-green-600" />
          </div>
          <h3 className="font-bold text-secondary dark:text-white mb-2">Check your email</h3>
          <p className="text-sm text-gray-500 mb-4">
            We sent a password reset link to <strong>{email}</strong>
          </p>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">Email</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="email"
                value={email}
                onChange={(e) => { setEmail(e.target.value); setError(null) }}
                placeholder="you@example.com"
                autoComplete="email"
                className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-secondary dark:text-white dark:bg-secondary ${
                  error ? 'border-danger' : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
                }`}
              />
            </div>
            {error && <p className="mt-1 text-xs text-danger">{error}</p>}
          </div>

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Sending...' : 'Send Reset Link'}
          </Button>
        </form>
      )}
    </AuthLayout>
  )
}
EOF

# ============================================================
# 10. ResetPassword.jsx
# ============================================================
cat > src/pages/ResetPassword.jsx << 'EOF'
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import AuthLayout from '../components/auth/AuthLayout'
import PasswordInput from '../components/auth/PasswordInput'
import Button from '../components/ui/Button'
import { supabase } from '../lib/supabase'
import { validators } from '../lib/validators'

export default function ResetPassword() {
  const navigate = useNavigate()
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (event === 'PASSWORD_RECOVERY') setReady(true)
    })

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) setReady(true)
    })

    return () => subscription.unsubscribe()
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()

    const newErrors = {}
    const pwdErr = validators.password(password)
    if (pwdErr) newErrors.password = pwdErr
    if (password !== confirmPassword) newErrors.confirmPassword = 'Passwords do not match'

    if (Object.keys(newErrors).length) { setErrors(newErrors); return }

    setLoading(true)
    try {
      const { error } = await supabase.auth.updateUser({ password })
      if (error) throw error

      toast.success('Password updated! Please sign in.')
      await supabase.auth.signOut()
      navigate('/login')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to update password')
    } finally {
      setLoading(false)
    }
  }

  if (!ready) {
    return (
      <AuthLayout title="Invalid link" subtitle="This password reset link is invalid or expired">
        <Button onClick={() => navigate('/forgot-password')} className="w-full">
          Request New Link
        </Button>
      </AuthLayout>
    )
  }

  return (
    <AuthLayout title="Reset password" subtitle="Enter your new password">
      <form onSubmit={handleSubmit} className="space-y-4">
        <PasswordInput
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          error={errors.password}
          placeholder="New password"
          autoComplete="new-password"
        />

        <PasswordInput
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          error={errors.confirmPassword}
          placeholder="Confirm new password"
          autoComplete="new-password"
        />

        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? 'Updating...' : 'Update Password'}
        </Button>
      </form>
    </AuthLayout>
  )
}
EOF

# ============================================================
# 11. AuthCallback.jsx
# ============================================================
cat > src/pages/AuthCallback.jsx << 'EOF'
import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import Spinner from '../components/ui/Spinner'
import toast from 'react-hot-toast'

export default function AuthCallback() {
  const navigate = useNavigate()

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const { data: { session }, error } = await supabase.auth.getSession()
        if (error) throw error

        if (session) {
          localStorage.setItem('token', session.access_token)
          toast.success('Signed in successfully!')
          navigate('/account', { replace: true })
        } else {
          setTimeout(async () => {
            const { data: { session: retrySession } } = await supabase.auth.getSession()
            if (retrySession) {
              localStorage.setItem('token', retrySession.access_token)
              navigate('/account', { replace: true })
            } else {
              toast.error('Sign-in failed')
              navigate('/login', { replace: true })
            }
          }, 1000)
        }
      } catch (err) {
        console.error(err)
        toast.error('Authentication failed')
        navigate('/login', { replace: true })
      }
    }

    handleCallback()
  }, [navigate])

  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center gap-4">
      <Spinner size="lg" />
      <p className="text-sm text-gray-500">Completing sign-in...</p>
    </div>
  )
}
EOF

# ============================================================
# 12. NotFound.jsx
# ============================================================
cat > src/pages/NotFound.jsx << 'EOF'
import { Link } from 'react-router-dom'
import { Home } from 'lucide-react'
import Button from '../components/ui/Button'

export default function NotFound() {
  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center px-4 text-center">
      <h1 className="text-8xl font-black text-primary mb-4">404</h1>
      <h2 className="text-2xl font-bold text-secondary dark:text-white mb-2">Page Not Found</h2>
      <p className="text-gray-500 mb-8 max-w-md">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Link to="/">
        <Button size="lg">
          <Home className="h-5 w-5" />
          Back to Home
        </Button>
      </Link>
    </div>
  )
}
EOF

echo ""
echo "✅ All Auth files created!"
echo ""
echo "📁 Files created:"
find src/components/auth src/pages src/lib/validators.js 2>/dev/null | sort
echo ""
