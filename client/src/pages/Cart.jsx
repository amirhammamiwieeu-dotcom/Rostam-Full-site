import { useState } from 'react'
import { useCart } from '../context/CartContext'
import CartItem from '../components/cart/CartItem'
import CartSummary from '../components/cart/CartSummary'
import CouponForm from '../components/cart/CouponForm'
import EmptyCart from '../components/cart/EmptyCart'
import CartSkeleton from '../components/cart/CartSkeleton'

export default function Cart() {
  const { items, subtotal, loading } = useCart()
  const [appliedCoupon, setAppliedCoupon] = useState(null)

  if (loading) {
    return (
      <div className="container-page py-8">
        <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">Shopping Cart</h1>
        <CartSkeleton />
      </div>
    )
  }

  if (items.length === 0) {
    return (
      <div className="container-page py-8">
        <EmptyCart />
      </div>
    )
  }

  return (
    <div className="container-page py-8">
      <h1 className="text-2xl font-bold mb-6 text-secondary dark:text-white">
        Shopping Cart ({items.length} {items.length === 1 ? 'item' : 'items'})
      </h1>

      <div className="grid lg:grid-cols-[1fr_360px] gap-6">
        <div className="space-y-4">
          <div className="bg-white dark:bg-secondary-light rounded-xl p-4 shadow-card">
            <h3 className="font-semibold mb-3 text-secondary dark:text-white">Have a coupon?</h3>
            <CouponForm
              subtotal={subtotal}
              applied={appliedCoupon}
              onApply={setAppliedCoupon}
              onRemove={() => setAppliedCoupon(null)}
            />
          </div>

          <div className="space-y-3">
            {items.map((item) => (
              <CartItem key={item.id} item={item} />
            ))}
          </div>
        </div>

        <div>
          <CartSummary subtotal={subtotal} coupon={appliedCoupon} />
        </div>
      </div>
    </div>
  )
}
