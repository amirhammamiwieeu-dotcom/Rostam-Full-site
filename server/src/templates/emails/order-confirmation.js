export const orderConfirmationEmail = ({ name, order }) => {
  const year = new Date().getFullYear()
  const itemsHtml = order.items
    .map(
      (item) => `
      <tr>
        <td style="padding: 12px 8px; border-bottom: 1px solid #eee;">
          <img src="${item.image || ''}" style="width: 60px; height: 60px; object-fit: contain; vertical-align: middle; margin-right: 12px; display: inline-block;">
          <span style="display: inline-block; vertical-align: middle; max-width: 300px;">${item.title}</span>
        </td>
        <td style="padding: 12px 8px; border-bottom: 1px solid #eee; text-align: center;">${item.quantity}</td>
        <td style="padding: 12px 8px; border-bottom: 1px solid #eee; text-align: right;">$${Number(item.total).toFixed(2)}</td>
      </tr>
    `
    )
    .join('')

  return `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="margin:0; padding:0; background:#f4f4f4; font-family: -apple-system, Arial, sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
    <tr><td align="center" style="padding: 40px 0;">
      <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="background:#fff; border-radius:12px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,.05);">
        <tr><td style="background:linear-gradient(135deg,#FF9900,#E68A00); padding:32px; text-align:center;">
          <h1 style="margin:0; color:#fff; font-size:26px;">🛒 MarketHub</h1>
        </td></tr>
        <tr><td style="padding:36px 30px;">
          <h2 style="margin:0 0 16px; color:#131921;">Order Confirmed! 🎉</h2>
          <p style="color:#333; font-size:15px;">Hi ${name}, your order <strong>${order.order_number}</strong> is confirmed.</p>
          <table width="100%" style="margin:24px 0; border-collapse:collapse;">
            <thead>
              <tr style="background:#fafafa;">
                <th style="text-align:left; padding:10px 8px; font-size:13px; color:#666;">Item</th>
                <th style="text-align:center; padding:10px 8px; font-size:13px; color:#666;">Qty</th>
                <th style="text-align:right; padding:10px 8px; font-size:13px; color:#666;">Total</th>
              </tr>
            </thead>
            <tbody>${itemsHtml}</tbody>
          </table>
          <table width="100%" style="margin-top:8px;">
            <tr><td style="color:#666; padding:4px 0;">Subtotal</td><td style="text-align:right; color:#333;">$${Number(order.subtotal).toFixed(2)}</td></tr>
            ${order.discount > 0 ? `<tr><td style="color:#00A86B; padding:4px 0;">Discount</td><td style="text-align:right; color:#00A86B;">-$${Number(order.discount).toFixed(2)}</td></tr>` : ''}
            <tr><td style="color:#666; padding:4px 0;">Shipping</td><td style="text-align:right; color:#333;">$${Number(order.shipping_cost || 0).toFixed(2)}</td></tr>
            <tr><td style="color:#666; padding:4px 0;">Tax</td><td style="text-align:right; color:#333;">$${Number(order.tax || 0).toFixed(2)}</td></tr>
            <tr><td style="padding-top:12px; font-weight:bold; font-size:16px;">Total</td><td style="text-align:right; padding-top:12px; font-weight:bold; font-size:16px; color:#FF9900;">$${Number(order.total).toFixed(2)}</td></tr>
          </table>
          <div style="text-align:center; margin:28px 0;">
            <a href="${process.env.CLIENT_URL}/account/orders" style="display:inline-block; background:#FF9900; color:#131921; padding:12px 28px; border-radius:8px; text-decoration:none; font-weight:700;">View Order</a>
          </div>
        </td></tr>
        <tr><td style="background:#131921; padding:24px; text-align:center;">
          <p style="margin:0; color:#999; font-size:12px;">© ${year} MarketHub. All rights reserved.</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
  `.trim()
}