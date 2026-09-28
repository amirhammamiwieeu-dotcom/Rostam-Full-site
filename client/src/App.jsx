import { Routes, Route } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import { AuthProvider } from './context/AuthContext'
import { CartProvider } from './context/CartContext'
import { WishlistProvider } from './context/WishlistContext'
import { CompareProvider } from './context/CompareContext'
import { CheckoutProvider } from './context/CheckoutContext'

import Layout from './components/layout/Layout'
import ProtectedRoute from './components/auth/ProtectedRoute'

import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import ForgotPassword from './pages/ForgotPassword'
import ResetPassword from './pages/ResetPassword'
import AuthCallback from './pages/AuthCallback'
import Products from './pages/Products'
import ProductDetail from './pages/ProductDetail'
import Search from './pages/Search'
import Category from './pages/Category'
import Cart from './pages/Cart'
import Wishlist from './pages/Wishlist'
import Compare from './pages/Compare'
import Checkout from './pages/Checkout'
import OrderSuccess from './pages/OrderSuccess'
import Orders from './pages/Orders'
import OrderDetail from './pages/OrderDetail'
import Account from './pages/Account'
import AccountProfile from './pages/AccountProfile'
import AccountAddresses from './pages/AccountAddresses'
import AccountReviews from './pages/AccountReviews'
import AccountSettings from './pages/AccountSettings'

import AdminDashboard from './pages/admin/AdminDashboard'
import AdminProducts from './pages/admin/AdminProducts'
import AdminProductForm from './pages/admin/AdminProductForm'
import AdminCategories from './pages/admin/AdminCategories'
import AdminOrders from './pages/admin/AdminOrders'
import AdminOrderDetail from './pages/admin/AdminOrderDetail'
import AdminUsers from './pages/admin/AdminUsers'
import AdminComments from './pages/admin/AdminComments'
import AdminCoupons from './pages/admin/AdminCoupons'
import AdminReports from './pages/admin/AdminReports'

import NotFound from './pages/NotFound'

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <WishlistProvider>
          <CompareProvider>
            <CartProvider>
              <CheckoutProvider>
                <Routes>
                  {/* Store */}
                  <Route element={<Layout />}>
                    <Route path="/" element={<Home />} />
                    <Route path="/products" element={<Products />} />
                    <Route path="/products/:slug" element={<ProductDetail />} />
                    <Route path="/search" element={<Search />} />
                    <Route path="/category/:slug" element={<Category />} />

                    <Route element={<ProtectedRoute />}>
                      <Route path="/cart" element={<Cart />} />
                      <Route path="/wishlist" element={<Wishlist />} />
                      <Route path="/compare" element={<Compare />} />
                      <Route path="/checkout" element={<Checkout />} />
                      <Route path="/order-success" element={<OrderSuccess />} />
                      <Route path="/orders" element={<Orders />} />
                      <Route path="/orders/:id" element={<OrderDetail />} />
                      <Route path="/account" element={<Account />} />
                      <Route path="/account/profile" element={<AccountProfile />} />
                      <Route path="/account/addresses" element={<AccountAddresses />} />
                      <Route path="/account/reviews" element={<AccountReviews />} />
                      <Route path="/account/settings" element={<AccountSettings />} />
                    </Route>

                    <Route path="*" element={<NotFound />} />
                  </Route>

                  {/* Auth */}
                  <Route path="/login" element={<Login />} />
                  <Route path="/register" element={<Register />} />
                  <Route path="/forgot-password" element={<ForgotPassword />} />
                  <Route path="/reset-password" element={<ResetPassword />} />
                  <Route path="/auth/callback" element={<AuthCallback />} />

                  {/* Admin */}
                  <Route element={<ProtectedRoute requireAdmin />}>
                    <Route path="/admin" element={<AdminDashboard />} />
                    <Route path="/admin/products" element={<AdminProducts />} />
                    <Route path="/admin/products/new" element={<AdminProductForm />} />
                    <Route path="/admin/products/:id/edit" element={<AdminProductForm />} />
                    <Route path="/admin/categories" element={<AdminCategories />} />
                    <Route path="/admin/orders" element={<AdminOrders />} />
                    <Route path="/admin/orders/:id" element={<AdminOrderDetail />} />
                    <Route path="/admin/users" element={<AdminUsers />} />
                    <Route path="/admin/comments" element={<AdminComments />} />
                    <Route path="/admin/coupons" element={<AdminCoupons />} />
                    <Route path="/admin/reports" element={<AdminReports />} />
                  </Route>
                </Routes>
              </CheckoutProvider>
            </CartProvider>
          </CompareProvider>
        </WishlistProvider>
      </AuthProvider>
    </ThemeProvider>
  )
}
