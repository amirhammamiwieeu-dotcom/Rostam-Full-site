import { AlertTriangle } from 'lucide-react'
import Button from '../ui/Button'

export default function ConfirmDialog({ open, onClose, onConfirm, title, message, loading, variant = 'danger' }) {
  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60"
      onClick={onClose}
    >
      <div
        className="bg-white dark:bg-secondary-light rounded-2xl shadow-2xl max-w-md w-full p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <div className={`w-12 h-12 mx-auto mb-4 rounded-full flex items-center justify-center ${
          variant === 'danger' ? 'bg-red-100 dark:bg-red-900/30' : 'bg-yellow-100 dark:bg-yellow-900/30'
        }`}>
          <AlertTriangle className={`h-6 w-6 ${variant === 'danger' ? 'text-danger' : 'text-yellow-600'}`} />
        </div>
        <h3 className="text-lg font-bold text-center mb-2 text-secondary dark:text-white">
          {title || 'Are you sure?'}
        </h3>
        <p className="text-sm text-gray-500 text-center mb-6">
          {message || 'This action cannot be undone.'}
        </p>
        <div className="flex gap-3 justify-center">
          <Button variant="secondary" onClick={onClose} disabled={loading}>
            Cancel
          </Button>
          <Button variant={variant} onClick={onConfirm} disabled={loading}>
            {loading ? 'Processing...' : 'Confirm'}
          </Button>
        </div>
      </div>
    </div>
  )
}
