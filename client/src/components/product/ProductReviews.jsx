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
