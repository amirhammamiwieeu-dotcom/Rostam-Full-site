import { useEffect } from 'react'
import { X } from 'lucide-react'
import { cn } from '../../lib/utils'

export default function Drawer({ open, onClose, title, children, side = 'right' }) {
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    return () => { document.body.style.overflow = 'unset' }
  }, [open])

  return (
    <>
      {open && (
        <div
          className="fixed inset-0 bg-black/60 z-40 animate-fade-in"
          onClick={onClose}
        />
      )}
      <div
        className={cn(
          'fixed top-0 h-full w-full max-w-md bg-white dark:bg-secondary-light shadow-2xl z-50 transition-transform duration-300',
          side === 'right' && 'right-0',
          side === 'left' && 'left-0',
          open ? 'translate-x-0' : side === 'right' ? 'translate-x-full' : '-translate-x-full'
        )}
        style={{ visibility: open ? 'visible' : 'hidden' }}
        aria-hidden={!open}
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
