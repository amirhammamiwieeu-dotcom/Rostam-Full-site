import { resend, FROM_EMAIL, FROM_NAME } from '../config/resend.js'
import { welcomeEmail } from '../templates/emails/welcome.js'
import { resetPasswordEmail } from '../templates/emails/reset-password.js'
import { verifyEmailTemplate } from '../templates/emails/verify-email.js'
import { orderConfirmationEmail } from '../templates/emails/order-confirmation.js'
import { orderShippedEmail } from '../templates/emails/order-shipped.js'

export const sendEmail = async ({ to, subject, html, text, replyTo }) => {
  try {
    const { data, error } = await resend.emails.send({
      from: `${FROM_NAME} <${FROM_EMAIL}>`,
      to,
      subject,
      html,
      ...(text && { text }),
      ...(replyTo && { replyTo }),
    })
    if (error) {
      console.error('❌ Email send failed:', error)
      return { success: false, error: error.message }
    }
    console.log(`📧 Email sent to ${to}: ${data.id}`)
    return { success: true, id: data.id }
  } catch (err) {
    console.error('❌ Email send error:', err)
    return { success: false, error: err.message }
  }
}

export const sendWelcomeEmail = ({ to, name }) =>
  sendEmail({
    to,
    subject: 'Welcome to MarketHub! 🛒',
    html: welcomeEmail({ name }),
  })

export const sendPasswordResetEmail = ({ to, name, resetLink }) =>
  sendEmail({
    to,
    subject: 'Reset your MarketHub password',
    html: resetPasswordEmail({ name, resetLink }),
  })

export const sendVerificationEmail = ({ to, name, verifyLink }) =>
  sendEmail({
    to,
    subject: 'Verify your MarketHub email',
    html: verifyEmailTemplate({ name, verifyLink }),
  })

export const sendOrderConfirmationEmail = ({ to, name, order }) =>
  sendEmail({
    to,
    subject: `Order Confirmed: ${order.order_number}`,
    html: orderConfirmationEmail({ name, order }),
  })

export const sendShippingEmail = ({ to, name, order }) =>
  sendEmail({
    to,
    subject: `Your order ${order.order_number} has shipped! 📦`,
    html: orderShippedEmail({ name, order }),
  })