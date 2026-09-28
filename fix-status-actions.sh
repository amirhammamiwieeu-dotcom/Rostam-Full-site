#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

FILE="src/pages/admin/AdminProducts.jsx"

echo "🔧 Fixing Status + Actions columns..."
echo ""

cp "$FILE" "$FILE.backup-$(date +%s)"
echo "✅ Backup created"
echo ""

python3 << 'PYEOF'
with open('src/pages/admin/AdminProducts.jsx', 'r') as f:
    content = f.read()

# ============================================================
# 1. جایگزینی Status column کامل
# ============================================================
old_status = '''    {
      header: 'Status',
      cell: (p) => {
        // Determine status based on multiple factors
        const isActive = p.is_active !== false
        const isPublished = !p.status || p.status === 'published'

        if (!isActive) {
          return (
            <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300">
              <EyeOff className="h-3 w-3" />
              Hidden
            </span>
          )
        }

        if (!isPublished) {
          return (
            <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
              {p.status || 'Draft'}
            </span>
          )
        }

        return (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300">
            <Eye className="h-3 w-3" />
            Active
          </span>
        )
      },
    },'''

new_status = '''    {
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

if old_status in content:
    content = content.replace(old_status, new_status)
    print('✅ Status column replaced')
else:
    print('⚠️  Status column not found — trying alternative...')
    # Try simpler approach: find and replace just the Status block
    import re
    pattern = r"\{\s*header:\s*'Status',[\s\S]*?^\s*\},"
    match = re.search(pattern, content, re.MULTILINE)
    if match:
        content = content[:match.start()] + new_status + content[match.end():]
        print('✅ Status column replaced (regex)')
    else:
        print('❌ Still could not find Status column')

# ============================================================
# 2. جایگزینی Actions column کامل
# ============================================================
old_actions = '''    {
      header: 'Actions',
      className: 'text-right',
      cell: (p) => (
        <div className="flex items-center justify-end gap-2">
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
      ),
    },'''

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

if old_actions in content:
    content = content.replace(old_actions, new_actions)
    print('✅ Actions column replaced')
else:
    print('⚠️  Actions column not found — trying alternative...')
    import re
    pattern = r"\{\s*header:\s*'Actions',[\s\S]*?^\s*\},"
    match = re.search(pattern, content, re.MULTILINE)
    if match:
        content = content[:match.start()] + new_actions + content[match.end():]
        print('✅ Actions column replaced (regex)')
    else:
        print('❌ Still could not find Actions column')

with open('src/pages/admin/AdminProducts.jsx', 'w') as f:
    f.write(content)
PYEOF

echo ""
echo "🎉 Done!"
echo ""
echo "📋 Next:"
echo "   1. Ctrl+C in Frontend terminal"
echo "   2. cd ~/Rostam-Full-site/client"
echo "   3. npm run dev"
echo ""
