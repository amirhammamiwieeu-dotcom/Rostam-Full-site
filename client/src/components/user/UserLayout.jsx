import UserSidebar from './UserSidebar'

export default function UserLayout({ title, description, children, actions }) {
  return (
    <div className="container-page py-6">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <UserSidebar />

        <div className="min-w-0">
          {(title || actions) && (
            <div className="flex items-center justify-between flex-wrap gap-3 mb-5">
              <div>
                {title && (
                  <h1 className="text-2xl font-bold text-secondary dark:text-white">
                    {title}
                  </h1>
                )}
                {description && (
                  <p className="text-sm text-gray-500 mt-1">{description}</p>
                )}
              </div>
              {actions && <div>{actions}</div>}
            </div>
          )}

          <div>{children}</div>
        </div>
      </div>
    </div>
  )
}
