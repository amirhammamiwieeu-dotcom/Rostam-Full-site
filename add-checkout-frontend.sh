#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🛒 Creating Checkout & Orders Frontend..."
echo "📁 Working dir: $(pwd)"
echo ""

mkdir -p src/components/checkout
mkdir -p src/components/order
mkdir -p src/pages
mkdir -p src/lib

# ============================================================
# 1. lib/orderHelpers.js
# ============================================================
cat > src/lib/orderHelpers.js << 'ENDOFFILE'
export const ORDER_STATUSES = {
  pending: { label: 'Pending', color: 'yellow' },
  confirmed: { label: 'Confirmed', color: 'blue' },
  processing: { label: 'Processing', color: 'blue' },
  shipped: { label: 'Shipped', color: 'purple' },
  delivered: { label: 'Delivered', color: 'green' },
  cancelled: { label: 'Cancelled', color: 'red' },
  returned: { label: 'Returned', color: 'gray' },
  refunded: { label: 'Refunded', color: 'gray' },
}

export const getStatusInfo = (status) => {
  return ORDER_STATUSES[status] || { label: status, color: 'gray' }
}

export const getStatusClasses = (color) => {
  const map = {
    yellow: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300',
    blue: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300',
    purple: 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300',
    green: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300',
    red: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300',
    gray: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300',
  }
  return map[color] || map.gray
}

export const generateOrderTimeline = (order) => {
  if (order.status === 'cancelled') {
    return [
      { key: 'pending', label: 'Order Placed', date: order.created_at, done: true },
      { key: 'cancelled', label: 'Order Cancelled', date: order.cancelled_at, done: true, isError: true },
    ]
  }

  return [
    { key: 'pending', label: 'Order Placed', date: order.created_at, done: true },
    { key: 'confirmed', label: 'Confirmed', date: order.paid_at, done: !!order.paid_at },
    { key: 'processing', label: 'Processing', date: null, done: ['processing', 'shipped', 'delivered'].includes(order.status) },
    { key: 'shipped', label: 'Shipped', date: order.shipped_at, done: !!order.shipped_at },
    { key: 'delivered', label: 'Delivered', date: order.delivered_at, done: !!order.delivered_at },
  ]
}
ENDOFFILE

echo "✅ orderHelpers.js"

# ============================================================
# 2. CheckoutStepper.jsx
# ============================================================
cat > src/components/checkout/CheckoutStepper.jsx << 'ENDOFFILE'
import { Check } from 'lucide-react'

const STEPS = [
  { num: 1, label: 'Shipping' },
  { num: 2, label: 'Payment' },
  { num: 3, label: 'Confirmation' },
]

