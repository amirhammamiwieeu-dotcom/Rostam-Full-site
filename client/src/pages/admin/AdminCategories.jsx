import { useEffect, useState } from 'react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'

export default function AdminCategories() {
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/categories')
      .then((res) => setCategories(res.data.categories || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const columns = [
    { header: 'Name', cell: (c) => <span className="font-medium text-secondary dark:text-white">{c.name}</span> },
    { header: 'Slug', cell: (c) => <span className="font-mono text-xs text-gray-500">{c.slug}</span> },
    { header: 'Type', cell: (c) => <span className={`px-2 py-0.5 rounded text-xs font-medium ${!c.parent_id ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-600'}`}>{!c.parent_id ? 'Main' : 'Sub'}</span> },
    { header: 'Products', cell: (c) => c.product_count || 0 },
    { header: 'Status', cell: (c) => c.is_active ? '✅' : '❌' },
  ]

  return (
    <AdminLayout title="Categories">
      <AdminTable columns={columns} data={categories} loading={loading} emptyMessage="No categories" />
    </AdminLayout>
  )
}
