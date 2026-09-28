import { cn } from '../../lib/utils'

export default function Button({ children, variant = 'primary', size = 'md', className, ...props }) {
  const variants = {
    primary: 'bg-primary hover:bg-primary-dark text-secondary font-semibold',
    secondary: 'bg-white border border-gray-300 hover:border-primary hover:text-primary text-secondary',
    ghost: 'hover:bg-gray-100 text-secondary',
    danger: 'bg-danger hover:bg-red-700 text-white',
    outline: 'border-2 border-primary text-primary hover:bg-primary hover:text-secondary',
  }
  const sizes = { sm: 'px-3 py-1.5 text-sm', md: 'px-4 py-2 text-sm', lg: 'px-6 py-3 text-base' }
  return (
    <button className={cn('inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed', variants[variant], sizes[size], className)} {...props}>
      {children}
    </button>
  )
}
