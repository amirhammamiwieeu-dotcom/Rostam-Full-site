import { useEffect, useState } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { ChevronRight, Package } from 'lucide-react'
import toast from 'react-hot-toast'
import CategorySidebar from '../components/category/CategorySidebar'
import ProductGrid from '../components/product/ProductGrid'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'

export default function Category() {
  const { slug } = useParams()
  const navigate = useNavigate()

  const [categoryData, setCategoryData] = useState(null)
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [productsLoading, setProductsLoading] = useState(true)

  // Load category + children
  useEffect(() => {
    setLoading(true)
    api.get(`/categories/${slug}/with-children`)
      .then((res) => {
        setCategoryData(res.data)
      })
      .catch((err) => {
        console.error(err)
        toast.error('Category not found')
        navigate('/products')
      })
      .finally(() => setLoading(false))
  }, [slug, navigate])

  // Load products for this category (and its children)
  useEffect(() => {
    if (!categoryData) return

    setProductsLoading(true)

    // Build list of slugs to fetch: this category + all its children
    const slugs = [categoryData.category.slug]
    if (categoryData.children && categoryData.children.length > 0) {
      categoryData.children.forEach((c) => slugs.push(c.slug))
    }

    // Fetch products for this category
    // Backend accepts ?category=slug, but we want products from children too.
    // Strategy: fetch each child's products and merge, OR fetch the parent.
    // For simplicity, if parent has children, fetch all children products.
    if (categoryData.children && categoryData.children.length > 0) {
      Promise.all(
        categoryData.children.map((c) =>
          api.get(`/products?category=${c.slug}&limit=8`).catch(() => ({ data: { products: [] } }))
        )
      )
        .then((results) => {
          const allProducts = results.flatMap((r) => r.data.products || [])
          // Deduplicate by id
          const unique = []
          const seen = new Set()
          for (const p of allProducts) {
            if (!seen.has(p.id)) {
              seen.add(p.id)
              unique.push(p)
            }
          }
          setProducts(unique)
        })
        .finally(() => setProductsLoading(false))
    } else {
      api.get(`/products?category=${categoryData.category.slug}&limit=20`)
        .then((res) => setProducts(res.data.products || []))
        .catch(() => setProducts([]))
        .finally(() => setProductsLoading(false))
    }
  }, [categoryData])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!categoryData) return null

  const { category, children, parent } = categoryData

  return (
    <div className="container-page py-6">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-xs text-gray-500 mb-5 flex-wrap">
        <Link to="/" className="hover:text-primary">Home</Link>
        <ChevronRight className="h-3 w-3" />
        {parent && (
          <>
            <Link to={`/category/${parent.slug}`} className="hover:text-primary">
              {parent.name}
            </Link>
            <ChevronRight className="h-3 w-3" />
          </>
        )}
        <span className="text-secondary dark:text-white font-medium">
          {category.name}
        </span>
      </nav>

      {/* Hero */}
      <div className="bg-gradient-to-r from-primary/10 to-primary-dark/10 border-2 border-primary/30 rounded-xl p-6 mb-6">
        <div className="flex items-center gap-4">
          {category.icon && (
            <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center text-secondary flex-shrink-0">
              <i className={`fas ${category.icon} text-2xl`} />
            </div>
          )}
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-secondary dark:text-white mb-1">
              {category.name}
            </h1>
            {category.description && (
              <p className="text-sm text-gray-600 dark:text-gray-400">
                {category.description}
              </p>
            )}
            {children.length > 0 && (
              <p className="text-xs text-gray-500 mt-2">
                {children.length} subcategories
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Main grid */}
      <div className="grid lg:grid-cols-[240px_1fr] gap-6">
        {/* Sidebar */}
        <CategorySidebar
          category={category}
          children={children}
          siblings={categoryData.siblings || []}
        />

        {/* Products */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-bold text-lg text-secondary dark:text-white flex items-center gap-2">
              <Package className="h-5 w-5 text-primary" />
              {children.length > 0 ? 'Products in this category' : 'Products'}
            </h2>
            {children.length > 0 && (
              <Link
                to={`/products?category=${category.slug}`}
                className="text-sm text-link hover:text-primary"
              >
                View all →
              </Link>
            )}
          </div>

          <ProductGrid
            products={products}
            loading={productsLoading}
            columns={4}
          />

          {!productsLoading && products.length === 0 && (
            <div className="text-center py-16 bg-white dark:bg-secondary-light rounded-xl">
              <Package className="h-12 w-12 text-gray-300 mx-auto mb-3" />
              <h3 className="font-bold text-secondary dark:text-white mb-2">
                No products in this category yet
              </h3>
              <p className="text-sm text-gray-500 mb-4">
                Check back soon, or browse other categories
              </p>
              <Link
                to="/products"
                className="text-link hover:text-primary text-sm"
              >
                Browse all products →
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
