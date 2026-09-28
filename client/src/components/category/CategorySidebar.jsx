import { Link } from 'react-router-dom'
import { ChevronRight } from 'lucide-react'

export default function CategorySidebar({ category, children = [], siblings = [] }) {
  // Decide which list to show:
  // - If we're on a main category, show its children
  // - If we're on a subcategory, show its siblings
  const items = category.parent_id ? siblings : children
  const currentSlug = category.slug

  return (
    <aside className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden lg:sticky lg:top-32">
      {/* Header */}
      <div className="bg-secondary text-white px-4 py-3">
        <h3 className="font-bold text-sm">
          {category.parent_id ? 'In This Category' : 'Subcategories'}
        </h3>
      </div>

      {/* List */}
      <nav className="p-2">
        {/* "All" link */}
        {category.parent_id && (
          <Link
            to={`/category/${siblings[0]?.slug?.replace(/.*/, '') || ''}#`}
            className="hidden"
          >
            All
          </Link>
        )}

        {items.length === 0 ? (
          <p className="text-xs text-gray-500 p-3 text-center">
            No subcategories
          </p>
        ) : (
          items.map((item) => {
            const isActive = item.slug === currentSlug
            return (
              <Link
                key={item.id}
                to={`/products?category=${item.slug}`}
                className={`flex items-center justify-between px-3 py-2.5 rounded-lg text-sm transition ${
                  isActive
                    ? 'bg-primary text-secondary font-semibold'
                    : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-secondary hover:text-primary'
                }`}
              >
                <span className="truncate">{item.name}</span>
                <ChevronRight className="h-4 w-4 flex-shrink-0" />
              </Link>
            )
          })
        )}
      </nav>

      {/* Footer link */}
      {category.parent_id && siblings.length > 0 && (
        <div className="border-t border-gray-200 dark:border-gray-700 p-2">
          <Link
            to={`/products?category=${category.slug}`}
            className="flex items-center justify-center gap-1 px-3 py-2 text-xs text-link hover:text-primary transition"
          >
            View all {category.name}
            <ChevronRight className="h-3 w-3" />
          </Link>
        </div>
      )}
    </aside>
  )
}
