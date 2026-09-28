import { useNavigate } from 'react-router-dom'
import { BarChart3, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import { useCompare } from '../../context/CompareContext'
import { useAuth } from '../../context/AuthContext'

export default function CompareButton({ productId }) {
  const navigate = useNavigate()
  const { isCompared, addToCompare, removeFromCompare } = useCompare()
  const { user } = useAuth()
  const compared = isCompared(productId)

  const handleClick = async () => {
    if (!user) {
      toast.error('Please sign in')
      navigate('/login')
      return
    }
    try {
      if (compared) {
        await removeFromCompare(productId)
        toast.success('Removed from compare')
      } else {
        await addToCompare(productId)
        toast.success('Added to compare')
      }
    } catch (err) {
      toast.error(err.message || 'Failed')
    }
  }

  return (
    <button
      onClick={handleClick}
      className={`flex items-center gap-2 px-4 py-3 border rounded-lg transition font-medium ${
        compared
          ? 'border-link text-link bg-blue-50 dark:bg-blue-900/10'
          : 'border-gray-300 dark:border-gray-700 text-secondary dark:text-white hover:border-link hover:text-link'
      }`}
    >
      {compared ? <Check className="h-5 w-5" /> : <BarChart3 className="h-5 w-5" />}
      {compared ? 'Comparing' : 'Compare'}
    </button>
  )
}
