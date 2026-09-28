import { useState } from 'react'
import { ThumbsUp, ThumbsDown, BadgeCheck } from 'lucide-react'
import RatingStars from './RatingStars'
import { formatRelativeTime } from '../../lib/utils'

export default function ReviewList({ reviews = [] }) {
  const [voted, setVoted] = useState({})

  if (reviews.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500 text-sm">
        No reviews yet. Be the first to review this product!
      </div>
    )
  }

  const handleVote = (reviewId, type) => {
    setVoted((v) => ({ ...v, [reviewId]: type }))
  }

  return (
    <div className="space-y-5">
      {reviews.map((review) => (
        <div key={review.id} className="pb-5 border-b border-gray-200 dark:border-gray-700 last:border-0">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-sm flex-shrink-0">
              {(review.user?.full_name || 'A').charAt(0).toUpperCase()}
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <span className="font-medium text-sm text-secondary dark:text-white">
                  {review.user?.full_name || 'Anonymous'}
                </span>
                {review.is_verified_purchase && (
                  <span className="flex items-center gap-1 text-xs text-success">
                    <BadgeCheck className="h-3.5 w-3.5" />
                    Verified Purchase
                  </span>
                )}
              </div>
              <div className="flex items-center gap-3">
                <RatingStars rating={review.rating} />
                <span className="text-xs text-gray-500">
                  {formatRelativeTime(review.created_at)}
                </span>
              </div>
            </div>
          </div>

          {review.title && (
            <h4 className="font-semibold text-sm mb-1 text-secondary dark:text-white">
              {review.title}
            </h4>
          )}
          <p className="text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
            {review.text}
          </p>

          {review.admin_reply && (
            <div className="mt-3 ml-4 pl-4 border-l-2 border-primary bg-gray-50 dark:bg-secondary p-3 rounded">
              <div className="text-xs font-semibold text-primary mb-1">
                MarketHub Response
              </div>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                {review.admin_reply}
              </p>
            </div>
          )}

          <div className="flex items-center gap-4 mt-3 text-xs text-gray-500">
            <span>Helpful?</span>
            <button
              onClick={() => handleVote(review.id, 'helpful')}
              className={`flex items-center gap-1 hover:text-primary transition ${
                voted[review.id] === 'helpful' ? 'text-primary font-semibold' : ''
              }`}
            >
              <ThumbsUp className="h-3.5 w-3.5" />
              Yes ({review.helpful_count || 0})
            </button>
            <button
              onClick={() => handleVote(review.id, 'not_helpful')}
              className={`flex items-center gap-1 hover:text-primary transition ${
                voted[review.id] === 'not_helpful' ? 'text-primary font-semibold' : ''
              }`}
            >
              <ThumbsDown className="h-3.5 w-3.5" />
              No ({review.not_helpful_count || 0})
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}
