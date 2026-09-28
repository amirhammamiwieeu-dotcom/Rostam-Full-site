import { useState } from 'react'
import { Lock, CreditCard } from 'lucide-react'
import toast from 'react-hot-toast'
import Button from '../ui/Button'
import { api } from '../../lib/api'

export default function PaymentForm({ orderId, onBack, onSuccess }) {
  const [loading, setLoading] = useState(false)

  const handlePay = async () => {
    setLoading(true)
    try {
      const res = await api.post('/payment/create-session', { order_id: orderId })
      if (res.data.url) {
        window.location.href = res.data.url
      } else {
        throw new Error('No checkout URL')
      }
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to start payment')
      setLoading(false)
    }
  }

  return (
    <div>
      <h2 className="text-xl font-bold mb-1 text-secondary dark:text-white">
        Payment
      </h2>
      <p className="text-sm text-gray-500 mb-6">
        You'll be redirected to Stripe to complete payment securely
      </p>

      <div className="bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800 rounded-xl p-5 mb-6">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
            <CreditCard className="h-5 w-5 text-blue-600" />
          </div>
          <div>
            <h3 className="font-semibold text-sm mb-1 text-secondary dark:text-white">
              Secure Payment by Stripe
            </h3>
            <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
              Your payment is processed securely by Stripe.
              We never see or store your card details.
            </p>
          </div>
        </div>
      </div>

      <div className="flex items-center gap-2 justify-center text-xs text-gray-500 mb-6">
        <Lock className="h-3.5 w-3.5" />
        256-bit SSL encrypted · PCI DSS compliant
      </div>

      <div className="flex gap-2">
        <Button variant="secondary" onClick={onBack} className="flex-1">
          ← Back
        </Button>
        <Button onClick={handlePay} disabled={loading} className="flex-1">
          {loading ? 'Redirecting...' : 'Pay with Stripe →'}
        </Button>
      </div>
    </div>
  )
}
