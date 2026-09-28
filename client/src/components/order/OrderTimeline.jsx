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
