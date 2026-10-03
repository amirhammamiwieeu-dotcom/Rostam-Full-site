import { useEffect } from 'react'
import { X } from 'lucide-react'

export default function Drawer({ open, onClose, title, children, side = 'right' }) {
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    return () => { document.body.style.overflow = 'unset' }
  }, [open])

  // وقتی بسته‌ست، هیچی رندر نکن
  if (!open) return null

  return (
    <>
      <div
        className="fixed inset-0 bg-black/60 z-40 animate-fade-in"
        onClick={onClose}
      />
      <div
        className={`fixed top-0 h-full w-full max-w-md bg-white dark:bg-secondary-light shadow-2xl z-50 ${
          side === 'right' ? 'right-0' : 'left-0'
        }`}
      >
        <div className="flex items-center justify-between p-5 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-lg font-bold text-secondary dark:text-white">{title}</h2>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition"
            aria-label="Close"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="p-5 overflow-y-auto h-[calc(100%-80px)]">{children}</div>
      </div>
    </>
  )
}