export default function CheckoutStepper({ current = 1 }) {
  return (
    <div className="flex items-center justify-center gap-2 mb-8 flex-wrap">
      {STEPS.map((step, i) => {
        const done = step.num < current
        const active = step.num === current
        return (
          <div key={step.num} className="flex items-center gap-2">
            <div className="flex items-center gap-2.5">
              <div
                className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition ${
                  done
                    ? 'bg-success text-white'
                    : active
                      ? 'bg-primary text-secondary'
                      : 'bg-gray-200 dark:bg-gray-700 text-gray-500'
                }`}
              >
                {done ? <Check className="h-4 w-4" /> : step.num}
              </div>
              <span
                className={`text-sm font-medium ${
                  active
                    ? 'text-secondary dark:text-white'
                    : 'text-gray-500'
                }`}
              >
                {step.label}
              </span>
            </div>
            {i < STEPS.length - 1 && (
              <div className={`w-8 h-0.5 ${done ? 'bg-success' : 'bg-gray-300 dark:bg-gray-700'}`} />
            )}
          </div>
        )
      })}
    </div>
  )
}
ENDOFFILE

echo "✅ CheckoutStepper.jsx"

# ============================================================
# 3. AddressCard.jsx
# ============================================================
cat > src/components/checkout/AddressCard.jsx << 'ENDOFFILE'
import { MapPin, Check } from 'lucide-react'

export default function AddressCard({ address, selected, onSelect }) {
  return (
    <button
      type="button"
      onClick={() => onSelect(address)}
      className={`w-full text-left p-4 rounded-xl border-2 transition ${
        selected
          ? 'border-primary bg-primary/5'
          : 'border-gray-200 dark:border-gray-700 hover:border-primary/50'
      }`}
    >
      <div className="flex items-start gap-3">
        <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
          selected ? 'bg-primary text-secondary' : 'bg-gray-100 dark:bg-gray-800 text-gray-400'
        }`}>
          <MapPin className="h-5 w-5" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-sm text-secondary dark:text-white">
              {address.full_name}
            </span>
            {selected && <Check className="h-4 w-4 text-primary" />}
          </div>
          <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
            {address.address_line1}
            {address.address_line2 && `, ${address.address_line2}`}
            <br />
            {address.city}, {address.state || ''} {address.zip}
            <br />
            {address.country} · {address.phone}
          </p>
        </div>
      </div>
    </button>
  )
}
ENDOFFILE

echo "✅ AddressCard.jsx"

# ============================================================
# 4. ShippingForm.jsx
# ============================================================
cat > src/components/checkout/ShippingForm.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { User, Mail, Phone, MapPin, Building } from 'lucide-react'
import Button from '../ui/Button'

export default function ShippingForm({ onNext, initial = {} }) {
  const [form, setForm] = useState({
    full_name: initial.full_name || '',
    email: initial.email || '',
    phone: initial.phone || '',
    address_line1: initial.address_line1 || '',
    address_line2: initial.address_line2 || '',
    city: initial.city || '',
    state: initial.state || '',
    country: initial.country || 'US',
    zip: initial.zip || '',
  })
  const [errors, setErrors] = useState({})

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const validate = () => {
    const newErrors = {}
    if (!form.full_name.trim()) newErrors.full_name = 'Full name required'
    if (!form.email.trim()) newErrors.email = 'Email required'
    if (!form.phone.trim()) newErrors.phone = 'Phone required'
    if (!form.address_line1.trim()) newErrors.address_line1 = 'Address required'
    if (!form.city.trim()) newErrors.city = 'City required'
    if (!form.zip.trim()) newErrors.zip = 'ZIP required'
    return newErrors
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const newErrors = validate()
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    onNext(form)
  }

  const Field = ({ icon: Icon, label, name, placeholder, type = 'text', half = false }) => (
    <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} *
      </label>
      <div className="relative">
        <Icon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type={type}
          value={form[name]}
          onChange={(e) => handleChange(name, e.target.value)}
          placeholder={placeholder}
          className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
            errors[name]
              ? 'border-danger'
              : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
          }`}
        />
      </div>
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <form onSubmit={handleSubmit}>
      <h2 className="text-xl font-bold mb-1 text-secondary dark:text-white">
        Shipping Information
      </h2>
      <p className="text-sm text-gray-500 mb-6">
        Where should we deliver your order?
      </p>

      <div className="grid md:grid-cols-2 gap-4 mb-6">
        <Field icon={User} label="Full Name" name="full_name" placeholder="John Doe" />
        <Field icon={Mail} label="Email" name="email" placeholder="john@example.com" type="email" />
        <Field icon={Phone} label="Phone" name="phone" placeholder="+1 234 567 8900" />
        <Field icon={MapPin} label="Address Line 1" name="address_line1" placeholder="123 Main St" />
        <Field icon={Building} label="Address Line 2 (optional)" name="address_line2" placeholder="Apt 4B" />
        <Field icon={Building} label="City" name="city" placeholder="New York" half />
        <Field icon={MapPin} label="State" name="state" placeholder="NY" half />
        <Field icon={MapPin} label="ZIP Code" name="zip" placeholder="10001" half />
        <Field icon={MapPin} label="Country" name="country" placeholder="US" half />
      </div>

      <Button type="submit" className="w-full">
        Continue to Shipping Method →
      </Button>
    </form>
  )
}
ENDOFFILE

echo "✅ ShippingForm.jsx"

# ============================================================
# 5. ShippingMethod.jsx
# ============================================================
cat > src/components/checkout/ShippingMethod.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { Truck, Zap, Rocket, Check } from 'lucide-react'
import Button from '../ui/Button'
import { formatCurrency } from '../../lib/utils'
import { shippingMethods, FREE_SHIPPING_THRESHOLD } from '../../lib/checkoutHelpers'

export default function ShippingMethod({ subtotal, selected, onSelect, onBack, onNext }) {
  const icons = { standard: Truck, express: Zap, same_day: Rocket }

  return (
    <div>
      <h2 className="text-xl font-bold mb-1 text-secondary dark:text-white">
        Shipping Method
      </h2>
      <p className="text-sm text-gray-500 mb-6">
        Choose how fast you want your order
      </p>

      <div className="space-y-3 mb-6">
        {shippingMethods.map((method) => {
          const Icon = icons[method.id] || Truck
          const isFree = method.id === 'standard' && subtotal >= FREE_SHIPPING_THRESHOLD
          const isSelected = selected === method.id

          return (
            <button
              key={method.id}
              type="button"
              onClick={() => onSelect(method.id)}
              className={`w-full text-left p-4 rounded-xl border-2 transition ${
                isSelected
                  ? 'border-primary bg-primary/5'
                  : 'border-gray-200 dark:border-gray-700 hover:border-primary/50'
              }`}
            >
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                  isSelected ? 'bg-primary text-secondary' : 'bg-gray-100 dark:bg-gray-800 text-gray-400'
                }`}>
                  <Icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-0.5">
                    <span className="font-semibold text-sm text-secondary dark:text-white">
                      {method.name}
                    </span>
                    {isSelected && <Check className="h-4 w-4 text-primary" />}
                  </div>
                  <p className="text-xs text-gray-500">{method.desc}</p>
                </div>
                <div className="text-right">
                  {isFree ? (
                    <span className="text-success font-bold text-sm">FREE</span>
                  ) : (
                    <span className="font-bold text-sm text-secondary dark:text-white">
                      {formatCurrency(method.price)}
                    </span>
                  )}
                </div>
              </div>
            </button>
          )
        })}
      </div>

      {subtotal < FREE_SHIPPING_THRESHOLD && (
        <p className="text-xs text-gray-500 mb-4 text-center">
          💡 Add {formatCurrency(FREE_SHIPPING_THRESHOLD - subtotal)} more to get FREE standard shipping
        </p>
      )}

      <div className="flex gap-2">
        <Button variant="secondary" onClick={onBack} className="flex-1">
          ← Back
        </Button>
        <Button onClick={onNext} className="flex-1">
          Continue to Payment →
        </Button>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ ShippingMethod.jsx"

