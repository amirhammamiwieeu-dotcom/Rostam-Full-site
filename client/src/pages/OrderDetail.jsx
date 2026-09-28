import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeft, MapPin, CreditCard, Package } from 'lucide-react'
import toast from 'react-hot-toast'
import OrderStatus from '../components/order/OrderStatus'
import OrderTimeline from '../components/order/OrderTimeline'
import Spinner from '../components/ui/Spinner'
import { api } from '../lib/api'
import { formatCurrency, formatDate } from '../lib/utils'

export default function OrderDetail() {
  const { id } = useParams()
  const [order, setOrder] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get(`/orders/${id}`)
      .then((res) => setOrder(res.data.order))
      .catch((err) => {
        console.error(err)
        toast.error('Order not found')
      })
      .finally(() => setLoading(false))
  }, [id])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!order) {
    return (
      <div className="container-page py-16 text-center">
        <h1 className="text-2xl font-bold mb-4 text-secondary dark:text-white">
          Order not found
        </h1>
        <Link to="/orders" className="text-link hover:text-primary">
          ← Back to orders
        </Link>
      </div>
    )
  }

  const address = order.shipping_address || {}
  const items = order.items || []

  return (
    <div className="container-page py-8 max-w-4xl">
      <Link to="/orders" className="text-sm text-link hover:text-primary inline-flex items-center gap-1 mb-4">
        <ArrowLeft className="h-4 w-4" /> Back to orders
      </Link>

      <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 mb-6">
        <div className="flex items-center justify-between flex-wrap gap-3 mb-4 pb-4 border-b border-gray-200 dark:border-gray-700">
          <div>
            <h1 className="text-xl font-bold text-secondary dark:text-white mb-1">
              Order #{order.order_number}
            </h1>
            <p className="text-xs text-gray-500">
              Placed on {formatDate(order.created_at)}
            </p>
          </div>
          <OrderStatus status={order.status} />
        </div>

        <div className="grid md:grid-cols-3 gap-4 text-sm">
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Total</div>
            <div className="font-bold text-primary">{formatCurrency(order.total)}</div>
          </div>
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Payment</div>
            <div className="font-medium text-secondary dark:text-white capitalize">
              {order.payment_status}
            </div>
          </div>
          <div>
            <div className="text-xs text-gray-500 uppercase tracking-wider mb-1">Items</div>
            <div className="font-medium text-secondary dark:text-white">
              {items.length}
            </div>
          </div>
        </div>
      </div>

      <div className="grid lg:grid-cols-[1fr_300px] gap-6">
        <div className="space-y-6">
          {/* Items */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h2 className="font-bold text-secondary dark:text-white mb-4 flex items-center gap-2">
              <Package className="h-5 w-5 text-primary" />
              Items
            </h2>
            <div className="space-y-4">
              {items.map((item) => (
                <div key={item.id} className="flex gap-3 pb-4 border-b border-gray-100 dark:border-gray-700/50 last:border-0 last:pb-0">
                  <img
                    src={item.image}
                    alt={item.title}
                    className="w-16 h-16 object-contain rounded-lg bg-gray-50 dark:bg-secondary"
                  />
                  <div className="flex-1">
                    <h3 className="text-sm font-medium text-secondary dark:text-white line-clamp-2 mb-1">
                      {item.title}
                    </h3>
                    <div className="text-xs text-gray-500">
                      Qty: {item.quantity} × {formatCurrency(item.price)}
                    </div>
                  </div>
                  <div className="font-bold text-secondary dark:text-white">
                    {formatCurrency(item.price * item.quantity)}
                  </div>
                </div>
              ))}
            </div>

            <div className="pt-4 mt-4 border-t border-gray-200 dark:border-gray-700 space-y-2 text-sm">
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Subtotal</span>
                <span>{formatCurrency(order.subtotal)}</span>
              </div>
              {order.discount > 0 && (
                <div className="flex justify-between text-success">
                  <span>Discount</span>
                  <span>−{formatCurrency(order.discount)}</span>
                </div>
              )}
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Shipping</span>
                <span>{formatCurrency(order.shipping_cost || 0)}</span>
              </div>
              <div className="flex justify-between text-gray-600 dark:text-gray-400">
                <span>Tax</span>
                <span>{formatCurrency(order.tax || 0)}</span>
              </div>
              <div className="flex justify-between font-bold text-secondary dark:text-white pt-2 border-t border-gray-200 dark:border-gray-700">
                <span>Total</span>
                <span className="text-primary">{formatCurrency(order.total)}</span>
              </div>
            </div>
          </div>

          {/* Shipping Address */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h2 className="font-bold text-secondary dark:text-white mb-4 flex items-center gap-2">
              <MapPin className="h-5 w-5 text-primary" />
              Shipping Address
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
              <strong className="text-secondary dark:text-white">{address.full_name}</strong>
              <br />
              {address.address_line1}
              {address.address_line2 && `, ${address.address_line2}`}
              <br />
              {address.city}, {address.state || ''} {address.zip}
              <br />
              {address.country}
              <br />
              {address.phone}
            </p>
          </div>
        </div>

        {/* Timeline */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 h-fit">
          <h2 className="font-bold text-secondary dark:text-white mb-6">
            Order Timeline
          </h2>
          <OrderTimeline order={order} />
        </div>
      </div>
    </div>
  )
}
