import { forwardRef } from 'react'
import { cn } from '../../lib/utils'

const Input = forwardRef(function Input({ label, error, icon: Icon, className, ...props }, ref) {
  return (
    <div className="w-full">
      {label && <label className="block text-sm font-medium mb-1.5 text-secondary">{label}</label>}
      <div className="relative">
        {Icon && <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none"><Icon className="h-5 w-5 text-gray-400" /></div>}
        <input ref={ref} className={cn('w-full px-4 py-2.5 border border-gray-300 rounded-lg outline-none transition text-secondary', 'focus:border-primary focus:ring-2 focus:ring-primary/20', Icon && 'pl-10', error && 'border-danger', className)} {...props} />
      </div>
      {error && <p className="mt-1 text-sm text-danger">{error}</p>}
    </div>
  )
})

export default Input
