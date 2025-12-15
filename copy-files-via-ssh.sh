#!/bin/bash
# Kopiert Dateien über SSH-Verbindung
# Führe dieses Skript manuell aus, wenn du dich bereits per SSH verbinden kannst

echo "📦 Kopiere Dateien über SSH..."
echo ""

# Erstelle temporäres tar-Archiv
echo "📦 Erstelle Archiv..."
tar -czf /tmp/relay-update.tar.gz build relay-web-backend.py

echo "📤 Kopiere auf Raspberry Pi..."
# Kopiere Archiv
scp /tmp/relay-update.tar.gz adam@raspberrypi.local:/tmp/

echo "📥 Entpacke auf Raspberry Pi..."
# Entpacke auf Raspberry Pi
ssh adam@raspberrypi.local << 'ENDSSH'
cd ~/relay-web-control
tar -xzf /tmp/relay-update.tar.gz
rm /tmp/relay-update.tar.gz
echo "✅ Dateien kopiert!"
ENDSSH

# Lösche temporäres Archiv
rm /tmp/relay-update.tar.gz

echo ""
echo "🔄 Starte Service neu..."
ssh adam@raspberrypi.local "sudo systemctl restart relay-web.service"

echo ""
echo "✅ Fertig! Öffne http://192.168.178.46:5000"

