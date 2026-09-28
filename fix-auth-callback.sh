#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/client"

cp src/pages/AuthCallback.jsx src/pages/AuthCallback.jsx.backup-$(date +%s) 2>/dev/null || true

cat > src/pages/AuthCallback.jsx << 'ENDOFFILE'
import { useEffect, useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { CheckCircle, XCircle, Loader } from 'lucide-react'
import { supabase } from '../lib/supabase'
import Button from '../components/ui/Button'
import Spinner from '../components/ui/Spinner'

export default function AuthCallback() {
  const navigate = useNavigate()
  const [status, setStatus] = useState('checking') // checking | success | error
  const [errorMsg, setErrorMsg] = useState('')

  useEffect(() => {
    let cancelled = false
    let timer

    const process = async () => {
      try {
        // Supabase handles the token automatically from URL hash
        const { data: { session }, error } = await supabase.auth.getSession()

        if (error) throw error

        if (session) {
          localStorage.setItem('token', session.access_token)
          if (!cancelled) setStatus('success')
          timer = setTimeout(() => {
            if (!cancelled) navigate('/account', { replace: true })
          }, 2000)
          return
        }

        // Try again after 1 second (sometimes Supabase needs time)
        timer = setTimeout(async () => {
          if (cancelled) return
          const { data: { session: retry } } = await supabase.auth.getSession()
          if (retry) {
            localStorage.setItem('token', retry.access_token)
            if (!cancelled) setStatus('success')
            timer = setTimeout(() => {
              if (!cancelled) navigate('/account', { replace: true })
            }, 2000)
          } else {
            if (!cancelled) {
              setStatus('error')
              setErrorMsg('Link is invalid or has expired')
            }
          }
        }, 1500)
      } catch (err) {
        console.error(err)
        if (!cancelled) {
          setStatus('error')
          setErrorMsg(err.message || 'Authentication failed')
        }
      }
    }

    process()
    return () => {
      cancelled = true
      if (timer) clearTimeout(timer)
    }
  }, [navigate])

  if (status === 'checking') {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center gap-4">
        <Spinner size="lg" />
        <p className="text-sm text-gray-500">Verifying your email...</p>
      </div>
    )
  }

  if (status === 'success') {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center gap-4 px-4">
        <div className="w-20 h-20 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
          <CheckCircle className="h-12 w-12 text-success" />
        </div>
        <h1 className="text-2xl font-bold text-secondary dark:text-white">
          Email confirmed! 🎉
        </h1>
        <p className="text-sm text-gray-500">Redirecting to your account...</p>
      </div>
    )
  }

  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center gap-4 px-4 text-center">
      <div className="w-20 h-20 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
        <XCircle className="h-12 w-12 text-danger" />
      </div>
      <h1 className="text-2xl font-bold text-secondary dark:text-white">
        Verification failed
      </h1>
      <p className="text-sm text-gray-500 max-w-md">{errorMsg}</p>
      <div className="flex gap-3 flex-wrap justify-center mt-2">
        <Link to="/register">
          <Button>Try signing up again</Button>
        </Link>
        <Link to="/login">
          <Button variant="secondary">Go to login</Button>
        </Link>
      </div>
    </div>
  )
}
ENDOFFILE

echo "✅ AuthCallback.jsx updated"
