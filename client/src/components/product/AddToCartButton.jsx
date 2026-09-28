import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ShoppingCart, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { useCart } from '../../context/CartContext'
import { useAuth } from '../../context/AuthContext'

export default function AddToCartButton({ productId, stock = 10, disabled = false, quantity = 1 }) {
  const navigate = useNavigate()
  const { addToCart } = useCart()
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)
  const [added, setAdded] = useState(false)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }

    if (stock <= 0) {
      toast.error('Out of stock')
      return
    }

    setLoading(true)
    try {
      await addToCart(productId, quantity)
      toast.success('Added to cart')
      setAdded(true)
      setTimeout(() => setAdded(false), 2000)
    } catch (err) {
      toast.error(err.message || 'Failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <button
      onClick={handleClick}
      disabled={disabled || loading || stock <= 0}
      className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark text-secondary font-bold py-3 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {added ? (
        <>
          <Check className="h-5 w-5" />
          Added to Cart
        </>
      ) : (
        <>
          <ShoppingCart className="h-5 w-5" />
          {loading ? 'Adding...' : stock <= 0 ? 'Out of Stock' : 'Add to Cart'}
        </>
      )}
    </button>
  )
}
