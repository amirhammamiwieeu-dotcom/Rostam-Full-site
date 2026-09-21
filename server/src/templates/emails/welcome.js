export const welcomeEmail = ({ name }) => {
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
              <h2 style="margin: 0 0 20px; color: #131921; font-size: 24px;">Welcome, ${name}! 🎉</h2>
              <p style="margin: 0 0 16px; color: #333333; font-size: 16px; line-height: 1.6;">
                Thanks for joining MarketHub. We're excited to have you on board!
              </p>
              <p style="margin: 0 0 24px; color: #333333; font-size: 16px; line-height: 1.6;">
                Here's what you can do now:
              </p>
              <ul style="margin: 0 0 24px; padding: 0 0 0 20px; color: #333333; font-size: 15px; line-height: 2;">
                <li>🛍️ Browse millions of products</li>
                <li>❤️ Save favorites to your wishlist</li>
                <li>🚚 Get fast, free shipping on orders over $50</li>
                <li>💳 Check out securely with Stripe</li>
              </ul>
              <div style="text-align: center; margin: 32px 0;">
                <a href="${process.env.CLIENT_URL || 'http://localhost:3000'}"
                   style="display: inline-block; background: #FF9900; color: #131921; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 16px;">
                  Start Shopping →
                </a>
              </div>
              <p style="margin: 24px 0 0; color: #666666; font-size: 14px; line-height: 1.6;">
                If you have any questions, reply to this email — we're here to help.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background-color: #131921; padding: 30px; text-align: center;">
              <p style="margin: 0 0 10px; color: #ffffff; font-size: 14px; font-weight: 600;">MarketHub</p>
              <p style="margin: 0 0 10px; color: #999999; font-size: 12px;">Your One-Stop Online Store</p>
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
