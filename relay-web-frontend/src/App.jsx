import React, { useState, useEffect } from 'react'
import './App.css'

const API_URL = window.location.origin

function App() {
  const [isRunning, setIsRunning] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [serverRunning, setServerRunning] = useState(false)
  const [serverInstalled, setServerInstalled] = useState(false)
  const [serverLoading, setServerLoading] = useState(false)
  const [serverError, setServerError] = useState(null)
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
      if (data.server) {
        setServerRunning(data.server.running || false)
        setServerInstalled(data.server.installed || false)
      }
      if (data.channels && Array.isArray(data.channels)) {
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
    } catch (err) {
      setError(err.message)
      console.error('Fehler:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleServerToggle = async () => {
    // Nur Start erlauben, nicht Stop (sonst ist Webseite nicht mehr erreichbar)
    if (serverRunning) {
      setServerError('Der Server kann nicht über die Webseite gestoppt werden, da sonst die Webseite nicht mehr erreichbar wäre.')
      return
    }

    setServerLoading(true)
    setServerError(null)

    try {
      const response = await fetch(`${API_URL}/api/server/start`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Fehler beim Senden der Anfrage')
      }

      // Warte kurz und prüfe dann den Status
      setTimeout(() => {
        checkStatus()
      }, 1000)
    } catch (err) {
      setServerError(err.message)
      console.error('Fehler:', err)
    } finally {
      setServerLoading(false)
    }
  }

  const handleChannelToggle = async (channelIndex) => {
    // Wenn Sequenz läuft, kann kein einzelner Kanal gesteuert werden
    if (isRunning) {
      setError('Sequenz läuft. Bitte zuerst stoppen, um einzelne Kanäle zu steuern.')
      return
    }

    setChannelLoading({ ...channelLoading, [channelIndex]: true })
    setError(null)

    try {
      const response = await fetch(`${API_URL}/api/channel/${channelIndex}/toggle`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Fehler beim Senden der Anfrage')
      }

      // Aktualisiere Status
      const newChannels = [...channels]
      newChannels[channelIndex] = data.state
      setChannels(newChannels)
    } catch (err) {
      setError(err.message)
      console.error('Fehler:', err)
    } finally {
      setChannelLoading({ ...channelLoading, [channelIndex]: false })
    }
  }

  const handleAllChannelsOff = async () => {
    if (isRunning) {
      setError('Sequenz läuft. Bitte zuerst stoppen.')
      return
    }

    setLoading(true)
    setError(null)

    try {
      const response = await fetch(`${API_URL}/api/channels/all/off`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Fehler beim Senden der Anfrage')
      }

      // Aktualisiere Status
      setChannels([false, false, false, false, false, false, false, false])
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
              <span className="button-text">Sequenz stoppen</span>
            </>
          ) : (
            <>
              <span className="button-icon">▶️</span>
              <span className="button-text">Sequenz starten</span>
            </>
          )}
        </button>

        {/* Einzelne Kanäle */}
        <div className="channels-section">
          <h2 className="channels-title">🔌 Einzelne Kanäle</h2>
          <p className="channels-subtitle">Steuere jeden Kanal einzeln (nur wenn Sequenz gestoppt ist)</p>
          
          <div className="channels-grid">
            {channels.map((state, index) => (
              <div key={index} className={`channel-card ${state ? 'active' : 'inactive'}`}>
                <div className="channel-header">
                  <span className="channel-number">Kanal {index + 1}</span>
                  <div className={`channel-status ${state ? 'on' : 'off'}`}>
                    <div className="channel-status-dot"></div>
                    <span>{state ? 'EIN' : 'AUS'}</span>
                  </div>
                </div>
                <button
                  className={`channel-button ${state ? 'on' : 'off'}`}
                  onClick={() => handleChannelToggle(index)}
                  disabled={isRunning || channelLoading[index]}
                >
                  {channelLoading[index] ? (
                    '⏳'
                  ) : state ? (
                    '🔴 AUS'
                  ) : (
                    '🟢 EIN'
                  )}
                </button>
              </div>
            ))}
          </div>

          <button
            className="control-button all-off-button"
            onClick={handleAllChannelsOff}
            disabled={isRunning || loading}
          >
            {loading ? (
              <span className="loading">⏳ Warte...</span>
            ) : (
              <>
                <span className="button-icon">🔌</span>
                <span className="button-text">Alle Kanäle ausschalten</span>
              </>
            )}
          </button>
        </div>

        {/* Server-Steuerung */}
        <div className="server-section">
          <h2 className="server-title">🖥️ Server Steuerung</h2>
          
          {serverInstalled ? (
            <>
              <div className="status-container">
                <div className={`status-indicator ${serverRunning ? 'running' : 'stopped'}`}>
                  <div className="status-dot"></div>
                  <span className="status-text">
                    {serverRunning ? 'Server läuft' : 'Server gestoppt'}
                  </span>
                </div>
              </div>

              {serverError && (
                <div className="error-message">
                  ⚠️ {serverError}
                </div>
              )}

              {!serverRunning && (
                <button
                  className="control-button server-button start"
                  onClick={handleServerToggle}
                  disabled={serverLoading}
                >
                  {serverLoading ? (
                    <span className="loading">⏳ Warte...</span>
                  ) : (
                    <>
                      <span className="button-icon">▶️</span>
                      <span className="button-text">Server starten</span>
                    </>
                  )}
                </button>
              )}

              {serverRunning && (
                <div className="info-message">
                  <p>ℹ️ Server läuft</p>
                  <p className="info-small">Der Server kann nicht über die Webseite gestoppt werden, da sonst die Webseite nicht mehr erreichbar wäre.</p>
                  <p className="info-small">Zum Stoppen: ssh adam@raspberrypi.local "sudo systemctl stop relay-web.service"</p>
                </div>
              )}
            </>
          ) : (
            <div className="info-message">
              <p>ℹ️ Server-Service ist nicht installiert</p>
              <p className="info-small">Installiere den Service mit: ./install-relay-service.sh</p>
            </div>
          )}
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

