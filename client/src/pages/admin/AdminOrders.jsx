import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Eye, Search } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import OrderStatus from '../../components/order/OrderStatus'
import { api } from '../../lib/api'
import { formatCurrency, formatDate, truncate } from '../../lib/utils'

export default function AdminOrders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  useEffect(() => {
    api.get('/admin/orders?limit=100')
      .then((res) => setOrders(res.data.orders || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const filtered = search
    ? orders.filter((o) =>
        o.order_number.toLowerCase().includes(search.toLowerCase()) ||
        (o.customer_email || '').toLowerCase().includes(search.toLowerCase())
      )
    : orders

  const columns = [
    { header: 'Order #', cell: (o) => <span className="font-mono text-xs text-secondary dark:text-white">{o.order_number}</span> },
    { header: 'Customer', cell: (o) => (
      <div className="text-xs">
        <div className="font-medium text-secondary dark:text-white">{o.customer_name || '—'}</div>
        <div className="text-gray-500">{truncate(o.customer_email, 25)}</div>
      </div>
    )},
    { header: 'Date', cell: (o) => <span className="text-xs text-gray-500">{formatDate(o.created_at)}</span> },
    { header: 'Total', cell: (o) => <span className="font-bold text-primary">{formatCurrency(o.total)}</span> },
    { header: 'Status', cell: (o) => <OrderStatus status={o.status} /> },
    { header: 'Actions', className: 'text-right', cell: (o) => (
      <Link to={`/admin/orders/${o.id}`} className="inline-flex p-1.5 text-link hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded transition" title="View">
        <Eye className="h-4 w-4" />
      </Link>
    )},
  ]

  return (
    <AdminLayout title="Orders">
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by order # or email..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>
      </div>

      <AdminTable columns={columns} data={filtered} loading={loading} emptyMessage="No orders yet" />
    </AdminLayout>
  )
}
