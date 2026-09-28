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
