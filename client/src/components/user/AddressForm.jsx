import { useState, useEffect } from 'react'
import Button from '../ui/Button'
import Modal from '../ui/Modal'

const EMPTY = {
  title: '',
  full_name: '',
  phone: '',
  address_line1: '',
  address_line2: '',
  city: '',
  state: '',
  country: 'US',
  zip: '',
  is_default: false,
}

export default function AddressForm({ open, onClose, onSubmit, initial = null }) {
  const [form, setForm] = useState(EMPTY)
  const [loading, setLoading] = useState(false)
  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (open) {
      setForm(initial ? { ...EMPTY, ...initial } : EMPTY)
      setErrors({})
    }
  }, [open, initial])

  const handleChange = (field, value) => {
    setForm((f) => ({ ...f, [field]: value }))
    if (errors[field]) setErrors((e) => ({ ...e, [field]: null }))
  }

  const validate = () => {
    const newErrors = {}
    if (!form.title?.trim()) newErrors.title = 'Title required (e.g. Home)'
    if (!form.full_name.trim()) newErrors.full_name = 'Full name required'
    if (!form.address_line1.trim()) newErrors.address_line1 = 'Address required'
    if (!form.city.trim()) newErrors.city = 'City required'
    if (!form.zip.trim()) newErrors.zip = 'ZIP required'
    return newErrors
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const newErrors = validate()
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    setLoading(true)
    try {
      await onSubmit(form)
      onClose()
    } catch (err) {
      // handled by parent
    } finally {
      setLoading(false)
    }
  }

  const Field = ({ label, name, placeholder, required = false, half = false }) => (
    <div className={half ? 'md:col-span-1' : 'md:col-span-2'}>
      <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
        {label} {required && '*'}
      </label>
      <input
        type="text"
        value={form[name]}
        onChange={(e) => handleChange(name, e.target.value)}
        placeholder={placeholder}
        className={`w-full px-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
          errors[name]
            ? 'border-danger'
            : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
        }`}
      />
      {errors[name] && <p className="mt-1 text-xs text-danger">{errors[name]}</p>}
    </div>
  )

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={initial ? 'Edit Address' : 'Add New Address'}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Title" name="title" placeholder="Home / Office" required />
          <Field label="Full Name" name="full_name" placeholder="John Doe" required />
          <Field label="Phone" name="phone" placeholder="+1 234 567 8900" />
          <Field label="Address Line 1" name="address_line1" placeholder="123 Main St" required />
          <Field label="Address Line 2" name="address_line2" placeholder="Apt 4B (optional)" />
          <Field label="City" name="city" placeholder="New York" required half />
          <Field label="State" name="state" placeholder="NY" half />
          <Field label="ZIP" name="zip" placeholder="10001" required half />
          <Field label="Country" name="country" placeholder="US" half />
        </div>

        <label className="flex items-center gap-2 text-sm text-secondary dark:text-white cursor-pointer">
          <input
            type="checkbox"
            checked={form.is_default}
            onChange={(e) => handleChange('is_default', e.target.checked)}
            className="accent-primary"
          />
          Set as default address
        </label>

        <div className="flex gap-2 justify-end pt-2">
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Saving...' : initial ? 'Update' : 'Add Address'}
          </Button>
        </div>
      </form>
    </Modal>
  )
}
