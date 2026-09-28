import { Link, useNavigate } from 'react-router-dom'
import { Heart, ShoppingCart, TrendingUp } from 'lucide-react'
import toast from 'react-hot-toast'
import RatingStars from './RatingStars'
import { formatCurrency } from '../../lib/utils'
import { calculateDiscount } from '../../lib/productHelpers'
import { useCart } from '../../context/CartContext'
import { useWishlist } from '../../context/WishlistContext'
import { useAuth } from '../../context/AuthContext'

export default function ProductCard({ product, compact = false }) {
  const navigate = useNavigate()
  const { addToCart } = useCart()
  const { toggleWishlist, isWished } = useWishlist()
  const { user } = useAuth()

  const discount = calculateDiscount(product.price, product.old_price)
  const wished = isWished(product.id)

  const handleAddToCart = async (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (!user) {
      toast.error('Please sign in to add items')
      navigate('/login')
      return
    }
    try {
      await addToCart(product.id, 1)
      toast.success('Added to cart')
    } catch (err) {
      toast.error(err.message || 'Failed to add to cart')
    }
  }

  const handleWishlist = async (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      const result = await toggleWishlist(product.id)
      toast.success(result.added ? 'Added to wishlist' : 'Removed from wishlist')
    } catch (err) {
      toast.error('Failed to update wishlist')
    }
  }

  return (
    <Link
      to={`/products/${product.slug}`}
      className="group bg-white dark:bg-secondary-light rounded-xl p-3 hover:shadow-xl hover:-translate-y-1 transition-all duration-200 border border-gray-100 dark:border-gray-800"
    >
      <div className="relative">
        <div className="w-full h-40 flex items-center justify-center overflow-hidden rounded-lg bg-gray-50 dark:bg-secondary mb-3">
          <img
            src={product.thumbnail}
            alt={product.title}
            className="max-h-full max-w-full object-contain group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        </div>

        {discount > 0 && (
          <span className="absolute top-2 left-2 bg-primary text-secondary text-xs font-bold px-2 py-0.5 rounded-full">
            -{discount}%
          </span>
        )}

        <button
          onClick={handleWishlist}
          className={`absolute top-2 right-2 w-8 h-8 rounded-full bg-white/90 dark:bg-secondary flex items-center justify-center transition shadow ${
            wished ? 'text-danger' : 'text-gray-400 hover:text-danger'
          }`}
          aria-label="Add to wishlist"
        >
          <Heart className={`h-4 w-4 ${wished ? 'fill-danger' : ''}`} />
        </button>
      </div>

      <div>
        <h3 className="text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-1.5 min-h-[40px]">
          {product.title}
        </h3>

        <div className="mb-2">
          <RatingStars
            rating={product.rating || 0}
            showValue
            count={product.num_reviews}
          />
        </div>

        <div className="flex items-baseline gap-2 mb-2">
          <span className="text-lg font-bold text-secondary dark:text-white">
            {formatCurrency(product.price)}
          </span>
          {product.old_price && (
            <span className="text-xs text-gray-400 line-through">
              {formatCurrency(product.old_price)}
            </span>
          )}
        </div>

        {product.is_prime && (
          <div className="flex items-center gap-1 text-xs text-link mb-2">
            <TrendingUp className="h-3 w-3" />
            <span className="font-semibold">Prime</span>
          </div>
        )}

        {!compact && (
          <button
            onClick={handleAddToCart}
            className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-semibold text-sm py-2 rounded-lg transition"
          >
            <ShoppingCart className="h-4 w-4" />
            Add to Cart
          </button>
        )}
      </div>
    </Link>
  )
}
