#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🛒 Creating Shopping Part 1 (Cart + Wishlist + Compare)..."
echo "📁 Working dir: $(pwd)"
echo ""

# ساخت پوشه‌ها
mkdir -p src/components/cart
mkdir -p src/components/wishlist
mkdir -p src/components/compare
mkdir -p src/pages
mkdir -p src/lib

# ============================================================
# 1. lib/checkoutHelpers.js
# ============================================================
cat > src/lib/checkoutHelpers.js << 'ENDOFFILE'
export const shippingMethods = [
  { id: 'standard', name: 'Standard Shipping', desc: '5-7 business days', price: 5.99, days: '5-7' },
  { id: 'express', name: 'Express Shipping', desc: '2-3 business days', price: 14.99, days: '2-3' },
  { id: 'same_day', name: 'Same-Day Delivery', desc: 'Within 24 hours', price: 24.99, days: '1' },
]

export const TAX_RATE = 0.09
export const FREE_SHIPPING_THRESHOLD = 50

export const calculateShipping = (method, subtotal) => {
  if (method === 'standard' && subtotal >= FREE_SHIPPING_THRESHOLD) return 0
  const found = shippingMethods.find((m) => m.id === method)
  return found ? found.price : 5.99
}

export const calculateTax = (subtotal, discount = 0) => {
  return Math.round((subtotal - discount) * TAX_RATE * 100) / 100
}

export const calculateTotal = (subtotal, discount = 0, shipping = 0) => {
  const tax = calculateTax(subtotal, discount)
  return Math.round((subtotal - discount + shipping + tax) * 100) / 100
}
ENDOFFILE

echo "✅ checkoutHelpers.js"
echo ""

# ============================================================
# 2. context/CheckoutContext.jsx
# ============================================================
cat > src/context/CheckoutContext.jsx << 'ENDOFFILE'
import { createContext, useContext, useState } from 'react'

const CheckoutContext = createContext()

export const useCheckout = () => {
  const ctx = useContext(CheckoutContext)
  if (!ctx) throw new Error('useCheckout must be used within CheckoutProvider')
  return ctx
}

export function CheckoutProvider({ children }) {
  const [step, setStep] = useState(1)
  const [shippingAddress, setShippingAddress] = useState(null)
  const [shippingMethod, setShippingMethod] = useState('standard')
  const [coupon, setCoupon] = useState(null)
  const [paymentIntent, setPaymentIntent] = useState(null)

  const reset = () => {
    setStep(1)
    setShippingAddress(null)
    setShippingMethod('standard')
    setCoupon(null)
    setPaymentIntent(null)
  }

  return (
    <CheckoutContext.Provider
      value={{
        step,
        setStep,
        shippingAddress,
        setShippingAddress,
        shippingMethod,
        setShippingMethod,
        coupon,
        setCoupon,
        paymentIntent,
        setPaymentIntent,
        reset,
      }}
    >
      {children}
    </CheckoutContext.Provider>
  )
}
ENDOFFILE

echo "✅ CheckoutContext.jsx"
echo ""

# ============================================================
# 3. components/cart/EmptyCart.jsx
# ============================================================
cat > src/components/cart/EmptyCart.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'
import Button from '../ui/Button'

export default function EmptyCart() {
  return (
    <div className="text-center py-16 px-4">
      <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-gray-100 dark:bg-secondary-light flex items-center justify-center">
        <ShoppingCart className="h-12 w-12 text-gray-400" />
      </div>
      <h2 className="text-2xl font-bold mb-2 text-secondary dark:text-white">
        Your cart is empty
      </h2>
      <p className="text-gray-500 mb-8 max-w-md mx-auto">
        Looks like you haven't added anything to your cart yet. Start shopping to fill it up!
      </p>
      <Link to="/products">
        <Button size="lg">
          <ShoppingCart className="h-5 w-5" />
          Start Shopping
        </Button>
      </Link>
    </div>
  )
}
ENDOFFILE

echo "✅ EmptyCart.jsx"
echo ""

