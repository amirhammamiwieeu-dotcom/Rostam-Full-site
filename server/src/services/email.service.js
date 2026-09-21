import { resend, FROM_EMAIL, FROM_NAME } from '../config/resend.js'
import { welcomeEmail } from '../templates/emails/welcome.js'
import { resetPasswordEmail } from '../templates/emails/reset-password.js'
import { verifyEmailTemplate } from '../templates/emails/verify-email.js'

/**
 * Send an email using Resend
 */
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

export const sendWelcomeEmail = async ({ to, name }) => {
  return sendEmail({
    to,
    subject: 'Welcome to MarketHub! 🛒',
    html: welcomeEmail({ name }),
    text: `Welcome to MarketHub, ${name}! Start shopping now.`,
  })
}

export const sendPasswordResetEmail = async ({ to, name, resetLink }) => {
  return sendEmail({
    to,
    subject: 'Reset your MarketHub password',
    html: resetPasswordEmail({ name, resetLink }),
    text: `Reset your password: ${resetLink}`,
  })
}

export const sendVerificationEmail = async ({ to, name, verifyLink }) => {
  return sendEmail({
    to,
    subject: 'Verify your MarketHub email',
    html: verifyEmailTemplate({ name, verifyLink }),
    text: `Verify your email: ${verifyLink}`,
  })
}

export const sendOrderConfirmationEmail = async ({ to, name, order }) => {
  return sendEmail({
    to,
    subject: `Order Confirmed: ${order.order_number}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #FF9900;">Order Confirmed! 🎉</h1>
        <p>Hi ${name},</p>
        <p>Your order <strong>${order.order_number}</strong> has been confirmed.</p>
        <p>Total: <strong>$${Number(order.total).toFixed(2)}</strong></p>
        <p>We'll notify you when it ships.</p>
        <p>Thanks for shopping with MarketHub!</p>
      </div>
    `,
    text: `Order ${order.order_number} confirmed. Total: $${order.total}`,
  })
}

export const sendShippingEmail = async ({ to, name, order }) => {
  return sendEmail({
    to,
    subject: `Your order ${order.order_number} has shipped! 📦`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #FF9900;">Your order is on the way! 🚚</h1>
        <p>Hi ${name},</p>
        <p>Your order <strong>${order.order_number}</strong> has been shipped.</p>
        ${order.tracking_number ? `<p>Tracking: <strong>${order.tracking_number}</strong></p>` : ''}
        <p>Thanks for shopping with MarketHub!</p>
      </div>
    `,
    text: `Order ${order.order_number} shipped.`,
  })
}
