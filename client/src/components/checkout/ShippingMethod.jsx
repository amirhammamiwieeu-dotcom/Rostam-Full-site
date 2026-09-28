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
