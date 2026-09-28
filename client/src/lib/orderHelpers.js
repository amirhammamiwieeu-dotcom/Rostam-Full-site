export const ORDER_STATUSES = {
  pending: { label: 'Pending', color: 'yellow' },
  confirmed: { label: 'Confirmed', color: 'blue' },
  processing: { label: 'Processing', color: 'blue' },
  shipped: { label: 'Shipped', color: 'purple' },
  delivered: { label: 'Delivered', color: 'green' },
  cancelled: { label: 'Cancelled', color: 'red' },
  returned: { label: 'Returned', color: 'gray' },
  refunded: { label: 'Refunded', color: 'gray' },
}

export const getStatusInfo = (status) => {
  return ORDER_STATUSES[status] || { label: status, color: 'gray' }
}

export const getStatusClasses = (color) => {
  const map = {
    yellow: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300',
    blue: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300',
    purple: 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300',
    green: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300',
    red: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300',
    gray: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300',
  }
  return map[color] || map.gray
}

export const generateOrderTimeline = (order) => {
  if (order.status === 'cancelled') {
    return [
      { key: 'pending', label: 'Order Placed', date: order.created_at, done: true },
      { key: 'cancelled', label: 'Order Cancelled', date: order.cancelled_at, done: true, isError: true },
    ]
  }

  return [
    { key: 'pending', label: 'Order Placed', date: order.created_at, done: true },
    { key: 'confirmed', label: 'Confirmed', date: order.paid_at, done: !!order.paid_at },
    { key: 'processing', label: 'Processing', date: null, done: ['processing', 'shipped', 'delivered'].includes(order.status) },
    { key: 'shipped', label: 'Shipped', date: order.shipped_at, done: !!order.shipped_at },
    { key: 'delivered', label: 'Delivered', date: order.delivered_at, done: !!order.delivered_at },
  ]
}
