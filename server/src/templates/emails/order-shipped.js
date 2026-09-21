export const orderShippedEmail = ({ name, order }) => {
  const year = new Date().getFullYear()
  return `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="margin:0; padding:0; background:#f4f4f4; font-family: -apple-system, Arial, sans-serif;">
  <table role="presentation" width="100%"><tr><td align="center" style="padding:40px 0;">
    <table role="presentation" width="600" style="background:#fff; border-radius:12px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,.05);">
      <tr><td style="background:linear-gradient(135deg,#FF9900,#E68A00); padding:32px; text-align:center;">
        <h1 style="margin:0; color:#fff; font-size:26px;">🛒 MarketHub</h1>
      </td></tr>
      <tr><td style="padding:36px 30px;">
        <h2 style="margin:0 0 16px; color:#131921;">Your order is on the way! 🚚</h2>
        <p style="color:#333; font-size:15px;">Hi ${name}, your order <strong>${order.order_number}</strong> has been shipped.</p>
        ${order.tracking_number ? `<div style="background:#FFF8E5; border-left:4px solid #FF9900; padding:14px; border-radius:4px; margin:20px 0;"><strong>Tracking:</strong> ${order.tracking_number}</div>` : ''}
        <div style="text-align:center; margin:28px 0;">
          <a href="${process.env.CLIENT_URL}/account/orders" style="display:inline-block; background:#FF9900; color:#131921; padding:12px 28px; border-radius:8px; text-decoration:none; font-weight:700;">Track Order</a>
        </div>
      </td></tr>
      <tr><td style="background:#131921; padding:24px; text-align:center;">
        <p style="margin:0; color:#999; font-size:12px;">© ${year} MarketHub. All rights reserved.</p>
      </td></tr>
    </table>
  </td></tr></table>
</body>
</html>
  `.trim()
}