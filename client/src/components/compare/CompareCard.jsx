import { Link } from 'react-router-dom'
import { X } from 'lucide-react'
import { formatCurrency } from '../../lib/utils'
import RatingStars from '../product/RatingStars'

export default function CompareCard({ item, onRemove }) {
  const p = item.product
  if (!p) return null

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-4 relative">
      <button
        onClick={() => onRemove(p.id)}
        className="absolute top-2 right-2 w-7 h-7 rounded-full bg-gray-100 dark:bg-secondary flex items-center justify-center text-gray-500 hover:text-danger hover:bg-red-50 dark:hover:bg-red-900/20 transition"
      >
        <X className="h-4 w-4" />
      </button>

      <Link to={`/products/${p.slug}`}>
        <img
          src={p.thumbnail}
          alt={p.title}
          className="w-full h-40 object-contain mb-3"
        />
      </Link>

      <Link to={`/products/${p.slug}`}>
        <h4 className="text-sm font-medium line-clamp-2 mb-2 min-h-[40px] text-secondary dark:text-white hover:text-primary transition">
          {p.title}
        </h4>
      </Link>

      <div className="mb-2">
        <RatingStars rating={p.rating || 0} showValue count={p.num_reviews} />
      </div>

      <div className="text-lg font-bold text-primary">
        {formatCurrency(p.price)}
      </div>
    </div>
  )
}
