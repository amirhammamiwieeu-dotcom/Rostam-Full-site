#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🤖 Adding Gemini Compare to Frontend..."
echo ""

# ============================================================
# 1. CompareGeminiModal.jsx (جدید)
# ============================================================
cat > src/components/compare/CompareGeminiModal.jsx << 'ENDOFFILE'
import { useEffect } from 'react'
import { X, Sparkles, Trophy, DollarSign, Zap, Star, Check, AlertCircle } from 'lucide-react'
import Spinner from '../ui/Spinner'

export default function CompareGeminiModal({ open, onClose, loading, result, error }) {
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    return () => { document.body.style.overflow = 'unset' }
  }, [open])

  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="bg-white dark:bg-secondary-light rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-primary to-primary-dark p-5 flex items-center justify-between">
          <div className="flex items-center gap-3 text-secondary">
            <div className="w-10 h-10 rounded-full bg-white/30 flex items-center justify-center">
              <Sparkles className="h-5 w-5" />
            </div>
            <div>
              <h2 className="font-bold text-lg">AI Product Comparison</h2>
              <p className="text-xs opacity-80">Powered by Google Gemini</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center text-secondary transition"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto p-6">
          {loading && (
            <div className="text-center py-16">
              <Spinner size="lg" />
              <p className="text-sm text-gray-500 mt-4">
                Gemini is analyzing products...
              </p>
            </div>
          )}

          {error && (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-red-100 dark:bg-red-900/20 flex items-center justify-center">
                <AlertCircle className="h-8 w-8 text-danger" />
              </div>
              <h3 className="font-bold text-secondary dark:text-white mb-2">
                Analysis failed
              </h3>
              <p className="text-sm text-gray-500 mb-4">{error}</p>
              <button
                onClick={onClose}
                className="text-link hover:text-primary text-sm"
              >
                Close
              </button>
            </div>
          )}

          {result && result.analysis && (
            <div className="space-y-6">
              {/* Summary */}
              <div className="bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800 rounded-xl p-4">
                <div className="flex items-start gap-3">
                  <Sparkles className="h-5 w-5 text-link flex-shrink-0 mt-0.5" />
                  <div>
                    <h3 className="font-semibold text-sm mb-1 text-secondary dark:text-white">
                      Overall Summary
                    </h3>
                    <p className="text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
                      {result.analysis.summary}
                    </p>
                  </div>
                </div>
              </div>

              {/* Winner */}
              {result.analysis.winner && (
                <div className="bg-yellow-50 dark:bg-yellow-900/10 border-2 border-yellow-400 rounded-xl p-4">
                  <div className="flex items-start gap-3">
                    <Trophy className="h-6 w-6 text-yellow-600 flex-shrink-0" />
                    <div className="flex-1">
                      <h3 className="font-bold text-sm mb-1 text-secondary dark:text-white">
                        🏆 Winner
                      </h3>
                      <p className="font-bold text-base text-primary mb-1">
                        {result.products[result.analysis.winner.product_index]?.title}
                      </p>
                      <p className="text-sm text-gray-700 dark:text-gray-300">
                        {result.analysis.winner.reason}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {/* Best For */}
              {result.analysis.best_for && (
                <div>
                  <h3 className="font-bold text-sm mb-3 text-secondary dark:text-white flex items-center gap-2">
                    <Star className="h-4 w-4 text-primary" />
                    Best For
                  </h3>
                  <div className="grid sm:grid-cols-3 gap-3">
                    {[
                      { key: 'budget', label: 'Budget', icon: DollarSign, color: 'text-green-600' },
                      { key: 'performance', label: 'Performance', icon: Zap, color: 'text-purple-600' },
                      { key: 'value', label: 'Value', icon: Star, color: 'text-blue-600' },
                    ].map(({ key, label, icon: Icon, color }) => {
                      const item = result.analysis.best_for[key]
                      if (!item) return null
                      const product = result.products[item.product_index]
                      return (
                        <div
                          key={key}
                          className="bg-white dark:bg-secondary border border-gray-200 dark:border-gray-700 rounded-xl p-3"
                        >
                          <div className="flex items-center gap-2 mb-2">
                            <Icon className={`h-4 w-4 ${color}`} />
                            <span className="text-xs font-semibold text-gray-500 uppercase">
                              {label}
                            </span>
                          </div>
                          <p className="text-sm font-bold text-secondary dark:text-white mb-1 line-clamp-2">
                            {product?.title || 'N/A'}
                          </p>
                          <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
                            {item.reason}
                          </p>
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}

              {/* Pros & Cons */}
              {result.analysis.pros_cons && result.analysis.pros_cons.length > 0 && (
                <div>
                  <h3 className="font-bold text-sm mb-3 text-secondary dark:text-white">
                    Pros & Cons
                  </h3>
                  <div className="space-y-3">
                    {result.analysis.pros_cons.map((pc, i) => {
                      const product = result.products[pc.product_index]
                      if (!product) return null
                      return (
                        <div
                          key={i}
                          className="bg-white dark:bg-secondary border border-gray-200 dark:border-gray-700 rounded-xl p-4"
                        >
                          <h4 className="font-semibold text-sm mb-3 text-secondary dark:text-white">
                            {product.title}
                          </h4>
                          <div className="grid sm:grid-cols-2 gap-3">
                            <div>
                              <div className="flex items-center gap-1.5 mb-2">
                                <Check className="h-4 w-4 text-success" />
                                <span className="text-xs font-bold text-success uppercase">
                                  Pros
                                </span>
                              </div>
                              <ul className="space-y-1">
                                {pc.pros.map((pro, j) => (
                                  <li
                                    key={j}
                                    className="text-xs text-gray-700 dark:text-gray-300 flex gap-1.5"
                                  >
                                    <span className="text-success">+</span>
                                    {pro}
                                  </li>
                                ))}
                              </ul>
                            </div>
                            <div>
                              <div className="flex items-center gap-1.5 mb-2">
                                <AlertCircle className="h-4 w-4 text-danger" />
                                <span className="text-xs font-bold text-danger uppercase">
                                  Cons
                                </span>
                              </div>
                              <ul className="space-y-1">
                                {pc.cons.map((con, j) => (
                                  <li
                                    key={j}
                                    className="text-xs text-gray-700 dark:text-gray-300 flex gap-1.5"
                                  >
                                    <span className="text-danger">−</span>
                                    {con}
                                  </li>
                                ))}
                              </ul>
                            </div>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}

              {/* Key Differences */}
              {result.analysis.key_differences && result.analysis.key_differences.length > 0 && (
                <div>
                  <h3 className="font-bold text-sm mb-3 text-secondary dark:text-white">
                    Key Differences
                  </h3>
                  <ul className="space-y-2">
                    {result.analysis.key_differences.map((diff, i) => (
                      <li
                        key={i}
                        className="flex gap-2 text-sm text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-secondary p-3 rounded-lg"
                      >
                        <span className="text-primary font-bold flex-shrink-0">
                          {i + 1}.
                        </span>
                        {diff}
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {/* Recommendation */}
              {result.analysis.recommendation && (
                <div className="bg-gradient-to-br from-primary/10 to-primary-dark/10 border-2 border-primary rounded-xl p-4">
                  <div className="flex items-start gap-3">
                    <Sparkles className="h-5 w-5 text-primary flex-shrink-0 mt-0.5" />
                    <div>
                      <h3 className="font-bold text-sm mb-1 text-secondary dark:text-white">
                        Our Recommendation
                      </h3>
                      <p className="text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
                        {result.analysis.recommendation}
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Footer */}
        {result && !loading && (
          <div className="border-t border-gray-200 dark:border-gray-700 p-4 flex justify-end">
            <button
              onClick={onClose}
              className="px-6 py-2 bg-primary hover:bg-primary-dark text-secondary font-semibold rounded-lg transition"
            >
              Done
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ CompareGeminiModal.jsx created"

# ============================================================
# 2. آپدیت CompareTable.jsx (اضافه کردن دکمه)
# ============================================================
cat > src/components/compare/CompareTable.jsx << 'ENDOFFILE'
import { useState } from 'react'
import { useCompare } from '../../context/CompareContext'
import { useCart } from '../../context/CartContext'
import { Link } from 'react-router-dom'
import { ShoppingCart, Trash2, Sparkles } from 'lucide-react'
import toast from 'react-hot-toast'
import RatingStars from '../product/RatingStars'
import CompareGeminiModal from './CompareGeminiModal'
import { api } from '../../lib/api'
import { formatCurrency } from '../../lib/utils'

export default function CompareTable({ items }) {
  const { removeFromCompare, clearCompare } = useCompare()
  const { addToCart } = useCart()

  const [geminiOpen, setGeminiOpen] = useState(false)
  const [geminiLoading, setGeminiLoading] = useState(false)
  const [geminiResult, setGeminiResult] = useState(null)
  const [geminiError, setGeminiError] = useState(null)

  const products = (items || [])
    .map((i) => i.product)
    .filter((p) => p && p.id)

  if (products.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500 mb-4">No products to compare</p>
        <Link to="/products" className="text-link hover:text-primary">
          ← Browse products
        </Link>
      </div>
    )
  }

  const handleAddToCart = async (productId) => {
    try {
      await addToCart(productId, 1)
      toast.success('Added to cart')
    } catch (err) {
      toast.error(err.message || 'Failed')
    }
  }

  const handleRemove = async (productId) => {
    try {
      await removeFromCompare(productId)
      toast.success('Removed')
    } catch (err) {
      toast.error('Failed')
    }
  }

  const handleCompareWithGemini = async () => {
    if (products.length < 2) {
      toast.error('Add at least 2 products to compare')
      return
    }

    setGeminiOpen(true)
    setGeminiLoading(true)
    setGeminiError(null)
    setGeminiResult(null)

    try {
      const productIds = products.map((p) => p.id)
      const res = await api.post('/ai/compare', { product_ids: productIds })
      setGeminiResult(res.data)
    } catch (err) {
      console.error(err)
      setGeminiError(err.message || 'Failed to generate comparison')
    } finally {
      setGeminiLoading(false)
    }
  }

  return (
    <>
      <div className="space-y-6">
        {/* 🤖 Gemini Button */}
        <div className="bg-gradient-to-r from-primary/10 to-primary-dark/10 border-2 border-primary/30 rounded-xl p-4 flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center">
              <Sparkles className="h-5 w-5 text-secondary" />
            </div>
            <div>
              <h3 className="font-bold text-sm text-secondary dark:text-white">
                AI-Powered Comparison
              </h3>
              <p className="text-xs text-gray-600 dark:text-gray-400">
                Let Gemini analyze these {products.length} products for you
              </p>
            </div>
          </div>
          <button
            onClick={handleCompareWithGemini}
            disabled={products.length < 2}
            className="flex items-center gap-2 bg-primary hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed text-secondary font-bold px-5 py-2.5 rounded-lg transition shadow-md"
          >
            <Sparkles className="h-4 w-4" />
            Compare with Gemini
          </button>
        </div>

        {/* Horizontal scrollable table */}
        <div className="overflow-x-auto bg-white dark:bg-secondary-light rounded-xl shadow-card">
          <table className="w-full" style={{ minWidth: `${products.length * 180 + 140}px` }}>
            <thead>
              <tr className="border-b-2 border-gray-200 dark:border-gray-700">
                <th className="p-3 text-left text-xs font-semibold text-gray-500 w-32 align-top bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Feature
                </th>
                {products.map((p) => (
                  <th key={p.id} className="p-3 text-center min-w-[160px] align-top">
                    <div className="relative">
                      <button
                        onClick={() => handleRemove(p.id)}
                        className="absolute -top-1 right-0 w-6 h-6 rounded-full bg-gray-100 dark:bg-secondary flex items-center justify-center text-gray-400 hover:text-danger transition z-10"
                        title="Remove"
                      >
                        <Trash2 className="h-3 w-3" />
                      </button>
                      <Link to={`/products/${p.slug}`}>
                        <img
                          src={p.thumbnail}
                          alt={p.title}
                          className="w-full h-24 object-contain mb-2"
                        />
                        <h4 className="text-xs font-medium line-clamp-2 min-h-[32px] text-secondary dark:text-white hover:text-primary transition">
                          {p.title}
                        </h4>
                      </Link>
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="text-xs">
              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Price
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center">
                    <div className="font-bold text-primary text-sm">
                      {formatCurrency(p.price)}
                    </div>
                    {p.old_price && (
                      <div className="text-[10px] text-gray-400 line-through">
                        {formatCurrency(p.old_price)}
                      </div>
                    )}
                  </td>
                ))}
              </tr>

              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Rating
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center">
                    <div className="flex justify-center">
                      <RatingStars rating={p.rating || 0} />
                    </div>
                    <div className="text-[10px] text-gray-500 mt-1">
                      ({p.num_reviews || 0})
                    </div>
                  </td>
                ))}
              </tr>

              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Brand
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center text-secondary dark:text-gray-300">
                    {p.brand?.name || '—'}
                  </td>
                ))}
              </tr>

              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Stock
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center">
                    {p.stock > 0 ? (
                      <span className="text-success font-medium text-[11px]">
                        ✓ In Stock
                      </span>
                    ) : (
                      <span className="text-danger font-medium text-[11px]">
                        ✗ Out
                      </span>
                    )}
                  </td>
                ))}
              </tr>

              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10">
                  Discount
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center">
                    {p.discount > 0 ? (
                      <span className="bg-primary text-secondary text-[10px] font-bold px-2 py-0.5 rounded-full">
                        -{p.discount}%
                      </span>
                    ) : (
                      <span className="text-gray-400">—</span>
                    )}
                  </td>
                ))}
              </tr>

              <tr className="border-b border-gray-100 dark:border-gray-700/50">
                <td className="p-3 font-semibold text-gray-500 bg-gray-50 dark:bg-secondary sticky left-0 z-10 align-top">
                  Features
                </td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-[11px] align-top">
                    {p.features && p.features.length > 0 ? (
                      <ul className="space-y-0.5 text-left">
                        {p.features.slice(0, 5).map((f, i) => (
                          <li key={i} className="text-gray-600 dark:text-gray-400">
                            • {f}
                          </li>
                        ))}
                      </ul>
                    ) : (
                      <span className="text-gray-400">—</span>
                    )}
                  </td>
                ))}
              </tr>

              <tr>
                <td className="p-3 bg-gray-50 dark:bg-secondary sticky left-0 z-10"></td>
                {products.map((p) => (
                  <td key={p.id} className="p-3 text-center">
                    <button
                      onClick={() => handleAddToCart(p.id)}
                      disabled={p.stock <= 0}
                      className="inline-flex items-center gap-1 bg-primary hover:bg-primary-dark text-secondary font-semibold px-3 py-1.5 rounded-lg text-[11px] disabled:opacity-50 transition"
                    >
                      <ShoppingCart className="h-3 w-3" />
                      Add
                    </button>
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>

        <div className="text-right">
          <button
            onClick={async () => {
              await clearCompare()
              toast.success('Compare list cleared')
            }}
            className="text-sm text-danger hover:underline"
          >
            Clear all
          </button>
        </div>
      </div>

      <CompareGeminiModal
        open={geminiOpen}
        onClose={() => setGeminiOpen(false)}
        loading={geminiLoading}
        result={geminiResult}
        error={geminiError}
      />
    </>
  )
}
ENDOFFILE

echo "✅ CompareTable.jsx updated with Gemini button"

echo ""
echo "🎉 Frontend done!"
echo ""
echo "📋 Next:"
echo "   cd ~/Rostam-Full-site/client"
echo "   pkill -f vite"
echo "   npm run dev"
echo ""
