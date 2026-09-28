import { MapPin, Pencil, Trash2, Check } from 'lucide-react'

export default function AddressCard({ address, onEdit, onDelete, onSetDefault }) {
  return (
    <div
      className={`bg-white dark:bg-secondary-light rounded-xl p-4 border-2 transition ${
        address.is_default ? 'border-primary' : 'border-gray-200 dark:border-gray-700'
      }`}
    >
      <div className="flex items-start gap-3">
        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
          <MapPin className="h-5 w-5 text-primary" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-sm text-secondary dark:text-white">
              {address.title || address.full_name || 'Address'}
            </span>
            {address.is_default && (
              <span className="inline-flex items-center gap-1 bg-primary text-secondary text-[10px] font-bold px-2 py-0.5 rounded-full">
                <Check className="h-3 w-3" />
                Default
              </span>
            )}
          </div>
          <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
            {address.full_name && <>{address.full_name}<br /></>}
            {address.address_line1}
            {address.address_line2 && `, ${address.address_line2}`}
            <br />
            {address.city}, {address.state || ''} {address.zip}
            <br />
            {address.country}
            {address.phone && <><br />{address.phone}</>}
          </p>

          <div className="flex items-center gap-3 mt-3 text-xs">
            <button
              onClick={() => onEdit(address)}
              className="flex items-center gap-1 text-link hover:text-primary transition"
            >
              <Pencil className="h-3 w-3" />
              Edit
            </button>
            <button
              onClick={() => onDelete(address)}
              className="flex items-center gap-1 text-danger hover:underline transition"
            >
              <Trash2 className="h-3 w-3" />
              Delete
            </button>
            {!address.is_default && onSetDefault && (
              <button
                onClick={() => onSetDefault(address)}
                className="text-link hover:text-primary transition ml-auto"
              >
                Set as default
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
