import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'
import { formatDate } from '../../lib/utils'

export default function AdminCoupons() {
  const [coupons, setCoupons] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/coupons')
      .then((res) => setCoupons(res.data.coupons || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    { header: 'Code', cell: (c) => <span className="font-mono font-bold text-secondary dark:text-white">{c.code}</span> },
    { header: 'Type', cell: (c) => <span className="capitalize">{c.discount_type}</span> },
    { header: 'Value', cell: (c) => c.discount_type === 'percent' ? `${c.discount_value}%` : `$${c.discount_value}` },
    { header: 'Min Order', cell: (c) => `$${c.min_order || 0}` },
    { header: 'Used', cell: (c) => `${c.used_count || 0} / ${c.max_uses || '∞'}` },
    { header: 'Expires', cell: (c) => c.expires_at ? formatDate(c.expires_at) : 'Never' },
    { header: 'Status', cell: (c) => c.is_active ? '✅ Active' : '❌ Inactive' },
  ]

  return (
    <AdminLayout title="Coupons">
      <AdminTable columns={columns} data={coupons} loading={loading} emptyMessage="No coupons" />
    </AdminLayout>
  )
}
