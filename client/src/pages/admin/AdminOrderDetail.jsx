import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ArrowLeft, Save, MapPin, User } from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../components/admin/AdminLayout'
import OrderStatus from '../../components/order/OrderStatus'
import Button from '../../components/ui/Button'
import Spinner from '../../components/ui/Spinner'
import { api } from '../../lib/api'
import { formatCurrency, formatDate } from '../../lib/utils'

const STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded']

export default function AdminOrderDetail() {
  const { id } = useParams()
  const [order, setOrder] = useState(null)
  const [loading, setLoading] = useState(true)
  const [status, setStatus] = useState('')
  const [tracking, setTracking] = useState('')
  const [note, setNote] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    api.get(`/orders/${id}`)
      .then((res) => {
        setOrder(res.data.order)
        setStatus(res.data.order.status)
        setTracking(res.data.order.tracking_number || '')
        setNote(res.data.order.admin_note || '')
      })
      .catch(() => {
        toast.error('Order not found')
      })
      .finally(() => setLoading(false))
  }, [id])

  const handleSave = async () => {
    setSaving(true)
    try {
      await api.put(`/orders/${id}/status`, {
        status,
        tracking_number: tracking || undefined,
        note: note || undefined,
      })
      toast.success('Order updated')
      const res = await api.get(`/orders/${id}`)
      setOrder(res.data.order)
    } catch (err) {
      toast.error(err.message || 'Failed')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <AdminLayout title="Loading...">
        <div className="flex justify-center py-16"><Spinner size="lg" /></div>
      </AdminLayout>
    )
  }

  if (!order) {
    return (
      <AdminLayout title="Order not found">
        <Link to="/admin/orders" className="text-link hover:text-primary">
          ← Back to orders
        </Link>
      </AdminLayout>
    )
  }

  const address = order.shipping_address || {}

  return (
    <AdminLayout
      title={`Order #${order.order_number}`}
      actions={
        <Link to="/admin/orders" className="flex items-center gap-1 text-sm text-link hover:text-primary">
          <ArrowLeft className="h-4 w-4" /> Back
        </Link>
      }
    >
      <div className="grid lg:grid-cols-[1fr_320px] gap-6">
        {/* Main */}
        <div className="space-y-6">
          {/* Items */}
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Items</h3>
            <div className="space-y-3">
              {(order.items || []).map((item) => (
                <div key={item.id} className="flex gap-3 pb-3 border-b border-gray-100 dark:border-gray-700/50 last:border-0 last:pb-0">
                  <img src={item.image} alt="" className="w-14 h-14 object-contain rounded bg-gray-50 dark:bg-secondary" />
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium text-secondary dark:text-white line-clamp-2">{item.title}</div>
                    <div className="text-xs text-gray-500 mt-1">Qty: {item.quantity} × {formatCurrency(item.price)}</div>
                  </div>
                  <div className="font-bold text-secondary dark:text-white">{formatCurrency(item.price * item.quantity)}</div>
                </div>
              ))}
            </div>

            <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700 space-y-1.5 text-sm">
              <div className="flex justify-between text-gray-500"><span>Subtotal</span><span>{formatCurrency(order.subtotal)}</span></div>
              {order.discount > 0 && <div className="flex justify-between text-success"><span>Discount</span><span>−{formatCurrency(order.discount)}</span></div>}
              <div className="flex justify-between text-gray-500"><span>Shipping</span><span>{formatCurrency(order.shipping_cost || 0)}</span></div>
              <div className="flex justify-between text-gray-500"><span>Tax</span><span>{formatCurrency(order.tax || 0)}</span></div>
              <div className="flex justify-between font-bold text-secondary dark:text-white pt-2 border-t border-gray-200 dark:border-gray-700"><span>Total</span><span className="text-primary">{formatCurrency(order.total)}</span></div>
            </div>
          </div>

          {/* Customer & Address */}
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
              <h3 className="font-bold mb-3 text-secondary dark:text-white flex items-center gap-2">
                <User className="h-4 w-4 text-primary" /> Customer
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                <strong className="text-secondary dark:text-white">{address.full_name}</strong><br />
                {order.customer_email}<br />
                {address.phone}
              </p>
            </div>

            <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
              <h3 className="font-bold mb-3 text-secondary dark:text-white flex items-center gap-2">
                <MapPin className="h-4 w-4 text-primary" /> Shipping Address
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                {address.address_line1}<br />
                {address.address_line2 && <>{address.address_line2}<br /></>}
                {address.city}, {address.state} {address.zip}<br />
                {address.country}
              </p>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Manage Order</h3>

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Status</label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4"
            >
              {STATUSES.map((s) => (
                <option key={s} value={s} className="capitalize">{s}</option>
              ))}
            </select>

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Tracking Number</label>
            <input
              type="text"
              value={tracking}
              onChange={(e) => setTracking(e.target.value)}
              placeholder="TRK123456789"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4"
            />

            <label className="block text-xs font-medium mb-1.5 text-gray-500">Admin Note</label>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              rows={3}
              placeholder="Internal note..."
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary text-sm text-secondary dark:text-white outline-none focus:border-primary mb-4 resize-y"
            />

            <Button onClick={handleSave} disabled={saving} className="w-full">
              <Save className="h-4 w-4" />
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>

          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-5 text-sm">
            <div className="flex justify-between mb-2"><span className="text-gray-500">Payment</span><span className="font-medium text-secondary dark:text-white capitalize">{order.payment_status}</span></div>
            <div className="flex justify-between mb-2"><span className="text-gray-500">Placed</span><span className="text-secondary dark:text-white">{formatDate(order.created_at)}</span></div>
            {order.paid_at && <div className="flex justify-between mb-2"><span className="text-gray-500">Paid</span><span className="text-secondary dark:text-white">{formatDate(order.paid_at)}</span></div>}
            {order.shipped_at && <div className="flex justify-between mb-2"><span className="text-gray-500">Shipped</span><span className="text-secondary dark:text-white">{formatDate(order.shipped_at)}</span></div>}
            {order.delivered_at && <div className="flex justify-between"><span className="text-gray-500">Delivered</span><span className="text-secondary dark:text-white">{formatDate(order.delivered_at)}</span></div>}
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
