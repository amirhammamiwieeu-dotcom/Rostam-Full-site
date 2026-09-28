import { Link } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'

export default function AuthLayout({ title, subtitle, children, footer }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-secondary-dark dark:to-secondary flex flex-col">
      <div className="py-8 text-center">
        <Link to="/" className="inline-flex items-center gap-2 text-3xl font-black">
          <ShoppingCart className="h-8 w-8 text-primary" />
          <span className="text-secondary dark:text-white">Market</span>
          <span className="text-primary">Hub</span>
        </Link>
      </div>

      <div className="flex-1 flex items-start justify-center px-4 pb-12">
        <div className="w-full max-w-md bg-white dark:bg-secondary-light rounded-2xl shadow-xl p-8">
          {title && (
            <div className="mb-6">
              <h1 className="text-2xl font-bold text-secondary dark:text-white mb-1">{title}</h1>
              {subtitle && <p className="text-sm text-gray-500">{subtitle}</p>}
            </div>
          )}

          {children}

          {footer && (
            <div className="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700 text-center text-sm">
              {footer}
            </div>
          )}
        </div>
      </div>

      <div className="bg-secondary-dark py-6 text-center text-xs text-gray-500">
        <div className="flex justify-center gap-6 mb-2">
          <a href="#" className="hover:text-primary transition">Conditions of Use</a>
          <a href="#" className="hover:text-primary transition">Privacy Notice</a>
          <a href="#" className="hover:text-primary transition">Help</a>
        </div>
        <p>© {new Date().getFullYear()} MarketHub. All rights reserved.</p>
      </div>
    </div>
  )
}
