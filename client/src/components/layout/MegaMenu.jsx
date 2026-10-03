import { X, ChevronRight } from 'lucide-react'
import { Link } from 'react-router-dom'

const categories = [
  { name: 'Mobiles', slug: 'mobile-phones' },
  { name: 'Laptops', slug: 'laptops' },
  { name: 'Headphones & Audio', slug: 'headphones-audio' },
  { name: 'Cameras', slug: 'cameras' },
  { name: 'Smartwatches', slug: 'smartwatches' },
  { name: 'Gaming', slug: 'gaming' },
  { name: "Men's Clothing", slug: 'mens-clothing' },
  { name: "Women's Clothing", slug: 'womens-clothing' },
  { name: 'Shoes', slug: 'shoes' },
  { name: 'Bags & Accessories', slug: 'bags-accessories' },
]

export default function MegaMenu({ open, onClose }) {
  return (
    <>
      {open && (
        <div
          className="fixed inset-0 bg-black/60 z-40"
          onClick={onClose}
        />
      )}
      <aside
        className={`fixed top-0 left-0 h-full w-full max-w-sm bg-white dark:bg-secondary-light shadow-2xl z-50 transition-transform duration-300 ${
          open ? 'translate-x-0' : '-translate-x-full'
        }`}
        style={{ visibility: open ? 'visible' : 'hidden' }}
        aria-hidden={!open}
      >
        <div className="bg-secondary text-white p-5 flex items-center justify-between">
          <h3 className="text-lg font-bold">Shop by Department</h3>
          <button
            onClick={onClose}
            className="p-1 hover:bg-secondary-light rounded-lg"
            aria-label="Close menu"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="p-4 overflow-y-auto h-[calc(100%-80px)]">
          <Link
            to="/products"
            onClick={onClose}
            className="flex items-center justify-between px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition"
          >
            <span className="font-medium">All Products</span>
            <ChevronRight className="h-4 w-4" />
          </Link>
          {categories.map((cat) => (
            <Link
              key={cat.slug}
              to={`/products?category=${cat.slug}`}
              onClick={onClose}
              className="flex items-center justify-between px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition"
            >
              <span className="font-medium">{cat.name}</span>
              <ChevronRight className="h-4 w-4 text-gray-400" />
            </Link>
          ))}
        </div>
      </aside>
    </>
  )
}
