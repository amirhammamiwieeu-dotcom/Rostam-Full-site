import { useEffect, useState } from 'react'
import { Search } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import AdminTable from '../../components/admin/AdminTable'
import { api } from '../../lib/api'
import { formatDate } from '../../lib/utils'

export default function AdminUsers() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  useEffect(() => {
    api.get('/admin/users?limit=100')
      .then((res) => setUsers(res.data.users || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const filtered = search
    ? users.filter((u) =>
        (u.email || '').toLowerCase().includes(search.toLowerCase()) ||
        (u.full_name || '').toLowerCase().includes(search.toLowerCase())
      )
    : users

  const columns = [
    {
      header: 'User',
      cell: (u) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xs">
            {(u.full_name || u.email || 'U').charAt(0).toUpperCase()}
          </div>
          <div>
            <div className="font-medium text-secondary dark:text-white">{u.full_name || '—'}</div>
            <div className="text-xs text-gray-500">{u.email}</div>
          </div>
        </div>
      ),
    },
    {
      header: 'Role',
      cell: (u) => (
        <span className={`px-2 py-0.5 rounded text-xs font-semibold ${
          u.role === 'admin' ? 'bg-primary text-secondary' :
          u.role === 'seller' ? 'bg-blue-100 text-blue-700' :
          'bg-gray-100 text-gray-600'
        }`}>
          {u.role}
        </span>
      ),
    },
    { header: 'Joined', cell: (u) => <span className="text-xs text-gray-500">{formatDate(u.created_at)}</span> },
    { header: 'Status', cell: (u) => u.is_active ? '✅ Active' : '❌ Inactive' },
  ]

  return (
    <AdminLayout title="Users">
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search users..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>
      </div>
      <AdminTable columns={columns} data={filtered} loading={loading} emptyMessage="No users" />
    </AdminLayout>
  )
}
