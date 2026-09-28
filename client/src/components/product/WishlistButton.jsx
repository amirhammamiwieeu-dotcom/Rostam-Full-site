import { useNavigate } from 'react-router-dom'
import { Heart } from 'lucide-react'
import toast from 'react-hot-toast'
import { useWishlist } from '../../context/WishlistContext'
import { useAuth } from '../../context/AuthContext'

export default function WishlistButton({ productId }) {
  const navigate = useNavigate()
  const { isWished, toggleWishlist } = useWishlist()
  const { user } = useAuth()
  const wished = isWished(productId)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      const result = await toggleWishlist(productId)
      toast.success(result.added ? 'Added to wishlist' : 'Removed from wishlist')
    } catch (err) {
      toast.error('Failed')
    }
  }

  return (
    <button
      onClick={handleClick}
      className={`flex items-center gap-2 px-4 py-3 border rounded-lg transition font-medium ${
        wished
          ? 'border-danger text-danger bg-red-50 dark:bg-red-900/10'
          : 'border-gray-300 dark:border-gray-700 text-secondary dark:text-white hover:border-danger hover:text-danger'
      }`}
    >
      <Heart className={`h-5 w-5 ${wished ? 'fill-danger' : ''}`} />
      {wished ? 'Saved' : 'Wishlist'}
    </button>
  )
}
