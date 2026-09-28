import { useState } from 'react'
import { Lock, Bell, Trash2, AlertTriangle } from 'lucide-react'
import toast from 'react-hot-toast'
import UserLayout from '../components/user/UserLayout'
import PasswordInput from '../components/auth/PasswordInput'
import Button from '../components/ui/Button'
import { useProfile } from '../hooks/useProfile'

export default function AccountSettings() {
  const { changePassword } = useProfile()
  const [form, setForm] = useState({
    current_password: '',
    new_password: '',
    confirm_password: '',
  })
  const [errors, setErrors] = useState({})
  const [saving, setSaving] = useState(false)

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handlePasswordSubmit = async (e) => {
    e.preventDefault()
    const newErrors = {}
    if (!form.current_password) newErrors.current_password = 'Current password required'
    if (form.new_password.length < 8) newErrors.new_password = 'Min 8 characters'
    if (form.new_password !== form.confirm_password) {
      newErrors.confirm_password = 'Passwords do not match'
    }
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }

    setSaving(true)
    try {
      await changePassword({
        current_password: form.current_password,
        new_password: form.new_password,
      })
      toast.success('Password changed')
      setForm({ current_password: '', new_password: '', confirm_password: '' })
    } catch (err) {
      toast.error(err.message || 'Failed to change password')
    } finally {
      setSaving(false)
    }
  }

  return (
    <UserLayout
      title="Settings"
      description="Manage your account settings"
    >
      <div className="space-y-6">
        {/* Change Password */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
          <h2 className="font-bold text-secondary dark:text-white mb-1 flex items-center gap-2">
            <Lock className="h-5 w-5 text-primary" />
            Change Password
          </h2>
          <p className="text-xs text-gray-500 mb-5">
            Update your account password
          </p>

          <form onSubmit={handlePasswordSubmit} className="space-y-4 max-w-md">
            <PasswordInput
              value={form.current_password}
              onChange={(e) => handleChange('current_password', e.target.value)}
              error={errors.current_password}
              placeholder="Current password"
              autoComplete="current-password"
            />
            <PasswordInput
              value={form.new_password}
              onChange={(e) => handleChange('new_password', e.target.value)}
              error={errors.new_password}
              placeholder="New password"
              autoComplete="new-password"
            />
            <PasswordInput
              value={form.confirm_password}
              onChange={(e) => handleChange('confirm_password', e.target.value)}
              error={errors.confirm_password}
              placeholder="Confirm new password"
              autoComplete="new-password"
            />
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving...' : 'Change Password'}
            </Button>
          </form>
        </div>

        {/* Notifications (placeholder) */}
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6">
          <h2 className="font-bold text-secondary dark:text-white mb-1 flex items-center gap-2">
            <Bell className="h-5 w-5 text-primary" />
            Notifications
          </h2>
          <p className="text-xs text-gray-500 mb-5">
            Choose what emails you want to receive
          </p>
          <div className="space-y-3">
            {['Order updates', 'Promotions', 'New arrivals', 'Price drops on wishlist'].map((label) => (
              <label key={label} className="flex items-center gap-3 text-sm text-secondary dark:text-white cursor-pointer">
                <input
                  type="checkbox"
                  defaultChecked
                  className="accent-primary w-4 h-4"
                />
                {label}
              </label>
            ))}
          </div>
        </div>

        {/* Danger Zone */}
        <div className="bg-red-50 dark:bg-red-900/10 border-2 border-danger/30 rounded-xl p-6">
          <h2 className="font-bold text-danger mb-1 flex items-center gap-2">
            <AlertTriangle className="h-5 w-5" />
            Danger Zone
          </h2>
          <p className="text-xs text-gray-600 dark:text-gray-400 mb-5">
            Once you delete your account, there is no going back.
          </p>
          <Button
            variant="danger"
            onClick={() => toast.error('Account deletion requires support. Contact us.')}
          >
            <Trash2 className="h-4 w-4" />
            Delete Account
          </Button>
        </div>
      </div>
    </UserLayout>
  )
}
