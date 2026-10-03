import { useState, useRef } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { User, Package, Heart, LogOut, Settings, ShoppingBag } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { useOnClickOutside } from '../../hooks/useOnClickOutside'
import toast from 'react-hot-toast'

export default function UserMenu() {
  const { user, profile, signOut } = useAuth()
  const [open, setOpen] = useState(false)
  const ref = useRef(null)
  const navigate = useNavigate()

  useOnClickOutside(ref, () => setOpen(false))

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  // ====== وقتی کاربر لاگین نیست ======
  if (!user) {
    return (
      <Link
        to="/login"
        className="flex items-center gap-1 sm:gap-2 px-1 sm:px-3 py-1 hover:border hover:border-white rounded transition shrink-0"
        aria-label="Sign in"
      >
        <User className="h-4 w-4 sm:h-5 sm:w-5" />
        <div className="text-xs hidden lg:block">
          <div className="text-gray-400">Sign in</div>
          <div className="font-semibold">Account</div>
        </div>
      </Link>
    )
  }

  // ====== وقتی کاربر لاگین هست ======
  const initials = (profile?.full_name || user.email || 'U')
    .split(' ')
    .map((n) => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

  const menuItems = [
    { icon: Package, label: 'Your Orders', to: '/orders' },
    { icon: Heart, label: 'Your Wishlist', to: '/wishlist' },
    { icon: User, label: 'Account', to: '/account' },
    { icon: Settings, label: 'Settings', to: '/account/profile' },
  ]

  if (profile?.role === 'admin') {
    menuItems.push({ icon: ShoppingBag, label: 'Admin Dashboard', to: '/admin' })
  }

  return (
    <div className="relative shrink-0" ref={ref}>
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-1 sm:gap-2 px-1 sm:px-3 py-1 hover:border hover:border-white rounded transition shrink-0"
        aria-label="Account menu"
      >
        <div className="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-primary flex items-center justify-center text-secondary font-bold text-xs sm:text-sm">
          {initials}
        </div>
        <div className="text-xs hidden lg:block">
          <div className="text-gray-400">Hello,</div>
          <div className="font-semibold">
            {profile?.full_name?.split(' ')[0] || 'Account'}
          </div>
        </div>
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-64 max-w-[90vw] bg-white dark:bg-secondary-light rounded-xl shadow-2xl overflow-hidden z-50">
          <div className="p-4 bg-gray-50 dark:bg-secondary border-b border-gray-200 dark:border-gray-700">
            <p className="font-semibold text-sm text-secondary dark:text-white truncate">
              {profile?.full_name || 'User'}
            </p>
            <p className="text-xs text-gray-500 truncate">{user.email}</p>
          </div>

          <div className="py-2">
            {menuItems.map((item) => (
              <Link
                key={item.to}
                to={item.to}
                onClick={() => setOpen(false)}
                className="flex items-center gap-3 px-4 py-2.5 text-sm text-secondary dark:text-white hover:bg-gray-50 dark:hover:bg-secondary transition"
              >
                <item.icon className="h-4 w-4 text-gray-500" />
                {item.label}
              </Link>
            ))}
          </div>

          <div className="border-t border-gray-200 dark:border-gray-700">
            <button
              onClick={handleSignOut}
              className="flex items-center gap-3 w-full px-4 py-3 text-sm text-danger hover:bg-red-50 dark:hover:bg-red-900/10 transition"
            >
              <LogOut className="h-4 w-4" />
              Sign Out
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
