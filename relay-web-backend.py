#!/usr/bin/env python3
"""
Flask Backend für Relais-Steuerung
Läuft auf dem Raspberry Pi
"""
from flask import Flask, jsonify, send_from_directory, request
from flask_cors import CORS
from gpiozero import OutputDevice
import threading
import time
import subprocess
import os

app = Flask(__name__, static_folder='build', static_url_path='')
CORS(app)

# GPIO-Pins für 8-Kanal-Relais
gpioList = [26, 19, 13, 6, 12, 16, 20, 21]
relays = [OutputDevice(pin, active_high=False) for pin in gpioList]

# Globale Variable für Relais-Status
relay_running = False
relay_thread = None
# Status für einzelne Kanäle (True = ein, False = aus)
channel_states = [False] * 8

def relay_loop():
    """Hauptschleife für Relais-Steuerung"""
    global relay_running
    sleepTimeShort = 0.2
    sleepTimeLong = 0.1
    
    while relay_running:
        for relay in relays:
            if not relay_running:
                break
            relay.on()   # Relais ein
            time.sleep(sleepTimeShort)
            relay.off()  # Relais aus
            time.sleep(sleepTimeLong)
    
    # Alle Relais ausschalten beim Stoppen
    for relay in relays:
        relay.off()

def check_server_status():
    """Prüft ob der systemd Service läuft"""
    try:
        # Prüfe ob Service-Datei existiert (versuche mit sudo falls nötig)
        service_exists = os.path.exists('/etc/systemd/system/relay-web.service')
        
        if not service_exists:
            # Versuche mit sudo zu prüfen
            result = subprocess.run(
                ['sudo', 'test', '-f', '/etc/systemd/system/relay-web.service'],
                capture_output=True,
                text=True,
                timeout=2
            )
            service_exists = result.returncode == 0
        
        if not service_exists:
            return {'installed': False, 'running': False}
        
        # Prüfe Service-Status (versuche zuerst ohne sudo, dann mit sudo)
        result = subprocess.run(
            ['systemctl', 'is-active', 'relay-web.service'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        if result.returncode != 0:
            # Versuche mit sudo
            result = subprocess.run(
                ['sudo', 'systemctl', 'is-active', 'relay-web.service'],
                capture_output=True,
                text=True,
                timeout=2
            )
        
        is_running = result.returncode == 0 and result.stdout.strip() == 'active'
        
        return {
            'installed': True,
            'running': is_running
        }
    except Exception as e:
        # Fallback: Wenn Prüfung fehlschlägt, aber Service-Datei existiert, 
        # nehmen wir an dass er installiert ist
        try:
            if os.path.exists('/etc/systemd/system/relay-web.service'):
                return {
                    'installed': True,
                    'running': None  # Unbekannt
                }
        except:
            pass
        
        return {
            'installed': False,
            'running': False,
            'error': str(e)
        }

@app.route('/api/status', methods=['GET'])
def get_status():
    """Gibt den aktuellen Status zurück"""
    server_status = check_server_status()
    return jsonify({
        'running': relay_running,
        'relays': len(relays),
        'server': server_status,
        'channels': channel_states
    })

@app.route('/api/start', methods=['POST'])
def start_relay():
    """Startet die Relais-Sequenz"""
    global relay_running, relay_thread
    
    if relay_running:
        return jsonify({'error': 'Relais läuft bereits'}), 400
    
    relay_running = True
    relay_thread = threading.Thread(target=relay_loop, daemon=True)
    relay_thread.start()
    
    return jsonify({
        'status': 'started',
        'message': 'Relais gestartet'
    })

@app.route('/api/stop', methods=['POST'])
def stop_relay():
    """Stoppt die Relais-Sequenz"""
    global relay_running
    
    if not relay_running:
        return jsonify({'error': 'Relais läuft nicht'}), 400
    
    relay_running = False
    
    # Warte kurz bis Thread beendet ist
    if relay_thread:
        relay_thread.join(timeout=1.0)
    
    return jsonify({
        'status': 'stopped',
        'message': 'Relais gestoppt'
    })

@app.route('/api/channel/<int:channel>/toggle', methods=['POST'])
def toggle_channel(channel):
    """Schaltet einen einzelnen Kanal ein oder aus"""
    global channel_states
    
    if channel < 0 or channel >= len(relays):
        return jsonify({'error': f'Ungültiger Kanal. Verfügbar: 0-{len(relays)-1}'}), 400
    
    # Wenn die Sequenz läuft, kann kein einzelner Kanal gesteuert werden
    if relay_running:
        return jsonify({'error': 'Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    # Toggle Kanal-Status
    channel_states[channel] = not channel_states[channel]
    
    # Setze GPIO entsprechend
    if channel_states[channel]:
        relays[channel].on()
    else:
        relays[channel].off()
    
    return jsonify({
        'status': 'success',
        'channel': channel,
        'state': channel_states[channel],
        'message': f'Kanal {channel + 1} {"eingeschaltet" if channel_states[channel] else "ausgeschaltet"}'
    })

@app.route('/api/channel/<int:channel>/set', methods=['POST'])
def set_channel(channel):
    """Setzt einen einzelnen Kanal auf ein oder aus"""
    global channel_states
    
    if channel < 0 or channel >= len(relays):
        return jsonify({'error': f'Ungültiger Kanal. Verfügbar: 0-{len(relays)-1}'}), 400
    
    # Wenn die Sequenz läuft, kann kein einzelner Kanal gesteuert werden
    if relay_running:
        return jsonify({'error': 'Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    # Hole gewünschten Status aus Request
    data = request.get_json() or {}
    state = data.get('state', True)
    
    # Setze Kanal-Status
    channel_states[channel] = bool(state)
    
    # Setze GPIO entsprechend
    if channel_states[channel]:
        relays[channel].on()
    else:
        relays[channel].off()
    
    return jsonify({
        'status': 'success',
        'channel': channel,
        'state': channel_states[channel],
        'message': f'Kanal {channel + 1} {"eingeschaltet" if channel_states[channel] else "ausgeschaltet"}'
    })

@app.route('/api/channels/all/off', methods=['POST'])
def all_channels_off():
    """Schaltet alle Kanäle aus"""
    global channel_states
    
    # Wenn die Sequenz läuft, kann nicht gesteuert werden
    if relay_running:
        return jsonify({'error': 'Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    # Schalte alle Kanäle aus
    for i in range(len(relays)):
        channel_states[i] = False
        relays[i].off()
    
    return jsonify({
        'status': 'success',
        'message': 'Alle Kanäle ausgeschaltet'
    })

@app.route('/api/server/status', methods=['GET'])
def get_server_status():
    """Gibt den Status des systemd Services zurück"""
    status = check_server_status()
    return jsonify(status)

@app.route('/api/server/start', methods=['POST'])
def start_server():
    """Startet den systemd Service"""
    try:
        # Versuche ohne sudo zuerst
        result = subprocess.run(
            ['systemctl', 'start', 'relay-web.service'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode != 0:
            # Falls ohne sudo fehlgeschlagen, versuche mit sudo
            result = subprocess.run(
                ['sudo', 'systemctl', 'start', 'relay-web.service'],
                capture_output=True,
                text=True,
                timeout=5
            )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'started',
                'message': 'Server gestartet'
            })
        else:
            return jsonify({
                'error': f'Fehler beim Starten: {result.stderr}'
            }), 500
            
    except subprocess.TimeoutExpired:
        return jsonify({
            'error': 'Timeout beim Starten des Servers'
        }), 500
    except Exception as e:
        return jsonify({
            'error': f'Fehler: {str(e)}'
        }), 500

@app.route('/api/server/stop', methods=['POST'])
def stop_server():
    """Stoppt den systemd Service"""
    try:
        # Versuche ohne sudo zuerst
        result = subprocess.run(
            ['systemctl', 'stop', 'relay-web.service'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode != 0:
            # Falls ohne sudo fehlgeschlagen, versuche mit sudo
            result = subprocess.run(
                ['sudo', 'systemctl', 'stop', 'relay-web.service'],
                capture_output=True,
                text=True,
                timeout=5
            )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'stopped',
                'message': 'Server gestoppt'
            })
        else:
            return jsonify({
                'error': f'Fehler beim Stoppen: {result.stderr}'
            }), 500
            
    except subprocess.TimeoutExpired:
        return jsonify({
            'error': 'Timeout beim Stoppen des Servers'
        }), 500
    except Exception as e:
        return jsonify({
            'error': f'Fehler: {str(e)}'
        }), 500

@app.route('/')
def index():
    """Serve React App"""
    return send_from_directory('build', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    """Serve static files"""
    return send_from_directory('build', path)

if __name__ == '__main__':
    print("🚀 Starte Relais-Web-Server...")
    print("📱 Öffne im Browser: http://<raspberry-pi-ip>:5000")
    print("⚠️  Drücke Ctrl+C zum Beenden")
    
    # Starte Server auf allen Interfaces (0.0.0.0) damit es vom Handy erreichbar ist
    app.run(host='0.0.0.0', port=5000, debug=False)

