#!/bin/bash
# Start-Skript für Relais-Web-Server
# Auf dem Raspberry Pi ausführen

cd ~/relay-web-control

# Ermittle IP-Adresse automatisch
IP=$(hostname -I | awk '{print $1}')

echo "🚀 Starte Relais-Web-Server..."
echo "📱 Öffne im Browser: http://$IP:5000"
echo "⚠️  Drücke Ctrl+C zum Beenden"
echo ""

python3 relay-web-backend.py

