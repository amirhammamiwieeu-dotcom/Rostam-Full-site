import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Star } from 'lucide-react'
import toast from 'react-hot-toast'
import Button from '../ui/Button'
import { api } from '../../lib/api'
import { useAuth } from '../../context/AuthContext'

export default function ReviewForm({ productId, onSuccess }) {
  const { user } = useAuth()
  const navigate = useNavigate()

  const [rating, setRating] = useState(0)
  const [hoverRating, setHoverRating] = useState(0)
  const [title, setTitle] = useState('')
  const [text, setText] = useState('')
  const [loading, setLoading] = useState(false)

  if (!user) {
    return (
      <div className="bg-gray-50 dark:bg-secondary p-6 rounded-xl text-center">
        <p className="text-sm text-gray-600 dark:text-gray-400 mb-3">
          Please sign in to write a review
        </p>
        <Button onClick={() => navigate('/login')}>Sign In</Button>
      </div>
    )
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (rating < 1) return toast.error('Please select a rating')
    if (text.trim().length < 5) return toast.error('Review must be at least 5 characters')

    setLoading(true)
    try {
      await api.post('/comments', {
        product_id: productId,
        rating,
        title: title.trim() || null,
        text: text.trim(),
      })
      toast.success('Review submitted!')
      setRating(0)
      setTitle('')
      setText('')
      if (onSuccess) onSuccess()
    } catch (err) {
      toast.error(err.message || 'Failed to submit review')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="bg-gray-50 dark:bg-secondary p-5 rounded-xl">
      <h3 className="font-bold text-secondary dark:text-white mb-4">
        Write a Review
      </h3>

      <div className="mb-4">
        <label className="block text-sm font-medium mb-2 text-secondary dark:text-white">
          Your Rating
        </label>
        <div className="flex gap-1">
          {[1, 2, 3, 4, 5].map((star) => (
            <button
              key={star}
              type="button"
              onClick={() => setRating(star)}
              onMouseEnter={() => setHoverRating(star)}
              onMouseLeave={() => setHoverRating(0)}
              className="transition-transform hover:scale-110"
            >
              <Star
                className={`h-7 w-7 ${
                  star <= (hoverRating || rating)
                    ? 'text-yellow-500 fill-yellow-500'
                    : 'text-gray-300'
                }`}
              />
            </button>
          ))}
        </div>
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium mb-2 text-secondary dark:text-white">
          Title (optional)
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Summary of your review"
          maxLength={150}
          className="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
        />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium mb-2 text-secondary dark:text-white">
          Your Review
        </label>
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Share your thoughts about this product..."
          rows={4}
          maxLength={2000}
          className="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary resize-y"
        />
      </div>

      <Button type="submit" disabled={loading}>
        {loading ? 'Submitting...' : 'Submit Review'}
      </Button>
    </form>
  )
}
