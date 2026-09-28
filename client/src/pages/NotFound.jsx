import { Link } from 'react-router-dom'
import { Home } from 'lucide-react'
import Button from '../components/ui/Button'

export default function NotFound() {
  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center px-4 text-center">
      <h1 className="text-8xl font-black text-primary mb-4">404</h1>
      <h2 className="text-2xl font-bold text-secondary dark:text-white mb-2">Page Not Found</h2>
      <p className="text-gray-500 mb-8 max-w-md">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Link to="/">
        <Button size="lg">
          <Home className="h-5 w-5" />
          Back to Home
        </Button>
      </Link>
    </div>
  )
}
