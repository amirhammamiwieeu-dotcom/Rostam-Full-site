import { getStatusInfo, getStatusClasses } from '../../lib/orderHelpers'

export default function OrderStatus({ status }) {
  const info = getStatusInfo(status)
  return (
    <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${getStatusClasses(info.color)}`}>
      {info.label}
    </span>
  )
}
