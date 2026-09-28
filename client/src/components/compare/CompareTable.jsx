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
