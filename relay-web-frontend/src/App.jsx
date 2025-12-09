import React, { useState, useEffect } from 'react'
import './App.css'

const API_URL = window.location.origin

function App() {
  const [isRunning, setIsRunning] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [channels, setChannels] = useState([false, false, false, false, false, false, false, false])
  const [channelLoading, setChannelLoading] = useState({})

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
      if (data.channels) {
        setChannels(data.channels)
      }
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
      // Aktualisiere Status nach Toggle
      setTimeout(checkStatus, 500)
    } catch (err) {
      setError(err.message)
      console.error('Fehler:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleChannelToggle = async (channel) => {
    if (isRunning) {
      setError('Automatische Sequenz läuft. Bitte zuerst stoppen.')
      return
    }

    setChannelLoading({ ...channelLoading, [channel]: true })
    setError(null)

    try {
      const response = await fetch(`${API_URL}/api/channels/${channel}/toggle`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Fehler beim Umschalten')
      }

      // Aktualisiere Status
      setChannels(prev => {
        const newChannels = [...prev]
        newChannels[channel - 1] = data.status === 'on'
        return newChannels
      })
    } catch (err) {
      setError(err.message)
      console.error('Fehler:', err)
    } finally {
      setChannelLoading({ ...channelLoading, [channel]: false })
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
              <span className="button-text">Stop Sequenz</span>
            </>
          ) : (
            <>
              <span className="button-icon">▶️</span>
              <span className="button-text">Start Sequenz</span>
            </>
          )}
        </button>

        <div className="channels-section">
          <h2 className="channels-title">Einzelne Kanäle</h2>
          <p className="channels-subtitle">
            {isRunning ? '⚠️ Automatische Sequenz läuft - Kanäle gesperrt' : 'Klicke auf einen Kanal zum Ein-/Ausschalten'}
          </p>
          <div className="channels-grid">
            {[1, 2, 3, 4, 5, 6, 7, 8].map((channel) => {
              const isOn = channels[channel - 1]
              const isLoading = channelLoading[channel]
              return (
                <button
                  key={channel}
                  className={`channel-button ${isOn ? 'on' : 'off'} ${isRunning ? 'disabled' : ''}`}
                  onClick={() => handleChannelToggle(channel)}
                  disabled={isRunning || isLoading}
                  title={`Kanal ${channel} ${isOn ? 'ausschalten' : 'einschalten'}`}
                >
                  <div className="channel-number">{channel}</div>
                  <div className={`channel-status ${isOn ? 'active' : ''}`}>
                    {isLoading ? '⏳' : isOn ? '⚡' : '○'}
                  </div>
                  <div className="channel-label">{isOn ? 'EIN' : 'AUS'}</div>
                </button>
              )
            })}
          </div>
        </div>

        <div className="info">
          <p>📱 Von jedem Gerät im Netzwerk erreichbar</p>
          <p className="ip-info">IP: {window.location.hostname}</p>
        </div>
      </div>
    </div>
  )
}

export default App

