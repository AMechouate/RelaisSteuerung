#!/bin/bash
# Setup-Skript für Relais-Web-Steuerung auf Raspberry Pi

echo "🔧 Setup für Relais-Web-Steuerung auf Raspberry Pi"
echo "=================================================="
echo ""

ssh raspberrypi << 'ENDSSH'
cd ~

# Erstelle Projekt-Verzeichnis
mkdir -p relay-web-control
cd relay-web-control

echo "📦 Installiere Python-Abhängigkeiten..."
pip3 install flask flask-cors gpiozero

echo ""
echo "📝 Erstelle Backend-Server..."
cat > relay-web-backend.py << 'PYEOF'
#!/usr/bin/env python3
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
from gpiozero import OutputDevice
import threading
import time

app = Flask(__name__, static_folder='build', static_url_path='')
CORS(app)

gpioList = [26, 19, 13, 6, 12, 16, 20, 21]
relays = [OutputDevice(pin, active_high=False) for pin in gpioList]

relay_running = False
relay_thread = None

def relay_loop():
    global relay_running
    sleepTimeShort = 0.2
    sleepTimeLong = 0.1
    
    while relay_running:
        for relay in relays:
            if not relay_running:
                break
            relay.on()
            time.sleep(sleepTimeShort)
            relay.off()
            time.sleep(sleepTimeLong)
    
    for relay in relays:
        relay.off()

@app.route('/api/status', methods=['GET'])
def get_status():
    return jsonify({
        'running': relay_running,
        'relays': len(relays)
    })

@app.route('/api/start', methods=['POST'])
def start_relay():
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
    global relay_running
    
    if not relay_running:
        return jsonify({'error': 'Relais läuft nicht'}), 400
    
    relay_running = False
    
    if relay_thread:
        relay_thread.join(timeout=1.0)
    
    return jsonify({
        'status': 'stopped',
        'message': 'Relais gestoppt'
    })

@app.route('/')
def index():
    return send_from_directory('build', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('build', path)

if __name__ == '__main__':
    print("🚀 Starte Relais-Web-Server...")
    print("📱 Öffne im Browser: http://<raspberry-pi-ip>:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)
PYEOF

chmod +x relay-web-backend.py

echo "✅ Backend erstellt!"
echo ""
echo "📋 Nächste Schritte:"
echo "1. Baue das React-Frontend (siehe Anleitung)"
echo "2. Kopiere den 'build' Ordner auf den Raspberry Pi"
echo "3. Starte den Server: python3 relay-web-backend.py"
echo ""
echo "📱 IP-Adresse des Raspberry Pi:"
hostname -I | awk '{print $1}'
ENDSSH

echo ""
echo "✅ Setup abgeschlossen!"
echo ""
echo "📝 Jetzt musst du:"
echo "1. Das React-Frontend bauen"
echo "2. Den build-Ordner auf den Raspberry Pi kopieren"
echo "3. Den Server starten"

