import { useState } from 'react'
import { Tag, X, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { api } from '../../lib/api'
import { formatCurrency } from '../../lib/utils'

export default function CouponForm({ subtotal, applied, onApply, onRemove }) {
  const [code, setCode] = useState('')
  const [loading, setLoading] = useState(false)

  const handleApply = async (e) => {
    e.preventDefault()
    if (!code.trim()) return

    setLoading(true)
    try {
      const res = await api.post('/cart/coupon', { code: code.trim().toUpperCase() })
      onApply(res.data)
      toast.success('Coupon applied!')
      setCode('')
    } catch (err) {
      toast.error(err.message || 'Invalid coupon')
    } finally {
      setLoading(false)
    }
  }

  if (applied) {
    return (
      <div className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
        <div className="flex items-center gap-2">
          <Check className="h-4 w-4 text-success" />
          <span className="text-sm font-semibold text-success">
            {applied.coupon.code}
          </span>
          <span className="text-xs text-gray-600 dark:text-gray-400">
            −{formatCurrency(applied.discountAmount)}
          </span>
        </div>
        <button
          onClick={onRemove}
          className="text-gray-500 hover:text-danger transition"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    )
  }

  return (
    <form onSubmit={handleApply} className="flex gap-2">
      <div className="flex-1 relative">
        <Tag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          value={code}
          onChange={(e) => setCode(e.target.value.toUpperCase())}
          placeholder="Coupon code"
          className="w-full pl-10 pr-3 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary"
        />
      </div>
      <button
        type="submit"
        disabled={loading || !code.trim()}
        className="px-4 py-2.5 bg-secondary hover:bg-secondary-light text-white rounded-lg text-sm font-semibold disabled:opacity-50 transition"
      >
        {loading ? '...' : 'Apply'}
      </button>
    </form>
  )
}
