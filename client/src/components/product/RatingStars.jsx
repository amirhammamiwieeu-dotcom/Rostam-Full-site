import { Star } from 'lucide-react'

export default function RatingStars({ rating = 0, size = 'sm', showValue = false, count = null }) {
  const sizes = { sm: 'h-3.5 w-3.5', md: 'h-4 w-4', lg: 'h-5 w-5' }
  const starSize = sizes[size] || sizes.sm

  return (
    <div className="flex items-center gap-1">
      <div className="flex">
        {[1, 2, 3, 4, 5].map((star) => {
          const fill = Math.min(Math.max(rating - star + 1, 0), 1)
          return (
            <div key={star} className="relative">
              <Star className={`${starSize} text-gray-300`} />
              <div
                className="absolute inset-0 overflow-hidden"
                style={{ width: `${fill * 100}%` }}
              >
                <Star className={`${starSize} text-yellow-500 fill-yellow-500`} />
              </div>
            </div>
          )
        })}
      </div>
      {showValue && (
        <span className="text-xs text-link hover:text-primary cursor-pointer">
          {rating.toFixed(1)}
        </span>
      )}
      {count !== null && (
        <span className="text-xs text-gray-500">({count.toLocaleString()})</span>
      )}
    </div>
  )
}
