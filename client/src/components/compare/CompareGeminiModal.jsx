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
