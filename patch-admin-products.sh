#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

FILE="src/pages/admin/AdminProducts.jsx"

echo "🔧 Patching AdminProducts.jsx..."
echo ""

# Backup
cp "$FILE" "$FILE.backup-$(date +%s)"
echo "✅ Backup created"
echo ""

# ============================================================
# 1. اضافه کردن imports (useMemo + icons)
# ============================================================
if ! grep -q "useMemo" "$FILE"; then
  sed -i "s/import { useEffect, useState } from 'react'/import { useEffect, useState, useMemo } from 'react'/" "$FILE"
  echo "✅ useMemo imported"
fi

if ! grep -q "CheckCircle2" "$FILE"; then
  sed -i "s/import { Plus, Pencil, Trash2, Search, Eye, EyeOff } from 'lucide-react'/import { Plus, Pencil, Trash2, Search, Eye, EyeOff, CheckCircle2, XCircle } from 'lucide-react'/" "$FILE"
  echo "✅ Icons imported"
fi

# ============================================================
# 2. اضافه کردن FILTERS constant
# ============================================================
if ! grep -q "const FILTERS" "$FILE"; then
  # اضافه کردن بعد از imports (قبل از export default)
  sed -i "s|export default function AdminProducts() {|const FILTERS = [\n  { value: 'all', label: 'All' },\n  { value: 'active', label: 'Active' },\n  { value: 'inactive', label: 'Inactive' },\n]\n\nexport default function AdminProducts() {|" "$FILE"
  echo "✅ FILTERS constant added"
fi

# ============================================================
# 3. اضافه کردن state برای filter و toggling
# ============================================================
if ! grep -q "const \[filter, setFilter\]" "$FILE"; then
  sed -i "s|const \[search, setSearch\] = useState('')|const [search, setSearch] = useState('')\n  const [filter, setFilter] = useState('all')\n  const [toggling, setToggling] = useState(null)|" "$FILE"
  echo "✅ filter + toggling states added"
fi

# ============================================================
# 4. اضافه کردن handleToggle بعد از handleDelete
# ============================================================
if ! grep -q "handleToggle" "$FILE"; then
  # پیدا کردن آخر handleDelete و اضافه کردن بعدش
  python3 << 'PYEOF'
import re

with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

handle_toggle = '''
  const handleToggle = async (product) => {
    setToggling(product.id)
    try {
      const res = await api.patch(`/products/${product.id}/toggle-active`)
      const updated = res.data.product
      setProducts((prev) =>
        prev.map((p) => (p.id === updated.id ? { ...p, ...updated } : p))
      )
      toast.success(
        updated.is_active ? '✅ Product activated' : '🚫 Product deactivated'
      )
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Failed to toggle')
    } finally {
      setToggling(null)
    }
  }
'''

# پیدا کردن آخر handleDelete
pattern = r"(const handleDelete = async \(\) => \{.*?\n  \})"
match = re.search(pattern, content, re.DOTALL)
if match and 'handleToggle' not in content:
    insert_pos = match.end()
    content = content[:insert_pos] + '\n' + handle_toggle + content[insert_pos:]
    with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
        f.write(content)
    print('✅ handleToggle added')
else:
    print('ℹ️  handleToggle already exists or handleDelete not found')
PYEOF
fi

# ============================================================
# 5. جایگزینی filtered با useMemo
# ============================================================
if ! grep -q "const filtered = useMemo" "$FILE"; then
  python3 << 'PYEOF'
import re

with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

new_filtered = '''  const filtered = useMemo(() => {
    let items = products

    if (filter === 'active') items = items.filter((p) => p.is_active !== false)
    if (filter === 'inactive') items = items.filter((p) => p.is_active === false)

    if (search.trim()) {
      const q = search.toLowerCase()
      items = items.filter(
        (p) =>
          p.title.toLowerCase().includes(q) ||
          (p.brand?.name || '').toLowerCase().includes(q)
      )
    }

    return items
  }, [products, filter, search])

  const counts = useMemo(
    () => ({
      all: products.length,
      active: products.filter((p) => p.is_active !== false).length,
      inactive: products.filter((p) => p.is_active === false).length,
    }),
    [products]
  )
'''

# پیدا کردن filtered قدیمی
pattern = r"const filtered = search\s*\n\s*\? products\.filter.*?\n\s*: products"
match = re.search(pattern, content, re.DOTALL)

if match:
    content = content[:match.start()] + new_filtered + content[match.end():]
    with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
        f.write(content)
    print('✅ filtered + counts replaced with useMemo')
else:
    print('⚠️  Could not find old filtered')
PYEOF
fi

# ============================================================
# 6. جایگزینی Status column
# ============================================================
if ! grep -q "CheckCircle2 className" "$FILE"; then
  python3 << 'PYEOF'