# ============================================================
# 4. components/cart/CartSkeleton.jsx
# ============================================================
cat > src/components/cart/CartSkeleton.jsx << 'ENDOFFILE'
export default function CartSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      {[1, 2, 3].map((i) => (
        <div key={i} className="flex gap-4 p-4 bg-white dark:bg-secondary-light rounded-xl">
          <div className="w-24 h-24 bg-gray-200 dark:bg-gray-700 rounded-lg" />
          <div className="flex-1 space-y-2">
            <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4" />
            <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2" />
            <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-1/4" />
          </div>
        </div>
      ))}
    </div>
  )
}
ENDOFFILE

echo "✅ CartSkeleton.jsx"
echo ""

# ============================================================
# 5. components/cart/CartItem.jsx
# ============================================================
cat > src/components/cart/CartItem.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { Trash2, Plus, Minus, Heart } from 'lucide-react'
import toast from 'react-hot-toast'
import { useCart } from '../../context/CartContext'
import { useWishlist } from '../../context/WishlistContext'
import { formatCurrency } from '../../lib/utils'

export default function CartItem({ item }) {
  const { updateCartItem, removeCartItem } = useCart()
  const { toggleWishlist } = useWishlist()

  const product = item.product
  const price = item.variant?.price || product.price

  const handleQty = async (delta) => {
    const newQty = item.quantity + delta
    if (newQty < 1) return
    try {
      await updateCartItem(item.id, newQty)
    } catch (err) {
      toast.error(err.message || 'Failed to update')
    }
  }

  const handleRemove = async () => {
    try {
      await removeCartItem(item.id)
      toast.success('Removed from cart')
    } catch (err) {
      toast.error('Failed to remove')
    }
  }

  const handleMoveToWishlist = async () => {
    try {
      await toggleWishlist(product.id)
      await removeCartItem(item.id)
      toast.success('Moved to wishlist')
    } catch (err) {
      toast.error('Failed')
    }
  }

  return (
    <div className="flex gap-4 p-4 bg-white dark:bg-secondary-light rounded-xl shadow-card">
      <Link to={`/products/${product.slug}`} className="flex-shrink-0">
        <img
          src={product.thumbnail}
          alt={product.title}
          className="w-24 h-24 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
        />
      </Link>

      <div className="flex-1 min-w-0">
        <Link to={`/products/${product.slug}`}>
          <h3 className="font-medium text-secondary dark:text-white line-clamp-2 hover:text-primary transition mb-1">
            {product.title}
          </h3>
        </Link>

        {item.variant && (
          <p className="text-xs text-gray-500 mb-2">
            Variant: {item.variant.title}
          </p>
        )}

        <div className="flex items-center gap-2 mb-3">
          <span className="text-lg font-bold text-secondary dark:text-white">
            {formatCurrency(price)}
          </span>
          {product.old_price && (
            <span className="text-sm text-gray-400 line-through">
              {formatCurrency(product.old_price)}
            </span>
          )}
        </div>

        <div className="flex items-center gap-4 flex-wrap">
          <div className="flex items-center gap-2 border border-gray-300 dark:border-gray-700 rounded-lg">
            <button
              onClick={() => handleQty(-1)}
              disabled={item.quantity <= 1}
              className="w-8 h-8 flex items-center justify-center hover:bg-gray-100 dark:hover:bg-gray-800 disabled:opacity-40 transition rounded-r-lg"
            >
              <Minus className="h-3.5 w-3.5" />
            </button>
            <span className="w-8 text-center text-sm font-semibold">
              {item.quantity}
            </span>
            <button
              onClick={() => handleQty(1)}
              className="w-8 h-8 flex items-center justify-center hover:bg-gray-100 dark:hover:bg-gray-800 transition rounded-l-lg"
            >
              <Plus className="h-3.5 w-3.5" />
            </button>
          </div>

          <button
            onClick={handleMoveToWishlist}
            className="text-xs text-link hover:text-primary flex items-center gap-1 transition"
          >
            <Heart className="h-3.5 w-3.5" />
            Move to Wishlist
          </button>

          <button
            onClick={handleRemove}
            className="text-xs text-danger hover:text-red-700 flex items-center gap-1 transition"
          >
            <Trash2 className="h-3.5 w-3.5" />
            Remove
          </button>
        </div>
      </div>

      <div className="hidden sm:block text-right">
        <div className="text-sm text-gray-500 mb-1">Subtotal</div>
        <div className="font-bold text-secondary dark:text-white">
          {formatCurrency(price * item.quantity)}
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ CartItem.jsx"
echo ""

# ============================================================
# 6. components/cart/CouponForm.jsx
# ============================================================
cat > src/components/cart/CouponForm.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { Tag, X, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { api } from '../../lib/api'
import { formatCurrency } from '../../lib/utils'

export default function CouponForm({ subtotal, applied, onApply, onRemove }) {
  const [code, setCode] = useState('')
  const [loading, setLoading] = useState(false)

  const handleApply = async (e) => {
    e.preventDefault()
    if (!code.trim()) return

    setLoading(true)
    try {
      const res = await api.post('/cart/coupon', { code: code.trim().toUpperCase() })
      onApply(res.data)
      toast.success('Coupon applied!')
      setCode('')
    } catch (err) {
      toast.error(err.message || 'Invalid coupon')
    } finally {
      setLoading(false)
    }
  }

  if (applied) {
    return (
      <div className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
        <div className="flex items-center gap-2">
          <Check className="h-4 w-4 text-success" />
          <span className="text-sm font-semibold text-success">
            {applied.coupon.code}
          </span>
          <span className="text-xs text-gray-600 dark:text-gray-400">
            −{formatCurrency(applied.discountAmount)}
          </span>
        </div>
        <button
          onClick={onRemove}
          className="text-gray-500 hover:text-danger transition"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    )
  }

  return (
    <form onSubmit={handleApply} className="flex gap-2">
      <div className="flex-1 relative">
        <Tag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          value={code}
          onChange={(e) => setCode(e.target.value.toUpperCase())}
          placeholder="Coupon code"
          className="w-full pl-10 pr-3 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
        />
      </div>
      <button
        type="submit"
        disabled={loading || !code.trim()}
        className="px-4 py-2.5 bg-secondary hover:bg-secondary-light text-white rounded-lg text-sm font-semibold disabled:opacity-50 transition"
      >
        {loading ? '...' : 'Apply'}
      </button>
    </form>
  )
}
ENDOFFILE

echo "✅ CouponForm.jsx"
echo ""

# ============================================================
# 7. components/cart/CartSummary.jsx
# ============================================================
cat > src/components/cart/CartSummary.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { Lock, Truck } from 'lucide-react'
import { formatCurrency } from '../../lib/utils'
import { calculateShipping, calculateTax, FREE_SHIPPING_THRESHOLD } from '../../lib/checkoutHelpers'

export default function CartSummary({ subtotal, coupon, shippingMethod = 'standard' }) {
  const discount = coupon?.discountAmount || 0
  const shipping = calculateShipping(shippingMethod, subtotal)
  const tax = calculateTax(subtotal, discount)
  const total = subtotal - discount + shipping + tax

  const remainingForFreeShipping = FREE_SHIPPING_THRESHOLD - subtotal

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-5 shadow-card sticky top-32">
      <h3 className="font-bold text-secondary dark:text-white mb-4 pb-3 border-b border-gray-200 dark:border-gray-700">
        Order Summary
      </h3>

      <div className="space-y-2 text-sm mb-4">
        <div className="flex justify-between text-gray-600 dark:text-gray-400">
          <span>Subtotal</span>
          <span className="text-secondary dark:text-white font-medium">
            {formatCurrency(subtotal)}
          </span>
        </div>

        {discount > 0 && (
          <div className="flex justify-between text-success">
            <span>Discount ({coupon.coupon.code})</span>
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
          <span className="text-secondary dark:text-white font-medium">
            {formatCurrency(tax)}
          </span>
        </div>
      </div>

      <div className="pt-4 border-t-2 border-gray-200 dark:border-gray-700 mb-4">
        <div className="flex justify-between items-baseline">
          <span className="font-bold text-secondary dark:text-white">Total</span>
          <span className="text-xl font-bold text-primary">
            {formatCurrency(total)}
          </span>
        </div>
      </div>

      {remainingForFreeShipping > 0 && (
        <div className="flex items-center gap-2 p-3 mb-4 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg text-xs">
          <Truck className="h-4 w-4 text-yellow-600 flex-shrink-0" />
          <span className="text-gray-700 dark:text-gray-300">
            Add <strong>{formatCurrency(remainingForFreeShipping)}</strong> more for FREE shipping!
          </span>
        </div>
      )}

      <Link
        to="/checkout"
        className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-bold py-3 rounded-lg transition"
      >
        <Lock className="h-4 w-4" />
        Proceed to Checkout
      </Link>

      <Link
        to="/products"
        className="block text-center text-sm text-link hover:text-primary mt-3 transition"
      >
        Continue Shopping
      </Link>
    </div>
  )
}
ENDOFFILE

echo "✅ CartSummary.jsx"
echo ""

# ============================================================
# 8. components/wishlist/WishlistSkeleton.jsx
# ============================================================
cat > src/components/wishlist/WishlistSkeleton.jsx << 'ENDOFFILE'
export default function WishlistSkeleton() {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      {[1, 2, 3, 4].map((i) => (
        <div key={i} className="bg-white dark:bg-secondary-light rounded-xl p-3 animate-pulse">
          <div className="w-full h-40 bg-gray-200 dark:bg-gray-700 rounded-lg mb-3" />
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2" />
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3" />
        </div>
      ))}
    </div>
  )
}
ENDOFFILE

echo "✅ WishlistSkeleton.jsx"
echo ""

# ============================================================
# 9. components/wishlist/WishlistGrid.jsx
# ============================================================
cat > src/components/wishlist/WishlistGrid.jsx << 'ENDOFFILE'
import ProductCard from '../product/ProductCard'
import WishlistSkeleton from './WishlistSkeleton'

export default function WishlistGrid({ items, loading }) {
  if (loading) return <WishlistSkeleton />

  if (!items || items.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500">Your wishlist is empty</p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      {items.map((item) => (
        <ProductCard key={item.id} product={item.product} />
      ))}
    </div>
  )
}
ENDOFFILE

