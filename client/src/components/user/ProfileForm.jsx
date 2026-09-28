import { useState, useEffect } from 'react'
import { User, Mail, Phone, FileText, Image as ImageIcon } from 'lucide-react'
import toast from 'react-hot-toast'
import Button from '../ui/Button'
import { useAuth } from '../../context/AuthContext'
import { useProfile } from '../../hooks/useProfile'

export default function ProfileForm() {
  const { profile } = useAuth()
  const { updateProfile, updating } = useProfile()

  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    username: '',
    bio: '',
    avatar_url: '',
  })
  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (profile) {
      setForm({
        full_name: profile.full_name || '',
        email: profile.email || '',
        phone: profile.phone || '',
        username: profile.username || '',
        bio: profile.bio || '',
        avatar_url: profile.avatar_url || '',
      })
    }
  }, [profile])

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const newErrors = {}
    if (!form.full_name.trim()) newErrors.full_name = 'Name required'
    if (!form.email.trim()) newErrors.email = 'Email required'
    if (form.phone && !/^\+?[0-9]{10,15}$/.test(form.phone)) {
      newErrors.phone = 'Invalid phone number'
    }
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    try {
      await updateProfile({
        full_name: form.full_name,
        email: form.email,
        phone: form.phone || null,
        username: form.username || null,
        bio: form.bio || null,
        avatar_url: form.avatar_url || null,
      })
      toast.success('Profile updated')
    } catch (err) {
      toast.error(err.message || 'Failed to update')
    }
  }

  const Field = ({ icon: Icon, label, name, placeholder, type = 'text', required = false, disabled = false }) => (
    <div>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} {required && '*'}
      </label>
      <div className="relative">
        <Icon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type={type}
          value={form[name]}
          onChange={(e) => handleChange(name, e.target.value)}
          placeholder={placeholder}
          disabled={disabled}
          className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary disabled:opacity-60 ${
            errors[name]
              ? 'border-danger'
              : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
          }`}
        />
      </div>
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <form onSubmit={handleSubmit} className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-6 space-y-5">
      <div className="grid md:grid-cols-2 gap-5">
        <Field icon={User} label="Full Name" name="full_name" placeholder="John Doe" required />
        <Field icon={Mail} label="Email" name="email" placeholder="john@example.com" type="email" required disabled />
        <Field icon={Phone} label="Phone" name="phone" placeholder="+1 234 567 8900" />
        <Field icon={User} label="Username" name="username" placeholder="johndoe" />
      </div>

      <div>
        <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
          Bio
        </label>
        <div className="relative">
          <FileText className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
          <textarea
            value={form.bio}
            onChange={(e) => handleChange('bio', e.target.value)}
            placeholder="Tell us about yourself..."
            rows={3}
            maxLength={500}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary focus:border-primary focus:ring-2 focus:ring-primary/20 resize-y"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
          Avatar URL
        </label>
        <div className="relative">
          <ImageIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="url"
            value={form.avatar_url}
            onChange={(e) => handleChange('avatar_url', e.target.value)}
            placeholder="https://example.com/avatar.jpg"
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </div>
      </div>

      <div className="flex justify-end pt-2">
        <Button type="submit" disabled={updating}>
          {updating ? 'Saving...' : 'Save Changes'}
        </Button>
      </div>
    </form>
  )
}
