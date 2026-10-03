import { useState, useEffect } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Link } from 'react-router-dom'

const slides = [
  { title: 'Mega Sale', subtitle: 'Up to 70% OFF', image: 'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1600&h=600&fit=crop', cta: 'Shop Now', link: '/products?sort=discount' },
  { title: 'New Arrivals', subtitle: 'Fresh Picks Weekly', image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600&h=600&fit=crop', cta: 'Browse New', link: '/products?sort=newest' },
  { title: 'Tech Deals', subtitle: 'Save on Electronics', image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1600&h=600&fit=crop', cta: 'Shop Tech', link: '/products?category=electronics' },
]

export default function Hero() {
  const [current, setCurrent] = useState(0)
  useEffect(() => {
    const timer = setInterval(() => setCurrent((c) => (c + 1) % slides.length), 6000)
    return () => clearInterval(timer)
  }, [])
  const next = () => setCurrent((c) => (c + 1) % slides.length)
  const prev = () => setCurrent((c) => (c - 1 + slides.length) % slides.length)

  return (
    <div className="relative h-[300px] sm:h-[400px] md:h-[500px] overflow-hidden">
      {slides.map((slide, index) => (
        <div key={index} className={`absolute inset-0 transition-opacity duration-1000 ${index === current ? 'opacity-100' : 'opacity-0'}`}>
          <img src={slide.image} alt={slide.title} className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-black/70 via-black/40 to-black/20" />
          <div className="absolute inset-0 flex items-center">
            <div className="container-page w-full">
              <div className="max-w-2xl text-white">
                <h2 className="text-3xl sm:text-5xl md:text-7xl font-black mb-1 sm:mb-2">
                  {slide.title}
                </h2>
                <p className="text-lg sm:text-2xl md:text-3xl text-primary font-bold mb-4 sm:mb-6">
                  {slide.subtitle}
                </p>
                <Link
                  to={slide.link}
                  className="inline-block bg-primary hover:bg-primary-dark text-secondary font-bold px-5 sm:px-8 py-2.5 sm:py-3 rounded-lg transition text-sm sm:text-base"
                >
                  {slide.cta} →
                </Link>
              </div>
            </div>
          </div>
        </div>
      ))}

      {/* Nav buttons - smaller on mobile */}
      <button
        onClick={prev}
        className="absolute left-2 sm:left-4 top-1/2 -translate-y-1/2 w-9 h-9 sm:w-12 sm:h-12 rounded-full bg-white/90 hover:bg-white flex items-center justify-center transition z-10"
        aria-label="Previous slide"
      >
        <ChevronLeft className="h-5 w-5 sm:h-6 sm:w-6 text-secondary" />
      </button>
      <button
        onClick={next}
        className="absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 w-9 h-9 sm:w-12 sm:h-12 rounded-full bg-white/90 hover:bg-white flex items-center justify-center transition z-10"
        aria-label="Next slide"
      >
        <ChevronRight className="h-5 w-5 sm:h-6 sm:w-6 text-secondary" />
      </button>

      <div className="absolute bottom-4 sm:bottom-6 left-1/2 -translate-x-1/2 flex gap-2 z-10">
        {slides.map((_, index) => (
          <button
            key={index}
            onClick={() => setCurrent(index)}
            className={`h-2 rounded-full transition-all ${index === current ? 'bg-primary w-6 sm:w-8' : 'bg-white/60 hover:bg-white w-2'}`}
            aria-label={`Go to slide ${index + 1}`}
          />
        ))}
      </div>
    </div>
  )
}
