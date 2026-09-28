import { Link } from 'react-router-dom'
import { Package, ArrowRight } from 'lucide-react'
import OrderStatus from './OrderStatus'
import { formatCurrency, formatDate } from '../../lib/utils'

export default function OrderCard({ order }) {
  const items = order.items || []
  const itemsPreview = items.slice(0, 3)

  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden">
      <div className="bg-gray-50 dark:bg-secondary px-4 py-3 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-4 text-xs">
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Order placed</div>
            <div className="font-semibold text-secondary dark:text-white">
              {formatDate(order.created_at)}
            </div>
          </div>
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Total</div>
            <div className="font-semibold text-secondary dark:text-white">
              {formatCurrency(order.total)}
            </div>
          </div>
          <div>
            <div className="text-gray-500 uppercase tracking-wider text-[10px]">Order #</div>
            <div className="font-mono text-secondary dark:text-white">
              {order.order_number}
            </div>
          </div>
        </div>
        <OrderStatus status={order.status} />
      </div>

      <div className="p-4">
        <div className="flex items-center gap-4 mb-3">
          <div className="flex -space-x-2">
            {itemsPreview.map((item) => (
              <img
                key={item.id}
                src={item.image}
                alt=""
                className="w-12 h-12 object-contain rounded-lg bg-white dark:bg-secondary border-2 border-white dark:border-secondary-light"
              />
            ))}
            {items.length > 3 && (
              <div className="w-12 h-12 rounded-lg bg-gray-100 dark:bg-secondary border-2 border-white dark:border-secondary-light flex items-center justify-center text-xs font-bold text-gray-500">
                +{items.length - 3}
              </div>
            )}
          </div>
          <div className="flex-1 text-sm text-gray-600 dark:text-gray-400">
            {items.length} {items.length === 1 ? 'item' : 'items'}
          </div>
          <Link
            to={`/orders/${order.id}`}
            className="text-sm text-link hover:text-primary flex items-center gap-1 transition"
          >
            View Details <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        {order.tracking_number && (
          <div className="text-xs text-gray-500 flex items-center gap-2">
            <Package className="h-3.5 w-3.5" />
            Tracking: <span className="font-mono">{order.tracking_number}</span>
          </div>
        )}
      </div>
    </div>
  )
}
