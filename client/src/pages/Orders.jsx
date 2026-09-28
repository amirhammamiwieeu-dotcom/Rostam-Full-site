import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Package } from 'lucide-react'
import OrderCard from '../components/order/OrderCard'
import Spinner from '../components/ui/Spinner'
import Button from '../components/ui/Button'
import { api } from '../lib/api'

export default function Orders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/orders')
      .then((res) => setOrders(res.data.orders || []))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  return (
    <div className="container-page py-8 max-w-4xl">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white flex items-center gap-3">
        <Package className="h-7 w-7 text-primary" />
        My Orders
      </h1>

      {orders.length === 0 ? (
        <div className="text-center py-16 bg-white dark:bg-secondary-light rounded-xl">
          <Package className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-lg font-bold mb-2 text-secondary dark:text-white">
            No orders yet
          </h2>
          <p className="text-sm text-gray-500 mb-6">
            Start shopping to see your orders here
          </p>
          <Link to="/products">
            <Button>Browse Products</Button>
          </Link>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map((order) => (
            <OrderCard key={order.id} order={order} />
          ))}
        </div>
      )}
    </div>
  )
}
