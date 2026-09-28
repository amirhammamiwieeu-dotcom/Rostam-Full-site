import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import App from './App'
import './index.css'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { error: null, errorInfo: null }
  }

  componentDidCatch(error, errorInfo) {
    console.error('❌ REACT ERROR:', error)
    console.error('📍 Component Stack:', errorInfo.componentStack)
    this.setState({ error, errorInfo })
  }

  render() {
    if (this.state.error) {
      return (
        <div style={{
          padding: '20px',
          fontFamily: 'monospace',
          background: '#1a1a1a',
          color: '#ff6b6b',
          minHeight: '100vh',
          overflow: 'auto'
        }}>
          <h1 style={{ color: '#ff6b6b', marginBottom: '16px' }}>
            ❌ React Error Caught
          </h1>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Error Message:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '13px',
            overflow: 'auto',
            marginBottom: '16px',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.error.toString()}
          </pre>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Stack Trace:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '12px',
            overflow: 'auto',
            marginBottom: '16px',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.error.stack}
          </pre>
          <h2 style={{ color: '#ffd93d', fontSize: '16px', marginBottom: '12px' }}>
            Component Stack:
          </h2>
          <pre style={{
            background: '#2a2a2a',
            padding: '12px',
            borderRadius: '6px',
            color: '#fff',
            fontSize: '12px',
            overflow: 'auto',
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-all'
          }}>
            {this.state.errorInfo?.componentStack}
          </pre>
        </div>
      )
    }
    return this.props.children
  }
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ErrorBoundary>
      <BrowserRouter>
        <App />
        <Toaster
          position="top-right"
          toastOptions={{
            duration: 3000,
            style: { background: '#131921', color: '#fff', padding: '12px 16px', borderRadius: '8px', fontSize: '14px' },
            success: { iconTheme: { primary: '#00A86B', secondary: '#fff' } },
            error: { iconTheme: { primary: '#CC0C39', secondary: '#fff' } },
          }}
        />
      </BrowserRouter>
    </ErrorBoundary>
  </React.StrictMode>
)
