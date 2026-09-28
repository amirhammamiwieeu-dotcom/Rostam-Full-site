import { useEffect, useState } from 'react'
import { Link, useSearchParams, useNavigate } from 'react-router-dom'
import { CheckCircle, Loader, XCircle } from 'lucide-react'
import Button from '../components/ui/Button'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'
import { useCart } from '../context/CartContext'
import { formatCurrency } from '../lib/utils'

export default function OrderSuccess() {
  const [params] = useSearchParams()
  const navigate = useNavigate()
  const { reload: reloadCart } = useCart()
  const sessionId = params.get('session_id')
  const orderId = params.get('order_id')

  const [status, setStatus] = useState('checking') // checking | paid | failed | timeout
  const [order, setOrder] = useState(null)
  const [attempts, setAttempts] = useState(0)

  useEffect(() => {
    if (!sessionId) {
      setStatus('failed')
      return
    }

    let cancelled = false
    const maxAttempts = 15
    let timer

    const check = async () => {
      if (cancelled) return
      try {
        const res = await api.post('/payment/verify-session', { session_id: sessionId })
        if (cancelled) return

        if (res.data.paid) {
          setOrder(res.data.order)
          setStatus('paid')
          reloadCart()
        } else if (res.data.status === 'expired') {
          setStatus('failed')
        } else {
          const next = attempts + 1
          setAttempts(next)
          if (next >= maxAttempts) {
            setStatus('timeout')
          } else {
            timer = setTimeout(check, 2000)
          }
        }
      } catch (err) {
        console.error(err)
        if (cancelled) return
        const next = attempts + 1
        setAttempts(next)
        if (next >= maxAttempts) setStatus('timeout')
        else timer = setTimeout(check, 2000)
      }
    }

    check()
    return () => {
      cancelled = true
      if (timer) clearTimeout(timer)
    }
  }, [sessionId])

  if (status === 'checking') {
    return (
      <div className="container-page py-16 text-center max-w-md mx-auto">
        <Spinner size="lg" className="mx-auto mb-6" />
        <h1 className="text-2xl font-bold mb-2 text-secondary dark:text-white">
          Confirming your payment...
        </h1>
        <p className="text-sm text-gray-500">
          This usually takes a few seconds. Please don't close this page.
        </p>
        <div className="text-xs text-gray-400 mt-4">
          Attempt {attempts + 1} of 15
        </div>
      </div>
    )
  }

  if (status === 'paid') {
    return (
      <div className="container-page py-16 text-center max-w-lg mx-auto">
        <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
          <CheckCircle className="h-12 w-12 text-success" />
        </div>
        <h1 className="text-3xl font-bold mb-2 text-secondary dark:text-white">
          Thank you! 🎉
        </h1>
        <p className="text-gray-500 mb-6">
          Your order has been confirmed. We've sent a confirmation email.
        </p>

        {order && (
          <div className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card mb-6 text-left">
            <div className="flex justify-between text-sm mb-2">
              <span className="text-gray-500">Order Number</span>
              <span className="font-mono font-semibold text-secondary dark:text-white">
                {order.order_number}
              </span>
            </div>
            <div className="flex justify-between text-sm mb-2">
              <span className="text-gray-500">Total Paid</span>
              <span className="font-bold text-primary">
                {formatCurrency(order.total)}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Email</span>
              <span className="text-secondary dark:text-white">
                {order.customer_email}
              </span>
            </div>
          </div>
        )}

        <div className="flex gap-3 justify-center flex-wrap">
          <Link to="/orders">
            <Button>View My Orders</Button>
          </Link>
          <Link to="/products">
            <Button variant="secondary">Continue Shopping</Button>
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="container-page py-16 text-center max-w-md mx-auto">
      <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
        <XCircle className="h-12 w-12 text-danger" />
      </div>
      <h1 className="text-2xl font-bold mb-2 text-secondary dark:text-white">
        {status === 'timeout' ? 'Still processing...' : 'Payment failed'}
      </h1>
      <p className="text-gray-500 mb-6">
        {status === 'timeout'
          ? 'Your payment is still being confirmed. Check your orders page in a few minutes.'
          : 'Something went wrong. Please try again or contact support.'}
      </p>
      <div className="flex gap-3 justify-center flex-wrap">
        <Link to="/orders">
          <Button>View My Orders</Button>
        </Link>
        <Link to="/cart">
          <Button variant="secondary">Back to Cart</Button>
        </Link>
      </div>
    </div>
  )
}
