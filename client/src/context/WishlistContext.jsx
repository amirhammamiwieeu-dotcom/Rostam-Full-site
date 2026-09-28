import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const WishlistContext = createContext()

export const useWishlist = () => {
  const ctx = useContext(WishlistContext)
  if (!ctx) throw new Error('useWishlist must be used within WishlistProvider')
  return ctx
}

export function WishlistProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])

  useEffect(() => {
    if (user) loadWishlist()
    else setItems([])
  }, [user])

  const loadWishlist = async () => {
    try {
      const res = await api.get('/wishlist')
      setItems(res.data.items)
    } catch (err) { console.error(err) }
  }

  const toggleWishlist = async (productId) => {
    const res = await api.post('/wishlist/toggle', { product_id: productId })
    await loadWishlist()
    return res.data
  }

  const isWished = (productId) => items.some((i) => i.product?.id === productId)

  return (
    <WishlistContext.Provider value={{ items, count: items.length, toggleWishlist, isWished, reload: loadWishlist }}>
      {children}
    </WishlistContext.Provider>
  )
}
