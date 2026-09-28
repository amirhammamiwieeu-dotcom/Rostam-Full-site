import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import {
  Users,
  Package,
  ShoppingCart,
  DollarSign,
  TrendingUp,
  ArrowRight,
} from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatsCard from '../../components/admin/StatsCard'
import Spinner from '../../components/ui/Spinner'
import OrderStatus from '../../components/order/OrderStatus'
import { api } from '../../lib/api'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function AdminDashboard() {
  const [stats, setStats] = useState(null)
  const [recentOrders, setRecentOrders] = useState([])
  const [lowStock, setLowStock] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([
      api.get('/admin/dashboard').catch(() => ({ data: {} })),
      api.get('/admin/orders?limit=5').catch(() => ({ data: { orders: [] } })),
      api.get('/admin/reports/low-stock').catch(() => ({ data: { products: [] } })),
    ])
      .then(([statsRes, ordersRes, lowStockRes]) => {
        setStats(statsRes.data)
        setRecentOrders(ordersRes.data.orders || [])
        setLowStock(lowStockRes.data.products || [])
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <AdminLayout title="Dashboard">
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : (
        <div className="space-y-6">
          {/* Stats */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <StatsCard icon={Users} label="Total Users" value={stats?.totalUsers || 0} color="blue" />
            <StatsCard icon={Package} label="Products" value={stats?.totalProducts || 0} color="purple" />
            <StatsCard icon={ShoppingCart} label="Orders" value={stats?.totalOrders || 0} color="yellow" />
            <StatsCard
              icon={DollarSign}
              label="Total Revenue"
              value={formatCurrency(stats?.totalRevenue || 0)}
              color="green"
              trend={12}
            />
          </div>

          <div className="grid lg:grid-cols-2 gap-6">
            {/* Recent Orders */}
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                <h3 className="font-bold text-secondary dark:text-white">Recent Orders</h3>
                <Link to="/admin/orders" className="text-xs text-link hover:text-primary flex items-center gap-1">
                  View All <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
              {recentOrders.length === 0 ? (
                <div className="p-6 text-center text-sm text-gray-500">No orders yet</div>
              ) : (
                <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
                  {recentOrders.map((order) => (
                    <Link
                      key={order.id}
                      to={`/admin/orders/${order.id}`}
                      className="block px-5 py-3 hover:bg-gray-50 dark:hover:bg-secondary transition"
                    >
                      <div className="flex items-center justify-between gap-2 flex-wrap">
                        <div className="min-w-0">
                          <div className="font-mono text-xs text-gray-500 mb-0.5">
                            {order.order_number}
                          </div>
                          <div className="text-xs text-gray-600 dark:text-gray-400">
                            {order.customer_name || order.customer_email}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-sm text-primary">
                            {formatCurrency(order.total)}
                          </span>
                          <OrderStatus status={order.status} />
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </div>

            {/* Low Stock */}
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                <h3 className="font-bold text-secondary dark:text-white flex items-center gap-2">
                  Low Stock Alert
                  {lowStock.length > 0 && (
                    <span className="bg-danger text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                      {lowStock.length}
                    </span>
                  )}
                </h3>
                <Link to="/admin/products" className="text-xs text-link hover:text-primary flex items-center gap-1">
                  Manage <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
              {lowStock.length === 0 ? (
                <div className="p-6 text-center text-sm text-gray-500">
                  All products are well-stocked ✅
                </div>
              ) : (
                <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
                  {lowStock.slice(0, 5).map((p) => (
                    <div key={p.id} className="px-5 py-3 flex items-center gap-3">
                      <img src={p.thumbnail} alt="" className="w-10 h-10 object-contain rounded bg-gray-50 dark:bg-secondary" />
                      <div className="flex-1 min-w-0">
                        <div className="text-xs font-medium text-secondary dark:text-white line-clamp-1">
                          {p.title}
                        </div>
                      </div>
                      <span className={`text-sm font-bold ${p.stock === 0 ? 'text-danger' : 'text-yellow-600'}`}>
                        {p.stock} left
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
