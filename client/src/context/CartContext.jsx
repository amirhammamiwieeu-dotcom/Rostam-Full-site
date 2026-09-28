import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const CartContext = createContext()

export const useCart = () => {
  const ctx = useContext(CartContext)
  if (!ctx) throw new Error('useCart must be used within CartProvider')
  return ctx
}

export function CartProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])
  const [subtotal, setSubtotal] = useState(0)
  const [count, setCount] = useState(0)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (user) loadCart()
    else { setItems([]); setSubtotal(0); setCount(0) }
  }, [user])

  const loadCart = async () => {
    setLoading(true)
    try {
      const res = await api.get('/cart')
      setItems(res.data.items)
      setSubtotal(res.data.subtotal)
      setCount(res.data.count)
    } catch (err) { console.error(err) }
    finally { setLoading(false) }
  }

  const addToCart = async (productId, quantity = 1) => {
    const res = await api.post('/cart/add', { product_id: productId, quantity })
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
    return res
  }

  const updateCartItem = async (itemId, quantity) => {
    const res = await api.put(`/cart/items/${itemId}`, { quantity })
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
  }

  const removeCartItem = async (itemId) => {
    const res = await api.delete(`/cart/items/${itemId}`)
    setItems(res.data.items); setSubtotal(res.data.subtotal); setCount(res.data.count)
  }

  const clearCart = async () => {
    await api.delete('/cart')
    setItems([]); setSubtotal(0); setCount(0)
  }

  return (
    <CartContext.Provider value={{ items, subtotal, count, loading, addToCart, updateCartItem, removeCartItem, clearCart, reload: loadCart }}>
      {children}
    </CartContext.Provider>
  )
}
