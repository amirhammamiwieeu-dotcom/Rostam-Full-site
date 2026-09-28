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
