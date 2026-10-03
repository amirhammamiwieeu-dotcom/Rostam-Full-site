import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Truck, Shield, RotateCcw, Headphones, ArrowRight } from 'lucide-react'
import Hero from '../components/home/Hero'
import { api } from '../lib/api'
import { formatCurrency } from '../lib/utils'
import Skeleton from '../components/ui/Skeleton'

const services = [
  { icon: Truck, title: 'Free Shipping', desc: 'On orders over $50' },
  { icon: Shield, title: 'Secure Payment', desc: '100% protected' },
  { icon: RotateCcw, title: 'Easy Returns', desc: '30-day guarantee' },
  { icon: Headphones, title: '24/7 Support', desc: 'Always here for you' },
]

const categories = [
  { name: 'Mobiles', slug: 'mobile-phones', emoji: '📱' },
  { name: 'Laptops', slug: 'laptops', emoji: '💻' },
  { name: 'Audio', slug: 'headphones-audio', emoji: '🎧' },
  { name: 'Cameras', slug: 'cameras', emoji: '📷' },
  { name: 'Watches', slug: 'smartwatches', emoji: '⌚' },
  { name: 'Gaming', slug: 'gaming', emoji: '🎮' },
  { name: 'Fashion', slug: 'fashion', emoji: '👕' },
  { name: 'Home', slug: 'home-kitchen', emoji: '🏠' },
]

export default function Home() {
  const [featured, setFeatured] = useState([])
  const [newArrivals, setNewArrivals] = useState([])
  const [bestSellers, setBestSellers] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([
      api.get('/products/featured?limit=8').catch(() => ({ data: { products: [] } })),
      api.get('/products/new?limit=8').catch(() => ({ data: { products: [] } })),
      api.get('/products/best-sellers?limit=8').catch(() => ({ data: { products: [] } })),
    ])
      .then(([feat, newArr, best]) => {
        setFeatured(feat.data.products || [])
        setNewArrivals(newArr.data.products || [])
        setBestSellers(best.data.products || [])
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="overflow-x-hidden w-full">
      <Hero />

      <section className="container-page py-6 sm:py-8">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4">
          {services.map((s, i) => (
            <div key={i} className="bg-white dark:bg-secondary-light rounded-xl p-3 sm:p-5 flex flex-col sm:flex-row items-center sm:items-center gap-2 sm:gap-3 shadow-card hover:shadow-card-hover transition text-center sm:text-left">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary shrink-0">
                <s.icon className="h-5 w-5 sm:h-6 sm:w-6" />
              </div>
              <div className="min-w-0">
                <h4 className="font-bold text-xs sm:text-sm text-secondary dark:text-white truncate">{s.title}</h4>
                <p className="text-[10px] sm:text-xs text-gray-500 truncate">{s.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="container-page pb-6 sm:pb-8">
        <div className="bg-white dark:bg-secondary-light rounded-xl p-4 sm:p-6 shadow-card">
          <h3 className="text-lg sm:text-xl font-bold mb-4 sm:mb-6 text-center text-secondary dark:text-white">
            Shop by Category
          </h3>
          <div className="grid grid-cols-4 lg:grid-cols-8 gap-3 sm:gap-4">
            {categories.map((cat) => (
              <Link key={cat.slug} to={`/products?category=${cat.slug}`} className="flex flex-col items-center gap-2 group">
                <div className="w-14 h-14 sm:w-20 sm:h-20 rounded-full bg-gradient-to-br from-gray-50 to-gray-200 dark:from-secondary dark:to-secondary-dark flex items-center justify-center text-2xl sm:text-3xl group-hover:shadow-lg group-hover:shadow-primary/20 group-hover:scale-105 transition">
                  {cat.emoji}
                </div>
                <span className="text-[10px] sm:text-xs text-center font-medium text-secondary dark:text-white">
                  {cat.name}
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <ProductSection title="Featured Products" products={featured} loading={loading} viewAllLink="/products?sort=featured" />
      <ProductSection title="New Arrivals" products={newArrivals} loading={loading} viewAllLink="/products?sort=newest" />
      <ProductSection title="Best Sellers" products={bestSellers} loading={loading} viewAllLink="/products?sort=popular" />
    </div>
  )
}

function ProductSection({ title, products, loading, viewAllLink }) {
  return (
    <section className="container-page pb-6 sm:pb-8">
      <div className="bg-white dark:bg-secondary-light rounded-xl p-4 sm:p-6 shadow-card">
        <div className="flex items-center justify-between mb-4 sm:mb-5">
          <h3 className="text-lg sm:text-xl font-bold text-secondary dark:text-white">{title}</h3>
          <Link to={viewAllLink} className="text-xs sm:text-sm text-link hover:text-primary flex items-center gap-1 transition">
            View All <ArrowRight className="h-3 w-3 sm:h-4 sm:w-4" />
          </Link>
        </div>
        {loading ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
            {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-64 sm:h-72 rounded-xl" />)}
          </div>
        ) : products.length === 0 ? (
          <p className="text-center text-gray-500 py-8">No products yet</p>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
            {products.map((p) => <ProductCard key={p.id} product={p} />)}
          </div>
        )}
      </div>
    </section>
  )
}

function ProductCard({ product }) {
  const discount = product.old_price ? Math.round((1 - product.price / product.old_price) * 100) : 0
  return (
    <Link to={`/products/${product.slug}`} className="group bg-white dark:bg-secondary rounded-xl p-2 sm:p-3 hover:shadow-card-hover hover:-translate-y-1 transition border border-transparent hover:border-gray-200 dark:hover:border-gray-700">
      <div className="relative">
        <img src={product.thumbnail} alt={product.title} className="w-full h-32 sm:h-40 object-contain mb-2 sm:mb-3" />
        {discount > 0 && (
          <span className="absolute top-2 left-2 bg-primary text-secondary text-xs font-bold px-2 py-0.5 rounded-full">
            -{discount}%
          </span>
        )}
      </div>
      <h4 className="text-xs sm:text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-2 min-h-[36px] sm:min-h-[40px]">
        {product.title}
      </h4>
      <div className="flex items-baseline gap-2">
        <span className="text-base sm:text-lg font-bold text-secondary dark:text-white">
          {formatCurrency(product.price)}
        </span>
        {product.old_price && (
          <span className="text-[10px] sm:text-xs text-gray-400 line-through">
            {formatCurrency(product.old_price)}
          </span>
        )}
      </div>
    </Link>
  )
}
