import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import CheckoutStepper from '../components/checkout/CheckoutStepper'
import ShippingForm from '../components/checkout/ShippingForm'
import ShippingMethod from '../components/checkout/ShippingMethod'
import PaymentForm from '../components/checkout/PaymentForm'
import OrderSummary from '../components/checkout/OrderSummary'
import { useCart } from '../context/CartContext'
import { api } from '../lib/api'

export default function Checkout() {
  const navigate = useNavigate()
  const { items, subtotal } = useCart()
  const [step, setStep] = useState(1)
  const [shippingAddress, setShippingAddress] = useState(null)
  const [shippingMethod, setShippingMethod] = useState('standard')
  const [orderId, setOrderId] = useState(null)
  const [creating, setCreating] = useState(false)

  if (items.length === 0) {
    return (
      <div className="container-page py-16 text-center">
        <h1 className="text-2xl font-bold mb-4 text-secondary dark:text-white">
          Your cart is empty
        </h1>
        <Link to="/products" className="text-link hover:text-primary">
          ← Start shopping
        </Link>
      </div>
    )
  }

  const handleShippingNext = (form) => {
    console.log('📦 Shipping form received:', form)
    setShippingAddress(form)
    setStep(2)
  }

  const handleMethodNext = async () => {
    console.log('📧 Shipping address on continue:', shippingAddress)

    if (!shippingAddress) {
      toast.error('Shipping address missing')
      return
    }

    if (!shippingAddress.email) {
      toast.error('Email is required')
      return
    }

    setCreating(true)
    try {
      const res = await api.post('/orders', {
        shipping_address: shippingAddress,
        shipping_method: shippingMethod,
        customer_email: shippingAddress.email,
      })
      console.log('✅ Order created:', res.data.order)
      setOrderId(res.data.order.id)
      setStep(3)
    } catch (err) {
      console.error('❌ Order creation failed:', err)
      toast.error(err.message || 'Failed to create order')
    } finally {
      setCreating(false)
    }
  }

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white text-center">
        Checkout
      </h1>

      <CheckoutStepper current={step} />

      <div className="grid lg:grid-cols-[1fr_360px] gap-6">
        <div className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card">
          {step === 1 && (
            <ShippingForm
              onNext={handleShippingNext}
              initial={shippingAddress || {}}
            />
          )}

          {step === 2 && (
            <ShippingMethod
              subtotal={subtotal}
              selected={shippingMethod}
              onSelect={setShippingMethod}
              onBack={() => setStep(1)}
              onNext={handleMethodNext}
              loading={creating}
            />
          )}

          {step === 3 && orderId && (
            <PaymentForm
              orderId={orderId}
              onBack={() => setStep(2)}
              onSuccess={() => navigate(`/order-success?order_id=${orderId}`)}
            />
          )}
        </div>

        <OrderSummary
          items={items}
          subtotal={subtotal}
          shippingMethod={shippingMethod}
        />
      </div>
    </div>
  )
}
