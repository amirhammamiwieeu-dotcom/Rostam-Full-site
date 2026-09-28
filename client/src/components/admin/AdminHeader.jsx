import { Menu, Bell, Moon, Sun, ExternalLink } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { useAuth } from '../../context/AuthContext'

export default function AdminHeader({ title, onMenuClick, actions }) {
  const { isDark, toggleTheme } = useTheme()
  const { profile } = useAuth()

  return (
    <header className="bg-white dark:bg-secondary-light border-b border-gray-200 dark:border-gray-700 px-4 sm:px-6 py-3 sticky top-0 z-20">
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 min-w-0">
          <button
            onClick={onMenuClick}
            className="lg:hidden p-2 hover:bg-gray-100 dark:hover:bg-secondary rounded-lg transition"
          >
            <Menu className="h-5 w-5" />
          </button>
          <h1 className="text-lg font-bold text-secondary dark:text-white truncate">
            {title || 'Admin'}
          </h1>
        </div>

        <div className="flex items-center gap-2">
          {actions}

          <Link
            to="/"
            className="hidden sm:flex items-center gap-1.5 px-3 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 hover:text-primary border border-gray-300 dark:border-gray-700 rounded-lg transition"
          >
            <ExternalLink className="h-3.5 w-3.5" />
            View Store
          </Link>

          <button
            onClick={toggleTheme}
            className="p-2 hover:bg-gray-100 dark:hover:bg-secondary rounded-lg transition text-secondary dark:text-white"
          >
            {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xs">
            {(profile?.full_name || 'A').charAt(0).toUpperCase()}
          </div>
        </div>
      </div>
    </header>
  )
}
