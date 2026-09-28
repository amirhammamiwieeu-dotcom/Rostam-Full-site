export default function ProductSkeleton() {
  return (
    <div className="bg-white dark:bg-secondary-light rounded-xl p-3 animate-pulse">
      <div className="w-full h-40 bg-gray-200 dark:bg-gray-700 rounded-lg mb-3" />
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2" />
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 mb-2" />
      <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-1/2 mb-2" />
      <div className="h-5 bg-gray-200 dark:bg-gray-700 rounded w-1/3 mb-3" />
      <div className="h-9 bg-gray-200 dark:bg-gray-700 rounded" />
    </div>
  )
}
