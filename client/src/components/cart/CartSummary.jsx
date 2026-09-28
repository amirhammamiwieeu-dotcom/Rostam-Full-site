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
