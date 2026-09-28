import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Sparkles } from 'lucide-react'
import UserLayout from '../components/user/UserLayout'
import UserStats from '../components/user/UserStats'
import RecentOrders from '../components/user/RecentOrders'
import Spinner from '../components/ui/Spinner'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'

export default function Account() {
  const { profile } = useAuth()
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({ orders: 0, wishlist: 0, reviews: 0, total_spent: 0 })
  const [recentOrders, setRecentOrders] = useState([])

  useEffect(() => {
    Promise.all([
      api.get('/orders').catch(() => ({ data: { orders: [] } })),
      api.get('/wishlist').catch(() => ({ data: { items: [] } })),
      api.get('/comments/my').catch(() => ({ data: { comments: [] } })),
    ])
      .then(([ordersRes, wishlistRes, reviewsRes]) => {
        const orders = ordersRes.data.orders || []
        const totalSpent = orders
          .filter((o) => o.payment_status === 'paid')
          .reduce((sum, o) => sum + Number(o.total || 0), 0)

        setStats({
          orders: orders.length,
          wishlist: (wishlistRes.data.items || []).length,
          reviews: (reviewsRes.data.comments || []).length,
          total_spent: totalSpent,
        })
        setRecentOrders(orders)
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <UserLayout
      title={`Welcome back, ${profile?.full_name?.split(' ')[0] || 'there'} 👋`}
      description="Here's a quick overview of your account"
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : (
        <div className="space-y-6">
          <UserStats stats={stats} />

          <RecentOrders orders={recentOrders} />

          <div className="bg-gradient-to-r from-primary/10 to-primary-dark/10 border-2 border-primary/30 rounded-xl p-5">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                <Sparkles className="h-5 w-5 text-secondary" />
              </div>
              <div className="flex-1">
                <h3 className="font-bold text-sm text-secondary dark:text-white mb-1">
                  Need help choosing?
                </h3>
                <p className="text-xs text-gray-600 dark:text-gray-400 mb-3">
                  Try our AI-powered smart search and product comparison.
                </p>
                <div className="flex gap-2 flex-wrap">
                  <Link
                    to="/products"
                    className="text-xs bg-primary hover:bg-primary-dark text-secondary font-semibold px-4 py-2 rounded-lg inline-flex items-center gap-1 transition"
                  >
                    Browse Products <ArrowRight className="h-3 w-3" />
                  </Link>
                  <Link
                    to="/compare"
                    className="text-xs bg-white dark:bg-secondary border border-gray-300 dark:border-gray-700 hover:border-primary text-secondary dark:text-white font-semibold px-4 py-2 rounded-lg inline-flex items-center gap-1 transition"
                  >
                    Compare Products
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </UserLayout>
  )
}
