import { Package, Heart, MessageSquare, DollarSign } from 'lucide-react'
import { formatCurrency } from '../../lib/utils'

export default function UserStats({ stats }) {
  const items = [
    {
      label: 'Total Orders',
      value: stats?.orders || 0,
      icon: Package,
      color: 'text-blue-600 bg-blue-100 dark:bg-blue-900/30',
    },
    {
      label: 'Wishlist Items',
      value: stats?.wishlist || 0,
      icon: Heart,
      color: 'text-red-600 bg-red-100 dark:bg-red-900/30',
    },
    {
      label: 'Reviews',
      value: stats?.reviews || 0,
      icon: MessageSquare,
      color: 'text-purple-600 bg-purple-100 dark:bg-purple-900/30',
    },
    {
      label: 'Total Spent',
      value: formatCurrency(stats?.total_spent || 0),
      icon: DollarSign,
      color: 'text-green-600 bg-green-100 dark:bg-green-900/30',
    },
  ]

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {items.map((item, i) => (
        <div
          key={i}
          className="bg-white dark:bg-secondary-light rounded-xl p-4 shadow-card"
        >
          <div className={`w-10 h-10 rounded-lg ${item.color} flex items-center justify-center mb-3`}>
            <item.icon className="h-5 w-5" />
          </div>
          <div className="text-xl font-bold text-secondary dark:text-white">
            {item.value}
          </div>
          <div className="text-xs text-gray-500 mt-1">{item.label}</div>
        </div>
      ))}
    </div>
  )
}
