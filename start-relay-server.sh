#!/bin/bash
# Start-Skript für Relais-Web-Server
# Auf dem Raspberry Pi ausführen

cd ~/relay-web-control

echo "🚀 Starte Relais-Web-Server..."
echo "📱 Öffne im Browser: http://192.168.178.46:5000"
echo "⚠️  Drücke Ctrl+C zum Beenden"
echo ""

python3 relay-web-backend.py

