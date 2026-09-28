import { ChevronLeft, ChevronRight } from 'lucide-react'

export default function ProductPagination({ page, pages, onPageChange }) {
  if (pages <= 1) return null

  const getPages = () => {
    const arr = []
    const maxShow = 5
    let start = Math.max(1, page - Math.floor(maxShow / 2))
    let end = Math.min(pages, start + maxShow - 1)
    if (end - start + 1 < maxShow) start = Math.max(1, end - maxShow + 1)
    for (let i = start; i <= end; i++) arr.push(i)
    return arr
  }

  return (
    <div className="flex items-center justify-center gap-2 mt-8">
      <button
        onClick={() => onPageChange(page - 1)}
        disabled={page === 1}
        className="w-9 h-9 rounded-lg border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
      >
        <ChevronLeft className="h-4 w-4" />
      </button>

      {getPages().map((p) => (
        <button
          key={p}
          onClick={() => onPageChange(p)}
          className={`w-9 h-9 rounded-lg border text-sm font-medium transition ${
            p === page
              ? 'bg-primary text-secondary border-primary'
              : 'border-gray-300 dark:border-gray-700 hover:border-primary hover:text-primary'
          }`}
        >
          {p}
        </button>
      ))}

      <button
        onClick={() => onPageChange(page + 1)}
        disabled={page === pages}
        className="w-9 h-9 rounded-lg border border-gray-300 dark:border-gray-700 flex items-center justify-center hover:border-primary hover:text-primary disabled:opacity-40 disabled:cursor-not-allowed transition"
      >
        <ChevronRight className="h-4 w-4" />
      </button>
    </div>
  )
}
