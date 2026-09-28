import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useCompare } from '../context/CompareContext'
import CompareTable from '../components/compare/CompareTable'
import CompareSkeleton from '../components/compare/CompareSkeleton'
import Button from '../components/ui/Button'

export default function Compare() {
  const { items, reload } = useCompare()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    reload().finally(() => setLoading(false))
  }, [])

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        Compare Products ({items.length}/4)
      </h1>

      {loading ? (
        <CompareSkeleton />
      ) : items.length === 0 ? (
        <div className="text-center py-16">
          <h2 className="text-xl font-bold mb-2 text-secondary dark:text-white">
            No products to compare
          </h2>
          <p className="text-gray-500 mb-6">
            Add up to 4 products to compare their features side by side.
          </p>
          <Link to="/products">
            <Button>Browse Products</Button>
          </Link>
        </div>
      ) : (
        <CompareTable items={items} />
      )}
    </div>
  )
}
