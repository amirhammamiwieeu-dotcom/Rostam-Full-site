import { useEffect, useState } from 'react'
import { Plus, MapPin } from 'lucide-react'
import toast from 'react-hot-toast'
import UserLayout from '../components/user/UserLayout'
import AddressCard from '../components/user/AddressCard'
import AddressForm from '../components/user/AddressForm'
import Button from '../components/ui/Button'
import Spinner from '../components/ui/Spinner'
import { supabase } from '../lib/supabase'
import { useAuth } from '../context/AuthContext'

export default function AccountAddresses() {
  const { user } = useAuth()
  const [addresses, setAddresses] = useState([])
  const [loading, setLoading] = useState(true)
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState(null)

  const load = async () => {
    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('addresses')
        .select('*')
        .eq('user_id', user.id)
        .order('is_default', { ascending: false })
        .order('created_at', { ascending: false })
      if (error) throw error
      setAddresses(data || [])
    } catch (err) {
      console.error(err)
      toast.error('Failed to load addresses')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (user) load()
  }, [user])

  const handleAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const handleEdit = (address) => {
    setEditing(address)
    setFormOpen(true)
  }

  const handleDelete = async (address) => {
    if (!confirm('Delete this address?')) return
    try {
      const { error } = await supabase
        .from('addresses')
        .delete()
        .eq('id', address.id)
      if (error) throw error
      toast.success('Address deleted')
      load()
    } catch (err) {
      toast.error('Failed to delete')
    }
  }

  const handleSetDefault = async (address) => {
    try {
      await supabase
        .from('addresses')
        .update({ is_default: false })
        .eq('user_id', user.id)
      const { error } = await supabase
        .from('addresses')
        .update({ is_default: true })
        .eq('id', address.id)
      if (error) throw error
      toast.success('Default address updated')
      load()
    } catch (err) {
      toast.error('Failed')
    }
  }

  const handleSubmit = async (form) => {
    try {
      if (form.is_default) {
        await supabase
          .from('addresses')
          .update({ is_default: false })
          .eq('user_id', user.id)
      }

      if (editing) {
        const { error } = await supabase
          .from('addresses')
          .update(form)
          .eq('id', editing.id)
        if (error) throw error
        toast.success('Address updated')
      } else {
        const { error } = await supabase
          .from('addresses')
          .insert({ ...form, user_id: user.id })
        if (error) throw error
        toast.success('Address added')
      }
      load()
    } catch (err) {
      toast.error(err.message || 'Failed to save')
      throw err
    }
  }

  return (
    <UserLayout
      title="Addresses"
      description="Manage your delivery addresses"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="h-4 w-4" />
          Add Address
        </Button>
      }
    >
      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : addresses.length === 0 ? (
        <div className="bg-white dark:bg-secondary-light rounded-xl shadow-card p-12 text-center">
          <MapPin className="h-12 w-12 text-gray-300 mx-auto mb-3" />
          <h3 className="font-bold mb-2 text-secondary dark:text-white">
            No addresses yet
          </h3>
          <p className="text-sm text-gray-500 mb-5">
            Add your first delivery address
          </p>
          <Button onClick={handleAdd}>
            <Plus className="h-4 w-4" />
            Add Address
          </Button>
        </div>
      ) : (
        <div className="space-y-3">
          {addresses.map((address) => (
            <AddressCard
              key={address.id}
              address={address}
              onEdit={handleEdit}
              onDelete={handleDelete}
              onSetDefault={handleSetDefault}
            />
          ))}
        </div>
      )}

      <AddressForm
        open={formOpen}
        onClose={() => setFormOpen(false)}
        onSubmit={handleSubmit}
        initial={editing}
      />
    </UserLayout>
  )
}
