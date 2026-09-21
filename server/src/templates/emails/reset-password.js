export const resetPasswordEmail = ({ name, resetLink }) => {
  const year = new Date().getFullYear()
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; background-color: #f4f4f4; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;">
  <table role="presentation" style="width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" style="padding: 40px 0;">
        <table role="presentation" style="width: 600px; max-width: 100%; border-collapse: collapse; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
          <tr>
            <td style="background: linear-gradient(135deg, #FF9900 0%, #E68A00 100%); padding: 40px 30px; text-align: center;">
              <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: 900;">🛒 MarketHub</h1>
            </td>
          </tr>
          <tr>
            <td style="padding: 40px 30px;">
              <h2 style="margin: 0 0 20px; color: #131921; font-size: 24px;">Reset your password 🔐</h2>
              <p style="margin: 0 0 16px; color: #333333; font-size: 16px; line-height: 1.6;">
                Hi ${name},
              </p>
              <p style="margin: 0 0 24px; color: #333333; font-size: 16px; line-height: 1.6;">
                We received a request to reset your password. Click the button below to create a new one.
              </p>
              <div style="text-align: center; margin: 32px 0;">
                <a href="${resetLink}"
                   style="display: inline-block; background: #FF9900; color: #131921; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 16px;">
                  Reset Password →
                </a>
              </div>
              <div style="background: #FFF8E5; border-left: 4px solid #FF9900; padding: 16px; border-radius: 4px; margin: 24px 0;">
                <p style="margin: 0; color: #333333; font-size: 14px; line-height: 1.6;">
                  ⚠️ This link will expire in 1 hour. If you didn't request this, you can safely ignore this email.
                </p>
              </div>
              <p style="margin: 24px 0 0; color: #666666; font-size: 13px; line-height: 1.6;">
                For security reasons, we never share your password with anyone.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background-color: #131921; padding: 30px; text-align: center;">
              <p style="margin: 0 0 10px; color: #ffffff; font-size: 14px; font-weight: 600;">MarketHub</p>
              <p style="margin: 0; color: #666666; font-size: 11px;">© ${year} MarketHub. All rights reserved.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim()
}
