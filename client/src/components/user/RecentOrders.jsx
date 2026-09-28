import { Link } from 'react-router-dom'
import { ArrowRight, Package } from 'lucide-react'
import OrderStatus from '../order/OrderStatus'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function RecentOrders({ orders = [] }) {
  if (orders.length === 0) {
    return (
      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 text-center">
        <Package className="h-12 w-12 text-gray-300 mx-auto mb-3" />
        <p className="text-sm text-gray-500">No orders yet</p>
        <Link to="/products" className="text-sm text-link hover:text-primary mt-2 inline-block">
          Start shopping →
        </Link>
      </div>
    )
  }

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
      <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <h3 className="font-bold text-secondary dark:text-white">Recent Orders</h3>
        <Link
          to="/orders"
          className="text-xs text-link hover:text-primary flex items-center gap-1"
        >
          View All <ArrowRight className="h-3 w-3" />
        </Link>
      </div>

      <div className="divide-y divide-gray-100 dark:divide-gray-700/50">
        {orders.slice(0, 3).map((order) => (
          <Link
            key={order.id}
            to={`/orders/${order.id}`}
            className="block px-5 py-3 hover:bg-gray-50 dark:hover:bg-secondary transition"
          >
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div className="min-w-0">
                <div className="font-mono text-xs text-gray-500 mb-1">
                  {order.order_number}
                </div>
                <div className="text-xs text-gray-600 dark:text-gray-400">
                  {formatDate(order.created_at)}
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="font-bold text-sm text-primary">
                  {formatCurrency(order.total)}
                </span>
                <OrderStatus status={order.status} />
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  )
}
