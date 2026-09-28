import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import RatingStars from '../../components/product/RatingStars'
import { api } from '../../lib/api'
import { formatRelativeTime, truncate } from '../../lib/utils'

export default function AdminComments() {
  const [comments, setComments] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/admin/comments?limit=100')
      .then((res) => setComments(res.data.comments || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    {
      header: 'Product',
      cell: (c) => (
        <div className="flex items-center gap-2">
          <img src={c.product?.thumbnail} alt="" className="w-8 h-8 object-contain rounded" />
          <span className="text-xs text-secondary dark:text-white">{truncate(c.product?.title, 30)}</span>
        </div>
      ),
    },
    { header: 'User', cell: (c) => <span className="text-xs">{c.user?.full_name || c.user?.email}</span> },
    { header: 'Rating', cell: (c) => <RatingStars rating={c.rating} /> },
    { header: 'Review', cell: (c) => <span className="text-xs text-gray-500">{truncate(c.text, 60)}</span> },
    { header: 'Date', cell: (c) => <span className="text-xs text-gray-500">{formatRelativeTime(c.created_at)}</span> },
    {
      header: 'Status',
      cell: (c) => (
        <span className={`px-2 py-0.5 rounded text-xs font-semibold ${c.is_approved ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
          {c.is_approved ? 'Approved' : 'Pending'}
        </span>
      ),
    },
  ]

  return (
    <AdminLayout title="Reviews">
      <AdminTable columns={columns} data={comments} loading={loading} emptyMessage="No reviews" />
    </AdminLayout>
  )
}
