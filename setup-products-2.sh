#!/bin/bash

set -e

echo "🚀 Creating Products pages - Part 2..."

cd client

# ساخت پوشه‌ها
mkdir -p src/components/product
mkdir -p src/pages

# ============================================================
# 1. RatingSummary.jsx
# ============================================================
cat > src/components/product/RatingSummary.jsx << 'EOF'
import RatingStars from './RatingStars'

export default function RatingSummary({ average = 0, total = 0, distribution = {} }) {
  const totalCount = Object.values(distribution).reduce((s, c) => s + c, 0) || total

  return (
    <div className="grid md:grid-cols-[200px_1fr] gap-6 pb-6 border-b border-gray-200 dark:border-gray-700">
      <div className="text-center md:text-left">
        <div className="text-5xl font-bold text-secondary dark:text-white">
          {average.toFixed(1)}
        </div>
        <div className="my-2 flex justify-center md:justify-start">
          <RatingStars rating={average} size="md" />
        </div>
        <div className="text-sm text-gray-500">
          {totalCount.toLocaleString()} ratings
        </div>
      </div>

      <div className="space-y-1.5">
        {[5, 4, 3, 2, 1].map((star) => {
          const count = distribution[star] || 0
          const pct = totalCount > 0 ? (count / totalCount) * 100 : 0
          return (
            <div key={star} className="flex items-center gap-3 text-sm">
              <span className="w-12 text-gray-600 dark:text-gray-400">{star} star</span>
              <div className="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div
                  className="h-full bg-yellow-500 transition-all"
                  style={{ width: `${pct}%` }}
                />
              </div>
              <span className="w-12 text-right text-gray-500">{Math.round(pct)}%</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
EOF

# ============================================================
# 2. ReviewList.jsx
# ============================================================
cat > src/components/product/ReviewList.jsx << 'EOF'
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
EOF

# ============================================================
# 3. ReviewForm.jsx
# ============================================================
cat > src/components/product/ReviewForm.jsx << 'EOF'
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
EOF

# ============================================================
# 4. ProductReviews.jsx
# ============================================================
cat > src/components/product/ProductReviews.jsx << 'EOF'
import { useState, useEffect } from 'react'
import toast from 'react-hot-toast'
import RatingSummary from './RatingSummary'
import ReviewList from './ReviewList'
import ReviewForm from './ReviewForm'
import Spinner from '../ui/Spinner'
import { api } from '../../lib/api'

export default function ProductReviews({ productId }) {
  const [reviews, setReviews] = useState([])
  const [summary, setSummary] = useState({ average: 0, total: 0, distribution: {} })
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)

  const loadData = async () => {
    setLoading(true)
    try {
      const [revRes, sumRes] = await Promise.all([
        api.get(`/comments/product/${productId}?limit=10`),
        api.get(`/comments/product/${productId}/summary`),
      ])
      setReviews(revRes.data.comments || [])
      setSummary(sumRes.data || { average: 0, total: 0, distribution: {} })
    } catch (err) {
      console.error(err)
      toast.error('Failed to load reviews')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (productId) loadData()
  }, [productId])

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner size="lg" />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <RatingSummary
        average={summary.average}
        total={summary.total}
        distribution={summary.distribution}
      />

      {!showForm ? (
        <button
          onClick={() => setShowForm(true)}
          className="w-full md:w-auto px-6 py-2.5 bg-primary hover:bg-primary-dark text-secondary font-semibold rounded-lg transition"
        >
          Write a Review
        </button>
      ) : (
        <ReviewForm
          productId={productId}
          onSuccess={() => {
            setShowForm(false)
            loadData()
          }}
        />
      )}

      <ReviewList reviews={reviews} />
    </div>
  )
}
EOF

# ============================================================
# 5. RelatedProducts.jsx
# ============================================================
cat > src/components/product/RelatedProducts.jsx << 'EOF'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'
import ProductCard from './ProductCard'
import { api } from '../../lib/api'

export default function RelatedProducts({ productId, title = 'Related Products' }) {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!productId) return
    setLoading(true)
    api.get(`/products/${productId}/related`)
      .then((res) => setProducts(res.data.products || []))
      .catch(() => setProducts([]))
      .finally(() => setLoading(false))
  }, [productId])

  if (!loading && products.length === 0) return null

  return (
    <section className="bg-white dark:bg-secondary-light rounded-xl p-6 shadow-card">
      <div className="flex items-center justify-between mb-5">
        <h3 className="text-xl font-bold text-secondary dark:text-white">{title}</h3>
        <Link to="/products" className="text-sm text-link hover:text-primary flex items-center gap-1">
          View All <ArrowRight className="h-4 w-4" />
        </Link>
      </div>

      {loading ? (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="animate-pulse h-72 bg-gray-200 dark:bg-gray-700 rounded-xl" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {products.slice(0, 8).map((p) => (
            <ProductCard key={p.id} product={p} />
          ))}
        </div>
      )}
    </section>
  )
}
EOF

# ============================================================
# 6. ProductInfo.jsx
# ============================================================
cat > src/components/product/ProductInfo.jsx << 'EOF'
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
EOF

echo ""
echo "✅ Products Part 2 (Components) created!"
echo ""
