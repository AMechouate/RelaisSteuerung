#!/usr/bin/env python3
"""
Flask Backend für Relais-Steuerung
Läuft auf dem Raspberry Pi
"""
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
from gpiozero import OutputDevice
import threading
import time

app = Flask(__name__, static_folder='build', static_url_path='')
CORS(app)

# GPIO-Pins für 8-Kanal-Relais
gpioList = [26, 19, 13, 6, 12, 16, 20, 21]
relays = [OutputDevice(pin, active_high=False) for pin in gpioList]

# Globale Variable für Relais-Status
relay_running = False
relay_thread = None
channel_states = [False] * 8  # Status für jeden Kanal

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
    for i, relay in enumerate(relays):
        relay.off()
        channel_states[i] = False

@app.route('/api/status', methods=['GET'])
def get_status():
    """Gibt den aktuellen Status zurück"""
    return jsonify({
        'running': relay_running,
        'relays': len(relays),
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

@app.route('/api/channels/<int:channel>/on', methods=['POST'])
def channel_on(channel):
    """Schaltet einen Kanal ein"""
    global relay_running
    
    if relay_running:
        return jsonify({'error': 'Automatische Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    if channel < 1 or channel > 8:
        return jsonify({'error': 'Ungültiger Kanal (1-8)'}), 400
    
    idx = channel - 1
    relays[idx].on()
    channel_states[idx] = True
    
    return jsonify({
        'status': 'on',
        'channel': channel,
        'message': f'Kanal {channel} eingeschaltet'
    })

@app.route('/api/channels/<int:channel>/off', methods=['POST'])
def channel_off(channel):
    """Schaltet einen Kanal aus"""
    global relay_running
    
    if relay_running:
        return jsonify({'error': 'Automatische Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    if channel < 1 or channel > 8:
        return jsonify({'error': 'Ungültiger Kanal (1-8)'}), 400
    
    idx = channel - 1
    relays[idx].off()
    channel_states[idx] = False
    
    return jsonify({
        'status': 'off',
        'channel': channel,
        'message': f'Kanal {channel} ausgeschaltet'
    })

@app.route('/api/channels/<int:channel>/toggle', methods=['POST'])
def channel_toggle(channel):
    """Schaltet einen Kanal um"""
    global relay_running
    
    if relay_running:
        return jsonify({'error': 'Automatische Sequenz läuft. Bitte zuerst stoppen.'}), 400
    
    if channel < 1 or channel > 8:
        return jsonify({'error': 'Ungültiger Kanal (1-8)'}), 400
    
    idx = channel - 1
    if channel_states[idx]:
        relays[idx].off()
        channel_states[idx] = False
        status = 'off'
    else:
        relays[idx].on()
        channel_states[idx] = True
        status = 'on'
    
    return jsonify({
        'status': status,
        'channel': channel,
        'message': f'Kanal {channel} {status}'
    })

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

