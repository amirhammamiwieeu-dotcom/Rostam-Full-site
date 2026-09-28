#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/server"

FILE="src/services/product.service.js"

if grep -q "export const toggleProductActive" "$FILE"; then
  echo "ℹ️  toggleProductActive already exists"
  exit 0
fi

echo "➕ Adding toggleProductActive to product.service.js..."

# Append to end of file
cat >> "$FILE" << 'ENDOFFILE'

// ============================================================
// 🆕 Toggle product active status (admin)
// ============================================================
export const toggleProductActive = async (id) => {
  const { data: product, error: fetchError } = await supabaseAdmin
    .from('products')
    .select('is_active, status')
    .eq('id', id)
    .single()

  if (fetchError || !product) {
    throw ApiError.notFound('Product not found')
  }

  const newIsActive = !product.is_active

  const { data: updated, error } = await supabaseAdmin
    .from('products')
    .update({
      is_active: newIsActive,
      status: newIsActive ? 'published' : 'archived',
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw ApiError.badRequest(error.message)
  return updated
}
ENDOFFILE

echo "✅ toggleProductActive added"
echo ""
echo "📋 Next:"
echo "   1. Backend will auto-restart (nodemon watching)"
echo "   2. Or Ctrl+C → npm run dev"
echo ""
