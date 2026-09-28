export const validators = {
  email: (value) => {
    if (!value) return 'Email is required'
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!re.test(value)) return 'Invalid email address'
    return null
  },

  password: (value) => {
    if (!value) return 'Password is required'
    if (value.length < 8) return 'Password must be at least 8 characters'
    if (!/[A-Z]/.test(value)) return 'Must contain an uppercase letter'
    if (!/[a-z]/.test(value)) return 'Must contain a lowercase letter'
    if (!/[0-9]/.test(value)) return 'Must contain a number'
    return null
  },

  simplePassword: (value) => {
    if (!value) return 'Password is required'
    if (value.length < 6) return 'Password must be at least 6 characters'
    return null
  },

  fullName: (value) => {
    if (!value) return 'Full name is required'
    if (value.length < 2) return 'Name must be at least 2 characters'
    if (value.length > 100) return 'Name is too long'
    return null
  },

  phone: (value) => {
    if (!value) return null
    const re = /^\+?[0-9]{10,15}$/
    if (!re.test(value)) return 'Invalid phone number'
    return null
  },
}

export const validateForm = (values, rules) => {
  const errors = {}
  for (const field in rules) {
    const error = rules[field](values[field])
    if (error) errors[field] = error
  }
  return errors
}
