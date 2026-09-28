#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

echo "🔧 Changing to Hard Delete..."
echo ""

cp src/services/product.service.js src/services/product.service.js.backup-$(date +%s) 2>/dev/null || true

python3 << 'PYEOF'
import re

with open('src/services/product.service.js', 'r') as f:
    content = f.read()

# New hard-delete function
new_delete = '''export const deleteProduct = async (id) => {
  // 1. Check if product exists
  const { data: existing, error: fetchError } = await supabaseAdmin
    .from('products')
    .select('id, title')
    .eq('id', id)
    .maybeSingle()

  if (fetchError) throw ApiError.badRequest(fetchError.message)
  if (!existing) throw ApiError.notFound('Product not found')

  // 2. Delete related records first (foreign keys)
  // Delete from cart_items (user carts)
  await supabaseAdmin
    .from('cart_items')
    .delete()
    .eq('product_id', id)

  // Delete from wishlists
  await supabaseAdmin
    .from('wishlists')
    .delete()
    .eq('product_id', id)

  // Delete from compares
  await supabaseAdmin
    .from('compares')
    .delete()
    .eq('product_id', id)

  // Delete from product_attributes
  await supabaseAdmin
    .from('product_attributes')
    .delete()
    .eq('product_id', id)

  // Delete from product_variants
  await supabaseAdmin
    .from('product_variants')
    .delete()
    .eq('product_id', id)

  // Delete from comments (reviews)
  await supabaseAdmin
    .from('comments')
    .delete()
    .eq('product_id', id)

  // Delete from review_votes
  await supabaseAdmin
    .from('review_votes')
    .delete()
    .eq('product_id', id)

  // Note: order_items has snapshot data, so we DON'T delete them
  // product_id will be set to NULL automatically via ON DELETE SET NULL

  // 3. Finally, delete the product itself
  const { error: deleteError } = await supabaseAdmin
    .from('products')
    .delete()
    .eq('id', id)

  if (deleteError) throw ApiError.badRequest(deleteError.message)

  console.log(`🗑️  Hard-deleted product: ${existing.title}`)
  return { success: true }
}'''

# Find old deleteProduct and replace
old_pattern = r'export const deleteProduct = async \(id\) => \{[\s\S]*?return \{ success: true \}\n\}'
if re.search(old_pattern, content):
    content = re.sub(old_pattern, new_delete, content)
    print('✅ deleteProduct → Hard Delete')
else:
    print('⚠️  Could not find deleteProduct with regex, trying simpler...')
    # Try simpler pattern
    old_simple = '''export const deleteProduct = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('products')
    .update({ is_active: false, status: 'archived' })
    .eq('id', id)
    .select('id')
    .single()

  if (error) throw ApiError.badRequest(error.message)
  if (!data) throw ApiError.notFound('Product not found')
  return { success: true }
}'''
    if old_simple in content:
        content = content.replace(old_simple, new_delete)
        print('✅ deleteProduct → Hard Delete (simple pattern)')
    else:
        print('❌ Could not find deleteProduct')

with open('src/services/product.service.js', 'w') as f:
    f.write(content)
PYEOF

echo ""
echo "🎉 Done!"
echo ""
echo "📋 Next:"
echo "   1. Restart Backend"
echo "   2. Test Delete"
echo ""
