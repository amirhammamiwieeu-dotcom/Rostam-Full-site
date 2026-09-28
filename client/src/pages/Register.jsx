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
