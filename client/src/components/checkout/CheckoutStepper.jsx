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