# ============================================================
# 6. OrderSummary.jsx
# ============================================================
cat > src/components/checkout/OrderSummary.jsx << 'ENDOFFILE'
import { formatCurrency } from '../../lib/utils'
import { calculateShipping, calculateTax } from '../../lib/checkoutHelpers'

export default function OrderSummary({ items, subtotal, discount = 0, shippingMethod = 'standard' }) {
  const shipping = calculateShipping(shippingMethod, subtotal - discount)
  const tax = calculateTax(subtotal, discount)
  const total = subtotal - discount + shipping + tax

  return (
    <aside className="bg-white dark:bg-secondary-light rounded-xl p-5 shadow-card sticky top-32">
      <h3 className="font-bold text-secondary dark:text-white mb-4 pb-3 border-b border-gray-200 dark:border-gray-700">
        Order Summary
      </h3>

      <div className="space-y-3 mb-4 max-h-64 overflow-y-auto">
        {items.map((item) => {
          const p = item.product
          if (!p) return null
          const price = item.variant?.price || p.price
          return (
            <div key={item.id} className="flex gap-3 text-xs">
              <img src={p.thumbnail} alt={p.title} className="w-12 h-12 object-contain rounded-lg bg-gray-50 dark:bg-secondary" />
              <div className="flex-1 min-w-0">
                <div className="font-medium text-secondary dark:text-white line-clamp-2 leading-tight mb-1">
                  {p.title}
                </div>
                <div className="text-gray-500">Qty: {item.quantity}</div>
              </div>
              <div className="font-bold text-primary text-right">
                {formatCurrency(price * item.quantity)}
              </div>
            </div>
          )
        })}
      </div>

      <div className="pt-4 border-t border-gray-200 dark:border-gray-700 space-y-2 text-sm">
        <div className="flex justify-between text-gray-600 dark:text-gray-400">
          <span>Subtotal</span>
          <span className="text-secondary dark:text-white font-medium">{formatCurrency(subtotal)}</span>
        </div>
        {discount > 0 && (
          <div className="flex justify-between text-success">
            <span>Discount</span>
            <span>−{formatCurrency(discount)}</span>
          </div>
        )}
        <div className="flex justify-between text-gray-600 dark:text-gray-400">
          <span>Shipping</span>
          <span className={shipping === 0 ? 'text-success font-medium' : 'text-secondary dark:text-white font-medium'}>
            {shipping === 0 ? 'FREE' : formatCurrency(shipping)}
          </span>
        </div>
        <div className="flex justify-between text-gray-600 dark:text-gray-400">
          <span>Tax (9%)</span>
          <span className="text-secondary dark:text-white font-medium">{formatCurrency(tax)}</span>
        </div>
      </div>

      <div className="pt-4 mt-4 border-t-2 border-gray-200 dark:border-gray-700">
        <div className="flex justify-between items-baseline">
          <span className="font-bold text-secondary dark:text-white">Total</span>
          <span className="text-xl font-bold text-primary">{formatCurrency(total)}</span>
        </div>
      </div>
    </aside>
  )
}
ENDOFFILE

