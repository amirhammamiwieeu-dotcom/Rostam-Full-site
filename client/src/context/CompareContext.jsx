import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'
import { useAuth } from './AuthContext'

const CompareContext = createContext()

export const useCompare = () => {
  const ctx = useContext(CompareContext)
  if (!ctx) throw new Error('useCompare must be used within CompareProvider')
  return ctx
}

export function CompareProvider({ children }) {
  const { user } = useAuth()
  const [items, setItems] = useState([])

  useEffect(() => {
    if (user) loadCompare()
    else setItems([])
  }, [user])

  const loadCompare = async () => {
    try {
      const res = await api.get('/compare')
      setItems(res.data.items)
    } catch (err) { console.error(err) }
  }

  const addToCompare = async (productId) => {
    const res = await api.post('/compare', { product_id: productId })
    setItems(res.data.items)
    return res.data
  }

  const removeFromCompare = async (productId) => {
    const res = await api.delete(`/compare/${productId}`)
    setItems(res.data.items)
  }

  const isCompared = (productId) => items.some((i) => i.product?.id === productId)

  return (
    <CompareContext.Provider value={{ items, count: items.length, addToCompare, removeFromCompare, isCompared, reload: loadCompare }}>
      {children}
    </CompareContext.Provider>
  )
}