echo "✅ WishlistGrid.jsx"
echo ""

# ============================================================
# 10. components/compare/CompareSkeleton.jsx
# ============================================================
cat > src/components/compare/CompareSkeleton.jsx << 'ENDOFFILE'
export default function CompareSkeleton() {
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 animate-pulse">
      {[1, 2, 3, 4].map((i) => (
        <div key={i} className="bg-white dark:bg-secondary-light rounded-xl p-4">
          <div className="w-full h-40 bg-gray-200 dark:bg-gray-700 rounded-lg mb-3" />
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2" />
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3" />
        </div>
      ))}
    </div>
  )
}
ENDOFFILE

echo "✅ CompareSkeleton.jsx"
echo ""

# ============================================================
# 11. components/compare/CompareCard.jsx
# ============================================================
cat > src/components/compare/CompareCard.jsx << 'ENDOFFILE'
import { Link } from 'react-router-dom'
import { X } from 'lucide-react'
import { formatCurrency } from '../../lib/utils'
import RatingStars from '../product/RatingStars'

export default function CompareCard({ item, onRemove }) {
  const p = item.product
  if (!p) return null

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-4 relative">
      <button
        onClick={() => onRemove(p.id)}
        className="absolute top-2 right-2 w-7 h-7 rounded-full bg-gray-100 dark:bg-secondary flex items-center justify-center text-gray-500 hover:text-danger hover:bg-red-50 dark:hover:bg-red-900/20 transition"
      >
        <X className="h-4 w-4" />
      </button>

      <Link to={`/products/${p.slug}`}>
        <img
          src={p.thumbnail}
          alt={p.title}
          className="w-full h-40 object-contain mb-3"
        />
      </Link>

      <Link to={`/products/${p.slug}`}>
        <h4 className="text-sm font-medium line-clamp-2 mb-2 min-h-[40px] text-secondary dark:text-white hover:text-primary transition">
          {p.title}
        </h4>
      </Link>

      <div className="mb-2">
        <RatingStars rating={p.rating || 0} showValue count={p.num_reviews} />
      </div>

      <div className="text-lg font-bold text-primary">
        {formatCurrency(p.price)}
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ CompareCard.jsx"
echo ""

# ============================================================
# 12. components/compare/CompareTable.jsx
# ============================================================
cat > src/components/compare/CompareTable.jsx << 'ENDOFFILE'
import { useCompare } from '../../context/CompareContext'
import { useCart } from '../../context/CartContext'
import { useNavigate } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'
import toast from 'react-hot-toast'
import RatingStars from '../product/RatingStars'
import { formatCurrency } from '../../lib/utils'

export default function CompareTable({ items }) {
  const { removeFromCompare, clearCompare } = useCompare()
  const { addToCart } = useCart()
  const navigate = useNavigate()

  const products = items.map((i) => i.product).filter(Boolean)

  if (products.length === 0) return null

  const handleAddToCart = async (productId) => {
    try {
      await addToCart(productId, 1)
      toast.success('Added to cart')
    } catch (err) {
      toast.error(err.message || 'Failed')
    }
  }

  return (
    <div>
      {/* Cards for mobile */}
      <div className="lg:hidden grid grid-cols-2 gap-4 mb-6">
        {products.map((p) => (
          <div key={p.id} className="bg-white dark:bg-secondary-light rounded-xl p-4">
            <img src={p.thumbnail} alt={p.title} className="w-full h-32 object-contain mb-2" />
            <h4 className="text-xs font-medium line-clamp-2 mb-2 min-h-[32px]">{p.title}</h4>
            <div className="text-sm font-bold text-primary">{formatCurrency(p.price)}</div>
            <button
              onClick={() => removeFromCompare(p.id)}
              className="text-xs text-danger mt-2"
            >
              Remove
            </button>
          </div>
        ))}
      </div>

      {/* Table for desktop */}
      <div className="hidden lg:block overflow-x-auto bg-white dark:bg-secondary-light rounded-xl shadow-card">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-200 dark:border-gray-700">
              <th className="p-4 text-left text-sm font-semibold text-gray-500 w-40">Product</th>
              {products.map((p) => (
                <th key={p.id} className="p-4 text-center min-w-[200px]">
                  <div className="relative">
                    <button
                      onClick={() => removeFromCompare(p.id)}
                      className="absolute -top-2 right-0 text-gray-400 hover:text-danger text-xs"
                    >
                      ✕
                    </button>
                    <img src={p.thumbnail} alt={p.title} className="w-full h-32 object-contain mb-2" />
                    <h4 className="text-sm font-medium line-clamp-2 min-h-[40px]">{p.title}</h4>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="text-sm">
            <tr className="border-b border-gray-200 dark:border-gray-700">
              <td className="p-4 font-semibold text-gray-500">Price</td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center font-bold text-primary">
                  {formatCurrency(p.price)}
                </td>
              ))}
            </tr>

            <tr className="border-b border-gray-200 dark:border-gray-700">
              <td className="p-4 font-semibold text-gray-500">Rating</td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center">
                  <div className="flex justify-center">
                    <RatingStars rating={p.rating || 0} showValue />
                  </div>
                </td>
              ))}
            </tr>

            <tr className="border-b border-gray-200 dark:border-gray-700">
              <td className="p-4 font-semibold text-gray-500">Reviews</td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center text-gray-600 dark:text-gray-400">
                  {p.num_reviews || 0}
                </td>
              ))}
            </tr>

            <tr className="border-b border-gray-200 dark:border-gray-700">
              <td className="p-4 font-semibold text-gray-500">Brand</td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center text-gray-600 dark:text-gray-400">
                  {p.brand?.name || '—'}
                </td>
              ))}
            </tr>

            <tr className="border-b border-gray-200 dark:border-gray-700">
              <td className="p-4 font-semibold text-gray-500">Stock</td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center">
                  {p.stock > 0 ? (
                    <span className="text-success">In Stock ({p.stock})</span>
                  ) : (
                    <span className="text-danger">Out of Stock</span>
                  )}
                </td>
              ))}
            </tr>

            <tr>
              <td className="p-4"></td>
              {products.map((p) => (
                <td key={p.id} className="p-4 text-center">
                  <button
                    onClick={() => handleAddToCart(p.id)}
                    disabled={p.stock <= 0}
                    className="inline-flex items-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-semibold px-4 py-2 rounded-lg text-xs disabled:opacity-50 transition"
                  >
                    <ShoppingCart className="h-3.5 w-3.5" />
                    Add to Cart
                  </button>
                </td>
              ))}
            </tr>
          </tbody>
        </table>
      </div>

      <div className="text-right mt-4">
        <button
          onClick={() => {
            clearCompare()
            navigate('/products')
          }}
          className="text-sm text-danger hover:underline"
        >
          Clear compare list
        </button>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ CompareTable.jsx"
