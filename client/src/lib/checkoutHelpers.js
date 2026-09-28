export const shippingMethods = [
  { id: 'standard', name: 'Standard Shipping', desc: '5-7 business days', price: 5.99, days: '5-7' },
  { id: 'express', name: 'Express Shipping', desc: '2-3 business days', price: 14.99, days: '2-3' },
  { id: 'same_day', name: 'Same-Day Delivery', desc: 'Within 24 hours', price: 24.99, days: '1' },
]

export const TAX_RATE = 0.09
export const FREE_SHIPPING_THRESHOLD = 50

export const calculateShipping = (method, subtotal) => {
  if (method === 'standard' && subtotal >= FREE_SHIPPING_THRESHOLD) return 0
  const found = shippingMethods.find((m) => m.id === method)
  return found ? found.price : 5.99
}

export const calculateTax = (subtotal, discount = 0) => {
  return Math.round((subtotal - discount) * TAX_RATE * 100) / 100
}

export const calculateTotal = (subtotal, discount = 0, shipping = 0) => {
  const tax = calculateTax(subtotal, discount)
  return Math.round((subtotal - discount + shipping + tax) * 100) / 100
}
