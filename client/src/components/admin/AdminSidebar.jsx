import { NavLink, useNavigate, Link } from 'react-router-dom'
import {
  LayoutDashboard,
  Package,
  FolderTree,
  ShoppingCart,
  Users,
  MessageSquare,
  Tag,
  BarChart3,
  Home,
  LogOut,
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

const menuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', to: '/admin', end: true },
  { icon: Package, label: 'Products', to: '/admin/products' },
  { icon: FolderTree, label: 'Categories', to: '/admin/categories' },
  { icon: ShoppingCart, label: 'Orders', to: '/admin/orders' },
  { icon: Users, label: 'Users', to: '/admin/users' },
  { icon: MessageSquare, label: 'Reviews', to: '/admin/comments' },
  { icon: Tag, label: 'Coupons', to: '/admin/coupons' },
  { icon: BarChart3, label: 'Reports', to: '/admin/reports' },
]

export default function AdminSidebar({ open, onClose }) {
  const { signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    toast.success('Signed out')
    navigate('/')
  }

  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black/60 z-30 lg:hidden" onClick={onClose} />
      )}
      <aside
        className={`fixed lg:sticky top-0 left-0 h-screen lg:h-[calc(100vh-0px)] w-64 bg-secondary text-white z-40 overflow-y-auto transition-transform ${
          open ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        }`}
      >
        {/* Logo */}
        <div className="p-5 border-b border-secondary-light">
          <Link to="/admin" className="flex items-center gap-2 text-xl font-black">
            <span className="text-primary">Market</span>
            <span className="text-white">Hub</span>
            <span className="text-[10px] bg-primary text-secondary px-1.5 py-0.5 rounded font-bold">
              ADMIN
            </span>
          </Link>
        </div>

        {/* Menu */}
        <nav className="p-3 space-y-1">
          {menuItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                  isActive
                    ? 'bg-primary text-secondary'
                    : 'text-gray-300 hover:bg-secondary-light hover:text-white'
                }`
              }
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </NavLink>
          ))}
        </nav>

        {/* Footer */}
        <div className="absolute bottom-0 left-0 right-0 p-3 border-t border-secondary-light bg-secondary space-y-1">
          <Link
            to="/"
            className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-gray-300 hover:bg-secondary-light hover:text-white transition"
          >
            <Home className="h-4 w-4" />
            Back to Store
          </Link>
          <button
            onClick={handleSignOut}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-red-400 hover:bg-red-900/20 transition"
          >
            <LogOut className="h-4 w-4" />
            Sign Out
          </button>
        </div>
      </aside>
    </>
  )
}
