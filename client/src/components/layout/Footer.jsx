import { Link } from 'react-router-dom'
import { ShoppingCart, Facebook, Instagram, Twitter, Youtube } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="bg-secondary text-gray-300 mt-auto">
      <div className="bg-secondary-light py-4 text-center hover:bg-secondary-light/80 transition cursor-pointer">
        <a href="#" className="text-sm font-medium">Back to top</a>
      </div>
      <div className="container-page py-12 grid grid-cols-2 md:grid-cols-4 gap-8">
        <div>
          <h4 className="text-white font-bold mb-4">Get to Know Us</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/about" className="hover:text-primary transition">About Us</Link></li>
            <li><Link to="/careers" className="hover:text-primary transition">Careers</Link></li>
            <li><Link to="/blog" className="hover:text-primary transition">Blog</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Make Money</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/sell" className="hover:text-primary transition">Sell products</Link></li>
            <li><Link to="/affiliate" className="hover:text-primary transition">Become Affiliate</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Customer Service</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/contact" className="hover:text-primary transition">Contact Us</Link></li>
            <li><Link to="/shipping" className="hover:text-primary transition">Shipping</Link></li>
            <li><Link to="/returns" className="hover:text-primary transition">Returns</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-bold mb-4">Follow Us</h4>
          <div className="flex gap-3">
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Facebook className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Instagram className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Twitter className="h-4 w-4" /></a>
            <a href="#" className="w-9 h-9 rounded-full bg-secondary-light flex items-center justify-center hover:bg-primary hover:text-secondary transition"><Youtube className="h-4 w-4" /></a>
          </div>
        </div>
      </div>
      <div className="bg-secondary-dark py-6 text-center text-sm text-gray-500">
        <div className="flex items-center justify-center gap-2 mb-2">
          <ShoppingCart className="h-5 w-5 text-primary" />
          <span className="text-white font-bold">Market<span className="text-primary">Hub</span></span>
        </div>
        <p>© {new Date().getFullYear()} MarketHub. All rights reserved.</p>
      </div>
    </footer>
  )
}
