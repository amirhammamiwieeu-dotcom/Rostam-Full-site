import { useState, useEffect } from 'react'
import { api } from '../lib/api'
import { useAuth } from '../context/AuthContext'

export function useProfile() {
  const { user, fetchProfile } = useAuth()
  const [loading, setLoading] = useState(true)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    if (user) {
      fetchProfile().finally(() => setLoading(false))
    } else {
      setLoading(false)
    }
  }, [user])

  const updateProfile = async (updates) => {
    setUpdating(true)
    try {
      const res = await api.put('/auth/me', updates)
      await fetchProfile()
      return res.data
    } finally {
      setUpdating(false)
    }
  }

  const changePassword = async ({ current_password, new_password }) => {
    return await api.post('/auth/change-password', {
      current_password,
      new_password,
    })
  }

  return { loading, updating, updateProfile, changePassword }
}
