import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard,
  User,
  MapPin,
  MessageSquare,
  Settings,
  Package,
  Heart,
  LogOut,
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', to: '/account', end: true },
  { icon: Package, label: 'My Orders', to: '/orders' },
  { icon: Heart, label: 'Wishlist', to: '/wishlist' },
  { icon: User, label: 'Profile', to: '/account/profile' },
  { icon: MapPin, label: 'Addresses', to: '/account/addresses' },
  { icon: MessageSquare, label: 'My Reviews', to: '/account/reviews' },
  { icon: Settings, label: 'Settings', to: '/account/settings' },
]

export default function UserSidebar() {
  const { profile, user, signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  const initials = (profile?.full_name || user?.email || 'U')
    .split(' ')
    .map((n) => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

  return (
    <aside className="bg-white dark:bg-secondary-light rounded-xl shadow-card overflow-hidden h-fit lg:sticky lg:top-32">
      {/* Profile header */}
      <div className="p-5 border-b border-gray-200 dark:border-gray-700 text-center">
        <div className="w-16 h-16 mx-auto rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xl mb-3">
          {initials}
        </div>
        <h3 className="font-bold text-secondary dark:text-white text-sm">
          {profile?.full_name || 'User'}
        </h3>
        <p className="text-xs text-gray-500 truncate mt-1">{user?.email}</p>
      </div>

      {/* Menu */}
      <nav className="p-2">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                isActive
                  ? 'bg-primary text-secondary'
                  : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-secondary hover:text-primary'
              }`
            }
          >
            <item.icon className="h-4 w-4" />
            {item.label}
          </NavLink>
        ))}

        <button
          onClick={handleSignOut}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-danger hover:bg-red-50 dark:hover:bg-red-900/10 transition mt-1"
        >
          <LogOut className="h-4 w-4" />
          Sign Out
        </button>
      </nav>
    </aside>
  )
}
