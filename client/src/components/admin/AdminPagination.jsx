import { ChevronLeft, ChevronRight } from 'lucide-react'

export default function AdminPagination({ page, pages, total, onPageChange }) {
  if (pages <= 1) return null

  return (
    <div className="flex items-center justify-between mt-4 flex-wrap gap-3">
      <div className="text-xs text-gray-500">
        Page {page} of {pages} · {total} items
      </div>
      <div className="flex items-center gap-2">
        <button
          onClick={() => onPageChange(page - 1)}
          disabled={page === 1}
          className="px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        <span className="text-sm font-medium text-secondary dark:text-white px-2">
          {page} / {pages}
        </span>
        <button
          onClick={() => onPageChange(page + 1)}
          disabled={page === pages}
          className="px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-lg text-sm hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}
