import ProductCard from '../product/ProductCard'
import WishlistSkeleton from './WishlistSkeleton'

export default function WishlistGrid({ items, loading }) {
  if (loading) return <WishlistSkeleton />

  if (!items || items.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500">Your wishlist is empty</p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      {items.map((item) => (
        <ProductCard key={item.id} product={item.product} />
      ))}
    </div>
  )
}