echo ""

# ============================================================
# 13. pages/Cart.jsx
# ============================================================
cat > src/pages/Cart.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { useCart } from '../context/CartContext'
import CartItem from '../components/cart/CartItem'
import CartSummary from '../components/cart/CartSummary'
import CouponForm from '../components/cart/CouponForm'
import EmptyCart from '../components/cart/EmptyCart'
import CartSkeleton from '../components/cart/CartSkeleton'

export default function Cart() {
  const { items, subtotal, loading } = useCart()
  const [appliedCoupon, setAppliedCoupon] = useState(null)

  if (loading) {
    return (
      <div className="container-page py-8">
        <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">Shopping Cart</h1>
        <CartSkeleton />
      </div>
    )
  }

  if (items.length === 0) {
    return (
      <div className="container-page py-8">
        <EmptyCart />
      </div>
    )
  }

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        Shopping Cart ({items.length} {items.length === 1 ? 'item' : 'items'})
      </h1>

      <div className="grid lg:grid-cols-[1fr_360px] gap-6">
        <div className="space-y-4">
          <div className="bg-white dark:bg-secondary-light rounded-xl p-4 shadow-card">
            <h3 className="font-semibold mb-3 text-secondary dark:text-white">Have a coupon?</h3>
            <CouponForm
              subtotal={subtotal}
              applied={appliedCoupon}
              onApply={setAppliedCoupon}
              onRemove={() => setAppliedCoupon(null)}
            />
          </div>

          <div className="space-y-3">
            {items.map((item) => (
              <CartItem key={item.id} item={item} />
            ))}
          </div>
        </div>

        <div>
          <CartSummary subtotal={subtotal} coupon={appliedCoupon} />
        </div>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ Cart.jsx"
echo ""

# ============================================================
# 14. pages/Wishlist.jsx
# ============================================================
cat > src/pages/Wishlist.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { useWishlist } from '../context/WishlistContext'
import WishlistGrid from '../components/wishlist/WishlistGrid'

export default function Wishlist() {
  const { items, reload } = useWishlist()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    reload().finally(() => setLoading(false))
  }, [])

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        My Wishlist ({items.length})
      </h1>

      <WishlistGrid items={items} loading={loading} />
    </div>
  )
}
ENDOFFILE

