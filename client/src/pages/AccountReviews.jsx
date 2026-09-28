import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { MessageSquare, Star } from 'lucide-react'
import UserLayout from '../components/user/UserLayout'
import RatingStars from '../components/product/RatingStars'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'
import { formatRelativeTime } from '../lib/utils'

export default function AccountReviews() {
  const [reviews, setReviews] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/comments/my')
      .then((res) => setReviews(res.data.comments || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  return (
    <UserLayout
      title="My Reviews"
      description="Reviews you've written"
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : reviews.length === 0 ? (
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
          <MessageSquare className="h-12 w-12 text-gray-300 mx-auto mb-3" />
          <h3 className="font-bold mb-2 text-secondary dark:text-white">
            No reviews yet
          </h3>
          <p className="text-sm text-gray-500 mb-5">
            Buy a product and share your thoughts
          </p>
          <Link to="/products" className="text-link hover:text-primary text-sm">
            Browse products →
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {reviews.map((review) => (
            <div
              key={review.id}
              className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-4"
            >
              <div className="flex gap-3">
                <Link to={`/products/${review.product?.slug}`} className="flex-shrink-0">
                  <img
                    src={review.product?.thumbnail}
                    alt=""
                    className="w-16 h-16 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
                  />
                </Link>
                <div className="flex-1 min-w-0">
                  <Link
                    to={`/products/${review.product?.slug}`}
                    className="font-medium text-sm text-secondary dark:text-white hover:text-primary transition line-clamp-2"
                  >
                    {review.product?.title}
                  </Link>
                  <div className="flex items-center gap-2 mt-1.5">
                    <RatingStars rating={review.rating} />
                    <span className="text-xs text-gray-500">
                      {formatRelativeTime(review.created_at)}
                    </span>
                  </div>
                  {review.title && (
                    <div className="font-semibold text-xs mt-2 text-secondary dark:text-white">
                      {review.title}
                    </div>
                  )}
                  <p className="text-xs text-gray-600 dark:text-gray-400 mt-1 leading-relaxed">
                    {review.text}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </UserLayout>
  )
}
