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
