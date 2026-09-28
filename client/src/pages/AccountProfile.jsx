import UserLayout from '../components/user/UserLayout'
import ProfileForm from '../components/user/ProfileForm'

export default function AccountProfile() {
  return (
    <UserLayout
      title="Profile"
      description="Manage your personal information"
    >
      <ProfileForm />
    </UserLayout>
  )
}
