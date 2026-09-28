import { Check, Truck, Shield, RotateCcw } from 'lucide-react'
import ProductPrice from './ProductPrice'
import RatingStars from './RatingStars'

export default function ProductInfo({ product }) {
  const inStock = product.stock > 0

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl md:text-3xl font-bold text-secondary dark:text-white mb-3">
          {product.title}
        </h1>

        <div className="flex items-center gap-4 mb-4">
          <RatingStars
            rating={product.rating || 0}
            size="md"
            showValue
            count={product.num_reviews}
          />
          {product.brand && (
            <>
              <span className="text-gray-300">|</span>
              <span className="text-sm text-gray-600 dark:text-gray-400">
                Brand: <span className="text-link hover:text-primary cursor-pointer">{product.brand.name}</span>
              </span>
            </>
          )}
        </div>
      </div>

      <div className="pb-5 border-b border-gray-200 dark:border-gray-700">
        <ProductPrice price={product.price} oldPrice={product.old_price} size="lg" />
        <p className="text-xs text-gray-500 mt-1">
          Price includes applicable taxes
        </p>
      </div>

      <div className="space-y-2.5">
        <div className="flex items-center gap-2 text-sm">
          {inStock ? (
            <>
              <Check className="h-5 w-5 text-success" />
              <span className="text-success font-semibold">In Stock</span>
            </>
          ) : (
            <span className="text-danger font-semibold">Out of Stock</span>
          )}
        </div>

        {product.is_prime && (
          <div className="flex items-center gap-2 text-sm">
            <Truck className="h-5 w-5 text-primary" />
            <span className="text-secondary dark:text-white">
              <span className="font-semibold">Prime</span> — FREE delivery
            </span>
          </div>
        )}

        <div className="flex items-center gap-2 text-sm">
          <RotateCcw className="h-5 w-5 text-link" />
          <span className="text-secondary dark:text-white">
            FREE returns within 30 days
          </span>
        </div>

        <div className="flex items-center gap-2 text-sm">
          <Shield className="h-5 w-5 text-link" />
          <span className="text-secondary dark:text-white">
            Secure transaction
          </span>
        </div>
      </div>

      {product.short_description && (
        <div className="pb-5 border-b border-gray-200 dark:border-gray-700">
          <h3 className="font-semibold text-sm mb-2 text-secondary dark:text-white">
            About this item
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
            {product.short_description}
          </p>
        </div>
      )}

      {product.features && product.features.length > 0 && (
        <div>
          <h3 className="font-semibold text-sm mb-2 text-secondary dark:text-white">
            Key Features
          </h3>
          <ul className="space-y-1.5">
            {product.features.map((f, i) => (
              <li key={i} className="flex items-start gap-2 text-sm text-gray-600 dark:text-gray-400">
                <Check className="h-4 w-4 text-success flex-shrink-0 mt-0.5" />
                {f}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
