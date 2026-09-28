import { useState } from 'react'

export default function ProductGallery({ images = [], thumbnail }) {
  const allImages = images.length > 0 ? images : [thumbnail]
  const [selected, setSelected] = useState(0)

  return (
    <div className="flex flex-col gap-4">
      <div className="w-full aspect-square bg-gray-50 dark:bg-secondary rounded-xl overflow-hidden flex items-center justify-center">
        <img
          src={allImages[selected]}
          alt="Product"
          className="max-w-full max-h-full object-contain"
        />
      </div>

      {allImages.length > 1 && (
        <div className="flex gap-2 overflow-x-auto pb-2">
          {allImages.map((img, i) => (
            <button
              key={i}
              onClick={() => setSelected(i)}
              className={`flex-shrink-0 w-16 h-16 rounded-lg overflow-hidden border-2 transition ${
                i === selected
                  ? 'border-primary'
                  : 'border-gray-200 dark:border-gray-700 hover:border-primary'
              }`}
            >
              <img src={img} alt="" className="w-full h-full object-cover" />
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
