import React, { useState, useEffect } from 'react'
import './App.css'

const API_URL = window.location.origin

function App() {
  const [isRunning, setIsRunning] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  // Prüfe Status beim Laden
  useEffect(() => {
    checkStatus()
    // Prüfe Status alle 2 Sekunden
    const interval = setInterval(checkStatus, 2000)
    return () => clearInterval(interval)
  }, [])

  const checkStatus = async () => {
    try {
      const response = await fetch(`${API_URL}/api/status`)
      const data = await response.json()
      setIsRunning(data.running)
    } catch (err) {
      console.error('Fehler beim Status-Check:', err)
    }
  }

  const handleToggle = async () => {
    setLoading(true)
    setError(null)

    try {
      const endpoint = isRunning ? '/api/stop' : '/api/start'
      const response = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Fehler beim Senden der Anfrage')
      }

      setIsRunning(!isRunning)
    } catch (err) {
      setError(err.message)
      console.error('Fehler:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app">
      <div className="container">
        <h1 className="title">🔌 Relais Steuerung</h1>
        <p className="subtitle">8-Kanal Relais Modul</p>

        <div className="status-container">
          <div className={`status-indicator ${isRunning ? 'running' : 'stopped'}`}>
            <div className="status-dot"></div>
            <span className="status-text">
              {isRunning ? 'Läuft' : 'Gestoppt'}
            </span>
          </div>
        </div>

        {error && (
          <div className="error-message">
            ⚠️ {error}
          </div>
        )}

        <button
          className={`control-button ${isRunning ? 'stop' : 'start'}`}
          onClick={handleToggle}
          disabled={loading}
        >
          {loading ? (
            <span className="loading">⏳ Warte...</span>
          ) : isRunning ? (
            <>
              <span className="button-icon">⏹️</span>
              <span className="button-text">Stop</span>
            </>
          ) : (
            <>
              <span className="button-icon">▶️</span>
              <span className="button-text">Start</span>
            </>
          )}
        </button>

        <div className="info">
          <p>📱 Von jedem Gerät im Netzwerk erreichbar</p>
          <p className="ip-info">IP: {window.location.hostname}</p>
        </div>
      </div>
    </div>
  )
}

export default App

