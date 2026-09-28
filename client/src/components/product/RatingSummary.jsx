import RatingStars from './RatingStars'

export default function RatingSummary({ average = 0, total = 0, distribution = {} }) {
  const totalCount = Object.values(distribution).reduce((s, c) => s + c, 0) || total

  return (
    <div className="grid md:grid-cols-[200px_1fr] gap-6 pb-6 border-b border-gray-200 dark:border-gray-700">
      <div className="text-center md:text-left">
        <div className="text-5xl font-bold text-secondary dark:text-white">
          {average.toFixed(1)}
        </div>
        <div className="my-2 flex justify-center md:justify-start">
          <RatingStars rating={average} size="md" />
        </div>
        <div className="text-sm text-gray-500">
          {totalCount.toLocaleString()} ratings
        </div>
      </div>

      <div className="space-y-1.5">
        {[5, 4, 3, 2, 1].map((star) => {
          const count = distribution[star] || 0
          const pct = totalCount > 0 ? (count / totalCount) * 100 : 0
          return (
            <div key={star} className="flex items-center gap-3 text-sm">
              <span className="w-12 text-gray-600 dark:text-gray-400">{star} star</span>
              <div className="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div
                  className="h-full bg-yellow-500 transition-all"
                  style={{ width: `${pct}%` }}
                />
              </div>
              <span className="w-12 text-right text-gray-500">{Math.round(pct)}%</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
