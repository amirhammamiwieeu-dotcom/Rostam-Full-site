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
