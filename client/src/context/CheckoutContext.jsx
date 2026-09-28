import { createContext, useContext, useState } from 'react'

const CheckoutContext = createContext()

export const useCheckout = () => {
  const ctx = useContext(CheckoutContext)
  if (!ctx) throw new Error('useCheckout must be used within CheckoutProvider')
  return ctx
}

export function CheckoutProvider({ children }) {
  const [step, setStep] = useState(1)
  const [shippingAddress, setShippingAddress] = useState(null)
  const [shippingMethod, setShippingMethod] = useState('standard')
  const [coupon, setCoupon] = useState(null)
  const [paymentIntent, setPaymentIntent] = useState(null)

  const reset = () => {
    setStep(1)
    setShippingAddress(null)
    setShippingMethod('standard')
    setCoupon(null)
    setPaymentIntent(null)
  }

  return (
    <CheckoutContext.Provider
      value={{
        step,
        setStep,
        shippingAddress,
        setShippingAddress,
        shippingMethod,
        setShippingMethod,
        coupon,
        setCoupon,
        paymentIntent,
        setPaymentIntent,
        reset,
      }}
    >
      {children}
    </CheckoutContext.Provider>
  )
}
