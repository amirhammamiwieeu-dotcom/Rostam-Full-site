import { useEffect, useState } from 'react'
import { useWishlist } from '../context/WishlistContext'
import WishlistGrid from '../components/wishlist/WishlistGrid'

export default function Wishlist() {
  const { items, reload } = useWishlist()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    reload().finally(() => setLoading(false))
  }, [])

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        My Wishlist ({items.length})
      </h1>

      <WishlistGrid items={items} loading={loading} />
    </div>
  )
}
