import { useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'

export default function Search() {
  const [params] = useSearchParams()
  const navigate = useNavigate()

  useEffect(() => {
    const q = params.get('q') || ''
    navigate(`/products?q=${encodeURIComponent(q)}`, { replace: true })
  }, [params, navigate])

  return null
}