echo "✅ Wishlist.jsx"
echo ""

# ============================================================
# 15. pages/Compare.jsx
# ============================================================
cat > src/pages/Compare.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useCompare } from '../context/CompareContext'
import CompareTable from '../components/compare/CompareTable'
import CompareSkeleton from '../components/compare/CompareSkeleton'
import Button from '../components/ui/Button'

export default function Compare() {
  const { items, reload } = useCompare()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    reload().finally(() => setLoading(false))
  }, [])

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        Compare Products ({items.length}/4)
      </h1>

      {loading ? (
        <CompareSkeleton />
      ) : items.length === 0 ? (
        <div className="text-center py-16">
          <h2 className="text-xl font-bold mb-2 text-secondary dark:text-white">
            No products to compare
          </h2>
          <p className="text-gray-500 mb-6">
            Add up to 4 products to compare their features side by side.
          </p>
          <Link to="/products">
            <Button>Browse Products</Button>
          </Link>
        </div>
      ) : (
        <CompareTable items={items} />
      )}
    </div>
  )
}
ENDOFFILE

echo "✅ Compare.jsx"
echo ""

echo "🎉 All components + pages created!"
echo ""
echo "📁 Now updating App.jsx and Layout.jsx..."
echo "   Run update-app-shopping.sh next"
echo ""
