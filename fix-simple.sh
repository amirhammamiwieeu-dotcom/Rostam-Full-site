#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

echo "🔧 Making App.jsx and main.jsx super simple..."
echo ""

# Backup
cp src/App.jsx src/App.jsx.backup-$(date +%s) 2>/dev/null || true
cp src/main.jsx src/main.jsx.backup-$(date +%s) 2>/dev/null || true
echo "✅ Backups created"
echo ""

# ============================================================
# App.jsx — ساده
# ============================================================
cat > src/App.jsx << 'ENDOFFILE'
export default function App() {
  return (
    <h1 style={{ color: 'red', fontSize: '40px', padding: '50px' }}>
      HELLO MARKET
    </h1>
  )
}
ENDOFFILE

echo "✅ App.jsx simplified"
echo ""

# ============================================================
# main.jsx — ساده
# ============================================================
cat > src/main.jsx << 'ENDOFFILE'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

console.log('🚀 main.jsx loaded')

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
ENDOFFILE

echo "✅ main.jsx simplified"
echo ""
echo "🎉 Done!"
echo ""
echo "📋 Next:"
echo "   cd ~/Rostam-Full-site/client"
echo "   pkill -f vite"
echo "   rm -rf node_modules/.vite"
echo "   npm run dev"
echo ""
echo "🎯 Then open: http://localhost:3000/"
echo "   You should see a RED 'HELLO MARKET' text"
echo ""
