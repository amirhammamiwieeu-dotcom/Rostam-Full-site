import { useState } from 'react'
import { User, Mail, Phone, MapPin, Building } from 'lucide-react'
import Button from '../ui/Button'

const IconField = ({ icon: Icon, label, name, placeholder, type = 'text', value, onChange, error, required }) => (
  <div>
    <label className="block text-sm font-medium mb-1.5 text-secondary dark:text-white">
      {label} {required && '*'}
    </label>
    <div className="relative">
      <Icon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
      <input
        type={type}
        name={name}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        autoComplete="off"
        className={`w-full pl-10 pr-4 py-2.5 border rounded-lg outline-none transition text-sm text-secondary dark:text-white dark:bg-secondary ${
          error
            ? 'border-danger'
            : 'border-gray-300 dark:border-gray-700 focus:border-primary focus:ring-2 focus:ring-primary/20'
        }`}
      />
    </div>
    {error && <p className="mt-1 text-xs text-danger">{error}</p>}
  </div>
)

export default function ShippingForm({ onNext, initial = {} }) {
  const [form, setForm] = useState({
    full_name: initial.full_name || '',
    email: initial.email || '',
    phone: initial.phone || '',
    address_line1: initial.address_line1 || '',
    address_line2: initial.address_line2 || '',
    city: initial.city || '',
    state: initial.state || '',
    country: initial.country || 'US',
    zip: initial.zip || '',
  })
  const [errors, setErrors] = useState({})

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm((prev) => ({ ...prev, [name]: value }))
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: null }))
  }

  const validate = () => {
    const newErrors = {}
    if (!form.full_name.trim()) newErrors.full_name = 'Full name required'
    if (!form.email.trim()) newErrors.email = 'Email required'
    if (!form.phone.trim()) newErrors.phone = 'Phone required'
    if (!form.address_line1.trim()) newErrors.address_line1 = 'Address required'
    if (!form.city.trim()) newErrors.city = 'City required'
    if (!form.zip.trim()) newErrors.zip = 'ZIP required'
    return newErrors
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const newErrors = validate()
    if (Object.keys(newErrors).length) {
      setErrors(newErrors)
      return
    }
    onNext(form)
  }

  return (
    <form onSubmit={handleSubmit}>
      <h2 className="text-xl font-bold mb-1 text-secondary dark:text-white">
        Shipping Information
      </h2>
      <p className="text-sm text-gray-500 mb-6">
        Where should we deliver your order?
      </p>

      <div className="grid md:grid-cols-2 gap-4 mb-6">
        <div className="md:col-span-2">
          <IconField
            icon={User}
            label="Full Name"
            name="full_name"
            placeholder="John Doe"
            value={form.full_name}
            onChange={handleChange}
            error={errors.full_name}
            required
          />
        </div>

        <div className="md:col-span-2">
          <IconField
            icon={Mail}
            label="Email"
            name="email"
            type="email"
            placeholder="john@example.com"
            value={form.email}
            onChange={handleChange}
            error={errors.email}
            required
          />
        </div>

        <div className="md:col-span-2">
          <IconField
            icon={Phone}
            label="Phone"
            name="phone"
            placeholder="+1 234 567 8900"
            value={form.phone}
            onChange={handleChange}
            error={errors.phone}
            required
          />
        </div>

        <div className="md:col-span-2">
          <IconField
            icon={MapPin}
            label="Address Line 1"
            name="address_line1"
            placeholder="123 Main St"
            value={form.address_line1}
            onChange={handleChange}
            error={errors.address_line1}
            required
          />
        </div>

        <div className="md:col-span-2">
          <IconField
            icon={Building}
            label="Address Line 2 (optional)"
            name="address_line2"
            placeholder="Apt 4B"
            value={form.address_line2}
            onChange={handleChange}
          />
        </div>

        <IconField
          icon={Building}
          label="City"
          name="city"
          placeholder="New York"
          value={form.city}
          onChange={handleChange}
          error={errors.city}
          required
        />

        <IconField
          icon={MapPin}
          label="State"
          name="state"
          placeholder="NY"
          value={form.state}
          onChange={handleChange}
        />

        <IconField
          icon={MapPin}
          label="ZIP Code"
          name="zip"
          placeholder="10001"
          value={form.zip}
          onChange={handleChange}
          error={errors.zip}
          required
        />

        <IconField
          icon={MapPin}
          label="Country"
          name="country"
          placeholder="US"
          value={form.country}
          onChange={handleChange}
        />
      </div>

      <Button type="submit" className="w-full">
        Continue to Shipping Method →
      </Button>
    </form>
  )
}