echo "✅ OrderSummary.jsx"

# ============================================================
# 7. PaymentForm.jsx
# ============================================================
cat > src/components/checkout/PaymentForm.jsx << 'ENDOFFILE'
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
ENDOFFILE

echo "✅ PaymentForm.jsx"

# ============================================================
# 8. OrderStatus.jsx
# ============================================================
cat > src/components/order/OrderStatus.jsx << 'ENDOFFILE'
import { getStatusInfo, getStatusClasses } from '../../lib/orderHelpers'

export default function OrderStatus({ status }) {
  const info = getStatusInfo(status)
  return (
    <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${getStatusClasses(info.color)}`}>
      {info.label}
    </span>
  )
}
ENDOFFILE

echo "✅ OrderStatus.jsx"

# ============================================================
# 9. OrderTimeline.jsx
# ============================================================
cat > src/components/order/OrderTimeline.jsx << 'ENDOFFILE'
import { Check, Package, Truck, Home, X } from 'lucide-react'
import { generateOrderTimeline } from '../../lib/orderHelpers'
import { formatDate } from '../../lib/utils'

export default function OrderTimeline({ order }) {
  const steps = generateOrderTimeline(order)
  const icons = [Check, Package, Package, Truck, Home]

  return (
    <div className="space-y-4">
      {steps.map((step, i) => {
        const Icon = step.isError ? X : icons[i] || Check
        return (
          <div key={step.key} className="flex gap-4">
            <div className="flex flex-col items-center flex-shrink-0">
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center ${
                  step.isError
                    ? 'bg-red-100 dark:bg-red-900/30 text-danger'
                    : step.done
                      ? 'bg-success text-white'
                      : 'bg-gray-200 dark:bg-gray-700 text-gray-400'
                }`}
              >
                <Icon className="h-5 w-5" />
              </div>
              {i < steps.length - 1 && (
                <div
                  className={`w-0.5 flex-1 mt-2 ${
                    step.done ? 'bg-success' : 'bg-gray-200 dark:bg-gray-700'
                  }`}
                  style={{ minHeight: '32px' }}
                />
              )}
            </div>
            <div className="pb-4">
              <h4 className={`font-semibold text-sm ${
                step.done ? 'text-secondary dark:text-white' : 'text-gray-400'
              }`}>
                {step.label}
              </h4>
              {step.date && (
                <p className="text-xs text-gray-500 mt-0.5">
                  {formatDate(step.date)}
                </p>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
ENDOFFILE

echo "✅ OrderTimeline.jsx"

# ============================================================
# 10. OrderCard.jsx
# ============================================================
cat > src/components/order/OrderCard.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { Package, ArrowRight } from 'lucide-react'
import OrderStatus from './OrderStatus'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function OrderCard({ order }) {
  const items = order.items || []
  const itemsPreview = items.slice(0, 3)

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
      <div className="bg-gray-50 dark:bg-secondary px-4 py-3 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-4 text-xs">
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Order placed</div>
            <div className="font-semibold text-secondary dark:text-white">
              {formatDate(order.created_at)}
            </div>
          </div>
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Total</div>
            <div className="font-semibold text-secondary dark:text-white">
              {formatCurrency(order.total)}
            </div>
          </div>
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Order #</div>
            <div className="font-mono text-secondary dark:text-white">
              {order.order_number}
            </div>
          </div>
        </div>
        <OrderStatus status={order.status} />
      </div>

      <div className="p-4">
        <div className="flex items-center gap-4 mb-3">
          <div className="flex -space-x-2">
            {itemsPreview.map((item) => (
              <img
                key={item.id}
                src={item.image}
                alt=""
                className="w-12 h-12 object-contain rounded-lg bg-white dark:bg-secondary border-2 border-white dark:border-secondary-light"
              />
            ))}
            {items.length > 3 && (
              <div className="w-12 h-12 rounded-lg bg-gray-100 dark:bg-secondary border-2 border-white dark:border-secondary-light flex items-center justify-center text-xs font-bold text-gray-500">
                +{items.length - 3}
              </div>
            )}
          </div>
          <div className="flex-1 text-sm text-gray-600 dark:text-gray-400">
            {items.length} {items.length === 1 ? 'item' : 'items'}
          </div>
          <Link
            to={`/orders/${order.id}`}
            className="text-sm text-link hover:text-primary flex items-center gap-1 transition"
          >
            View Details <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        {order.tracking_number && (
          <div className="text-xs text-gray-500 flex items-center gap-2">
            <Package className="h-3.5 w-3.5" />
            Tracking: <span className="font-mono">{order.tracking_number}</span>
          </div>
        )}
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ OrderCard.jsx"

# ============================================================
# 11. Checkout.jsx
# ============================================================
cat > src/pages/Checkout.jsx << 'ENDOFFILE'
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
    setShippingAddress(form)
    setStep(2)
  }

  const handleMethodNext = async () => {
    if (!shippingAddress) {
      toast.error('Shipping address missing')
      return
    }
    setCreating(true)
    try {
      const res = await api.post('/orders', {
        shipping_address: shippingAddress,
        shipping_method: shippingMethod,
      })
      setOrderId(res.data.order.id)
      setStep(3)
    } catch (err) {
      console.error(err)
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
          {step === 1 && <ShippingForm onNext={handleShippingNext} initial={shippingAddress || {}} />}

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
ENDOFFILE

echo "✅ Checkout.jsx"

# ============================================================
# 12. OrderSuccess.jsx
# ============================================================
cat > src/pages/OrderSuccess.jsx << 'ENDOFFILE'
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
ENDOFFILE

echo "✅ OrderSuccess.jsx"

# ============================================================
# 13. Orders.jsx
# ============================================================
cat > src/pages/Orders.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Package } from 'lucide-react'
import OrderCard from '../components/order/OrderCard'
import Spinner from '../components/ui/Spinner'
import Button from '../components/ui/Button'
import { api } from '../lib/api'

export default function Orders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/orders')
      .then((res) => setOrders(res.data.orders || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  return (
    <div className="container-page py-8 max-w-4xl">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white flex items-center gap-3">
        <Package className="h-7 w-7 text-primary" />
        My Orders
      </h1>

      {orders.length === 0 ? (
        <div className="text-center py-16 bg-white dark:bg-secondary-light rounded-xl">
          <Package className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-lg font-bold mb-2 text-secondary dark:text-white">
            No orders yet
          </h2>
          <p className="text-sm text-gray-500 mb-6">
            Start shopping to see your orders here
          </p>
          <Link to="/products">
            <Button>Browse Products</Button>
          </Link>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map((order) => (
            <OrderCard key={order.id} order={order} />
          ))}
        </div>
      )}
    </div>
  )
}
ENDOFFILE

echo "✅ Orders.jsx"

# ============================================================
# 14. OrderDetail.jsx
# ============================================================
cat > src/pages/OrderDetail.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeft, MapPin, CreditCard, Package } from 'lucide-react'
import toast from 'react-hot-toast'
import OrderStatus from '../components/order/OrderStatus'
import OrderTimeline from '../components/order/OrderTimeline'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'
import { formatCurrency, formatDate } from '../lib/utils'

export default function OrderDetail() {
  const { id } = useParams()
  const [order, setOrder] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get(`/orders/${id}`)
      .then((res) => setOrder(res.data.order))
      .catch((err) => {
        console.error(err)
        toast.error('Order not found')
      })
      .finally(() => setLoading(false))
  }, [id])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!order) {
    return (
      <div className="container-page py-16 text-center">
        <h1 className="text-2xl font-bold mb-4 text-secondary dark:text-white">
          Order not found
        </h1>
        <Link to="/orders" className="text-link hover:text-primary">
          ← Back to orders
        </Link>
      </div>
    )
  }

  const address = order.shipping_address || {}
  const items = order.items || []

  return (
    <div className="container-page py-8 max-w-4xl">
      <Link to="/orders" className="text-sm text-link hover:text-primary inline-flex items-center gap-1 mb-4">
        <ArrowLeft className="h-4 w-4" /> Back to orders
      </Link>

      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 mb-6">
        <div className="flex items-center justify-between flex-wrap gap-3 mb-4 pb-4 border-b border-gray-200 dark:border-gray-700">
          <div>
            <h1 className="text-xl font-bold text-secondary dark:text-white mb-1">
              Order #{order.order_number}
            </h1>
            <p className="text-xs text-gray-500">
              Placed on {formatDate(order.created_at)}
            </p>
          </div>
          <OrderStatus status={order.status} />
        </div>

        <div className="grid md:grid-cols-3 gap-4 text-sm">
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Total</div>
            <div className="font-bold text-primary">{formatCurrency(order.total)}</div>
          </div>
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Payment</div>
            <div className="font-medium text-secondary dark:text-white capitalize">
              {order.payment_status}
            </div>
          </div>
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Items</div>
            <div className="font-medium text-secondary dark:text-white">
              {items.length}
            </div>
          </div>
        </div>
      </div>

      <div className="grid lg:grid-cols-[1fr_300px] gap-6">
        <div className="space-y-6">
          {/* Items */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h2 className="font-bold text-secondary dark:text-white mb-4 flex items-center gap-2">
              <Package className="h-5 w-5 text-primary" />
              Items
            </h2>
            <div className="space-y-4">
              {items.map((item) => (
                <div key={item.id} className="flex gap-3 pb-4 border-b border-gray-100 dark:border-gray-700/50 last:border-0 last:pb-0">
                  <img
                    src={item.image}
                    alt={item.title}
                    className="w-16 h-16 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
                  />
                  <div className="flex-1">
                    <h3 className="text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-1">
                      {item.title}
                    </h3>
                    <div className="text-xs text-gray-500">
                      Qty: {item.quantity} × {formatCurrency(item.price)}
                    </div>
                  </div>
                  <div className="font-bold text-secondary dark:text-white">
                    {formatCurrency(item.price * item.quantity)}
                  </div>
                </div>
              ))}
            </div>

            <div className="pt-4 mt-4 border-t border-gray-200 dark:border-gray-700 space-y-2 text-sm">
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Subtotal</span>
                <span>{formatCurrency(order.subtotal)}</span>
              </div>
              {order.discount > 0 && (
                <div className="flex justify-between text-success">
                  <span>Discount</span>
                  <span>−{formatCurrency(order.discount)}</span>
                </div>
              )}
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Shipping</span>
                <span>{formatCurrency(order.shipping_cost || 0)}</span>
              </div>
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Tax</span>
                <span>{formatCurrency(order.tax || 0)}</span>
              </div>
              <div className="flex justify-between font-bold text-secondary dark:text-white pt-2 border-t border-gray-200 dark:border-gray-700">
                <span>Total</span>
                <span className="text-primary">{formatCurrency(order.total)}</span>
              </div>
            </div>
          </div>

          {/* Shipping Address */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h2 className="font-bold text-secondary dark:text-white mb-4 flex items-center gap-2">
              <MapPin className="h-5 w-5 text-primary" />
              Shipping Address
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
              <strong className="text-secondary dark:text-white">{address.full_name}</strong>
              <br />
              {address.address_line1}
              {address.address_line2 && `, ${address.address_line2}`}
              <br />
              {address.city}, {address.state || ''} {address.zip}
              <br />
              {address.country}
              <br />
              {address.phone}
            </p>
          </div>
        </div>

        {/* Timeline */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 h-fit">
          <h2 className="font-bold text-secondary dark:text-white mb-6">
            Order Timeline
          </h2>
          <OrderTimeline order={order} />
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ OrderDetail.jsx"

# ============================================================
# 15. App.jsx (آپدیت)
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
import Checkout from './pages/Checkout'
import OrderSuccess from './pages/OrderSuccess'
import Orders from './pages/Orders'
import OrderDetail from './pages/OrderDetail'
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
                      <Route path="/checkout" element={<Checkout />} />
                      <Route path="/order-success" element={<OrderSuccess />} />
                      <Route path="/orders" element={<Orders />} />
                      <Route path="/orders/:id" element={<OrderDetail />} />
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
# 16. UserMenu.jsx (آپدیت — لینک Orders)
# ============================================================
cat > src/components/auth/UserMenu.jsx << 'ENDOFFILE'
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
    { icon: Package, label: 'Your Orders', to: '/orders' },
    { icon: Heart, label: 'Your Wishlist', to: '/wishlist' },
    { icon: User, label: 'Account', to: '/account' },
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
ENDOFFILE

echo "✅ UserMenu.jsx updated"

echo ""
echo "🎉 Checkout & Orders Frontend done!"
echo ""
echo "📋 Next:"
echo "   1. cd ~/Rostam-Full-site/client"
echo "   2. pkill -f vite"
echo "   3. npm run dev"
echo ""
echo "🧪 Test:"
echo "   1. Add products to cart"
echo "   2. Go to /checkout"
echo "   3. Fill form → shipping method → pay"
echo "   4. Should redirect to Stripe"
echo ""
