import { MapPin, Check } from 'lucide-react'

export default function AddressCard({ address, selected, onSelect }) {
  return (
    <button
      type="button"
      onClick={() => onSelect(address)}
      className={`w-full text-left p-4 rounded-xl border-2 transition ${
        selected
          ? 'border-primary bg-primary/5'
          : 'border-gray-200 dark:border-gray-700 hover:border-primary/50'
      }`}
    >
      <div className="flex items-start gap-3">
        <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
          selected ? 'bg-primary text-secondary' : 'bg-gray-100 dark:bg-gray-800 text-gray-400'
        }`}>
          <MapPin className="h-5 w-5" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-sm text-secondary dark:text-white">
              {address.full_name}
            </span>
            {selected && <Check className="h-4 w-4 text-primary" />}
          </div>
          <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
            {address.address_line1}
            {address.address_line2 && `, ${address.address_line2}`}
            <br />
            {address.city}, {address.state || ''} {address.zip}
            <br />
            {address.country} · {address.phone}
          </p>
        </div>
      </div>
    </button>
  )
}
