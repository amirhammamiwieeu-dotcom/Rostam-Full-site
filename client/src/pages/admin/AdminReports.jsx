import { useEffect, useState } from 'react'
import { DollarSign, ShoppingCart, TrendingUp } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatsCard from '../../components/admin/StatsCard'
import Spinner from '../../components/ui/Spinner'
import { api } from '../../lib/api'
import { formatCurrency } from '../../lib/utils'

export default function AdminReports() {
  const [report, setReport] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/admin/reports/sales')
      .then((res) => setReport(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const avgOrder = report?.totalOrders > 0 ? report.totalRevenue / report.totalOrders : 0

  return (
    <AdminLayout title="Reports">
      {loading ? (
        <div className="flex justify-center py-12"><Spinner size="lg" /></div>
      ) : (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <StatsCard icon={DollarSign} label="Total Revenue" value={formatCurrency(report?.totalRevenue || 0)} color="green" />
            <StatsCard icon={ShoppingCart} label="Total Orders" value={report?.totalOrders || 0} color="blue" />
            <StatsCard icon={TrendingUp} label="Avg. Order Value" value={formatCurrency(avgOrder)} color="purple" />
          </div>

          <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
            <h3 className="font-bold mb-4 text-secondary dark:text-white">Sales by Day</h3>
            {!report?.byDay || Object.keys(report.byDay).length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-6">No sales data yet</p>
            ) : (
              <div className="space-y-3">
                {Object.entries(report.byDay).slice(-7).reverse().map(([day, data]) => (
                  <div key={day} className="flex items-center gap-3">
                    <div className="text-xs text-gray-500 w-24">{day}</div>
                    <div className="flex-1 bg-gray-100 dark:bg-secondary rounded-full h-6 overflow-hidden">
                      <div
                        className="h-full bg-primary rounded-full flex items-center justify-end pr-2 text-[10px] font-bold text-secondary"
                        style={{ width: `${Math.min(100, (data.revenue / report.totalRevenue) * 100 * 3)}%` }}
                      >
                        {data.count}
                      </div>
                    </div>
                    <div className="text-xs font-bold text-secondary dark:text-white w-24 text-right">
                      {formatCurrency(data.revenue)}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
