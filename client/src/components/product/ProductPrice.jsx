import { formatCurrency } from '../../lib/utils'
import { calculateDiscount } from '../../lib/productHelpers'

export default function ProductPrice({ price, oldPrice, size = 'md' }) {
  const discount = calculateDiscount(price, oldPrice)
  const sizes = {
    sm: 'text-base',
    md: 'text-2xl',
    lg: 'text-3xl',
  }

  return (
    <div className="flex flex-wrap items-baseline gap-2">
      <span className={`${sizes[size]} font-bold text-secondary dark:text-white`}>
        {formatCurrency(price)}
      </span>
      {oldPrice && discount > 0 && (
        <>
          <span className="text-sm text-gray-400 line-through">
            {formatCurrency(oldPrice)}
          </span>
          <span className="text-sm font-bold text-primary">
            Save {discount}%
          </span>
        </>
      )}
    </div>
  )
}