import re

with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

new_status_col = '''    {
      header: 'Status',
      cell: (p) => {
        const isActive = p.is_active !== false
        return isActive ? (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300">
            <CheckCircle2 className="h-3 w-3" />
            Active
          </span>
        ) : (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300">
            <XCircle className="h-3 w-3" />
            Inactive
          </span>
        )
      },
    },'''

# پیدا کردن Status column قدیمی
pattern = r"\{\s*header:\s*'Status',\s*cell:\s*\(p\)\s*=>\s*\([^)]*?p\.is_active.*?\n\s*\},"
match = re.search(pattern, content, re.DOTALL)

if match:
    content = content[:match.start()] + new_status_col + content[match.end():]
    with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
        f.write(content)
    print('✅ Status column updated with badge')
else:
    print('⚠️  Could not find Status column')
PYEOF
fi

# ============================================================
# 7. جایگزینی Actions column با toggle button
# ============================================================
if ! grep -q "handleToggle(p)" "$FILE"; then
  python3 << 'PYEOF'
import re

with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

new_actions = '''    {
      header: 'Actions',
      className: 'text-right',
      cell: (p) => {
        const isActive = p.is_active !== false
        return (
          <div className="flex items-center justify-end gap-1.5">
            <button
              onClick={() => handleToggle(p)}
              disabled={toggling === p.id}
              className={`p-1.5 rounded transition ${
                isActive
                  ? 'text-yellow-600 hover:bg-yellow-50 dark:hover:bg-yellow-900/20'
                  : 'text-success hover:bg-green-50 dark:hover:bg-green-900/20'
              } disabled:opacity-50`}
              title={isActive ? 'Deactivate' : 'Activate'}
            >
              {toggling === p.id ? (
                <div className="h-4 w-4 border-2 border-current border-t-transparent rounded-full animate-spin" />
              ) : isActive ? (
                <EyeOff className="h-4 w-4" />
              ) : (
                <Eye className="h-4 w-4" />
              )}
            </button>
            <button
              onClick={() => navigate(`/admin/products/${p.id}/edit`)}
              className="p-1.5 text-link hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded transition"
              title="Edit"
            >
              <Pencil className="h-4 w-4" />
            </button>
            <button
              onClick={() => setConfirm({ open: true, product: p })}
              className="p-1.5 text-danger hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition"
              title="Delete"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        )
      },
    },'''

# پیدا کردن Actions column قدیمی
pattern = r"\{\s*header:\s*'Actions',[\s\S]*?<\/div>\s*\)\s*\},\s*\n\s*\]"
match = re.search(pattern, content)

if match:
    content = content[:match.start()] + new_actions + "\n  ]" + content[match.end():]
    with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
        f.write(content)
    print('✅ Actions column updated with toggle button')
else:
    print('⚠️  Could not find Actions column')
PYEOF
fi

# ============================================================
# 8. جایگزینی Toolbar با Search + Filter
# ============================================================
if ! grep -q "FILTERS.map" "$FILE"; then
  python3 << 'PYEOF'
import re

with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

new_toolbar = '''      {/* Toolbar: Search + Filter */}
      <div className="flex flex-wrap items-center gap-3 mb-4">
        <div className="relative flex-1 min-w-[200px] max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search products..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-secondary-light text-sm text-secondary dark:text-white outline-none focus:border-primary"
          />
        </div>

        <div className="flex items-center gap-1 bg-white dark:bg-secondary-light rounded-lg p-1 border border-gray-200 dark:border-gray-700">
          {FILTERS.map((f) => (
            <button
              key={f.value}
              onClick={() => setFilter(f.value)}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition ${
                filter === f.value
                  ? 'bg-primary text-secondary'
                  : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-secondary'
              }`}
            >
              {f.label}
              {counts[f.value] > 0 && (
                <span
                  className={`ml-1.5 px-1.5 py-0.5 rounded-full text-[10px] ${
                    filter === f.value
                      ? 'bg-secondary/20'
                      : 'bg-gray-100 dark:bg-secondary'
                  }`}
                >
                  {counts[f.value]}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>
'''

# پیدا کردن Toolbar قدیمی (search only)
pattern = r"<div className=\"mb-4\">\s*<div className=\"relative max-w-md\">[\s\S]*?</div>\s*</div>"
match = re.search(pattern, content)

if match:
    content = content[:match.start()] + new_toolbar + content[match.end():]
    with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
        f.write(content)
    print('✅ Toolbar updated with filter tabs')
else:
    print('⚠️  Could not find toolbar')
PYEOF
fi

echo ""
echo "🎉 Frontend patched!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Frontend terminal"
echo "   2. cd ~/Rostam-Full-site/client"
echo "   3. npm run dev"
echo ""
