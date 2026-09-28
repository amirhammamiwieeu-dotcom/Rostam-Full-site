import { useState, useEffect, useMemo } from 'react'
import { useSearchParams } from 'react-router-dom'
import { SlidersHorizontal } from 'lucide-react'
import toast from 'react-hot-toast'
import ProductGrid from '../components/product/ProductGrid'
import ProductFilters from '../components/product/ProductFilters'
import ProductSort from '../components/product/ProductSort'
import ProductPagination from '../components/product/ProductPagination'
import { api } from '../lib/api'
import { buildQueryString, parseFiltersFromURL } from '../lib/productHelpers'

export default function Products() {
  const [searchParams, setSearchParams] = useSearchParams()

  const filters = useMemo(() => parseFiltersFromURL(searchParams), [searchParams])

  const [products, setProducts] = useState([])
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 })
  const [loading, setLoading] = useState(true)
  const [showMobileFilters, setShowMobileFilters] = useState(false)

  useEffect(() => {
    const query = buildQueryString(filters)
    console.log('🔍 Fetching products with filters:', filters)

    let cancelled = false
    setLoading(true)

    api.get(`/products?${query}`)
      .then((res) => {
        if (cancelled) return
        setProducts(res.data.products || [])
        setPagination(res.data.pagination || { page: 1, pages: 1, total: 0 })
      })
      .catch((err) => {
        if (cancelled) return
        console.error('❌ Fetch failed:', err)
        toast.error('Failed to load products')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [filters])

  const handleFilterChange = (newFilters) => {
    const query = buildQueryString(newFilters)
    setSearchParams(query, { replace: false })
  }

  const handlePageChange = (page) => {
    const newFilters = { ...filters, page }
    setSearchParams(buildQueryString(newFilters), { replace: false })
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  const handleSortChange = (sort) => {
    const newFilters = { ...filters, sort, page: 1 }
    setSearchParams(buildQueryString(newFilters), { replace: false })
  }

  const pageTitle = filters.category
    ? `Category: ${filters.category.replace(/-/g, ' ')}`
    : filters.q
      ? `Results for "${filters.q}"`
      : 'All Products'

  return (
    <div className="container-page py-6">
      <div className="mb-5">
        <h1 className="text-2xl font-bold text-secondary dark:text-white mb-1 capitalize">
          {pageTitle}
        </h1>
        <p className="text-sm text-gray-500">
          {loading
            ? 'Loading...'
            : `${pagination.total.toLocaleString()} products found`}
        </p>
      </div>

      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <aside className="hidden lg:block">
          <div className="sticky top-32">
            <ProductFilters filters={filters} onChange={handleFilterChange} />
          </div>
        </aside>

        {showMobileFilters && (
          <div className="fixed inset-0 z-50 lg:hidden">
            <div
              className="absolute inset-0 bg-black/60"
              onClick={() => setShowMobileFilters(false)}
            />
            <div className="absolute right-0 top-0 h-full w-full max-w-sm bg-white dark:bg-secondary-light overflow-y-auto p-4">
              <ProductFilters
                filters={filters}
                onChange={(f) => {
                  handleFilterChange(f)
                  setShowMobileFilters(false)
                }}
                onClose={() => setShowMobileFilters(false)}
              />
            </div>
          </div>
        )}

        <div>
          <div className="flex items-center justify-between mb-4 bg-white dark:bg-secondary-light rounded-xl p-3 shadow-card flex-wrap gap-2">
            <button
              onClick={() => setShowMobileFilters(true)}
              className="lg:hidden flex items-center gap-2 px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary transition"
            >
              <SlidersHorizontal className="h-4 w-4" />
              Filters
            </button>
            <div className="hidden lg:block text-sm text-gray-500">
              Showing {products.length} of {pagination.total} products
            </div>
            <ProductSort value={filters.sort} onChange={handleSortChange} />
          </div>

          <ProductGrid products={products} loading={loading} columns={4} />

          {!loading && products.length > 0 && pagination.pages > 1 && (
            <ProductPagination
              page={pagination.page}
              pages={pagination.pages}
              onPageChange={handlePageChange}
            />
          )}

          {!loading && products.length === 0 && (
            <div className="text-center py-16">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gray-100 dark:bg-secondary flex items-center justify-center">
                <SlidersHorizontal className="h-8 w-8 text-gray-400" />
              </div>
              <h3 className="font-bold text-secondary dark:text-white mb-2">
                No products found
              </h3>
              <p className="text-sm text-gray-500 mb-4">
                Try adjusting your filters
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
