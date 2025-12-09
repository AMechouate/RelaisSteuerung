#!/bin/bash
# Startet den Relais-Server auf dem Raspberry Pi (remote)

echo "🚀 Starte Relais-Server auf Raspberry Pi..."
echo ""

# Versuche verschiedene Verbindungsmethoden
PI_HOST=""

# 1. Versuche Hostname
if ping -c 1 -W 1 raspberrypi.local &> /dev/null; then
    PI_HOST="raspberrypi.local"
    echo "✅ Verbinde via Hostname: $PI_HOST"
elif ping -c 1 -W 1 adam.local &> /dev/null; then
    PI_HOST="adam.local"
    echo "✅ Verbinde via Hostname: $PI_HOST"
else
    echo "❌ Hostname nicht erreichbar"
    echo ""
    echo "💡 Bitte IP-Adresse eingeben:"
    read -p "Raspberry Pi IP: " PI_HOST
fi

echo ""
echo "📡 Verbinde mit Raspberry Pi..."
echo ""

# Starte Server
ssh adam@$PI_HOST << 'ENDSSH'
cd ~/relay-web-control

# Prüfe ob Server bereits läuft
if pgrep -f "relay-web-backend.py" > /dev/null; then
    echo "⚠️  Server läuft bereits!"
    echo "   PID: $(pgrep -f 'relay-web-backend.py')"
    echo ""
    read -p "Server neu starten? (j/n): " RESTART
    if [ "$RESTART" = "j" ] || [ "$RESTART" = "J" ]; then
        echo "🛑 Stoppe alten Server..."
        pkill -f relay-web-backend.py
        sleep 2
    else
        echo "✅ Server läuft bereits. Beende Skript."
        exit 0
    fi
fi

# Zeige IP-Adresse
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "🌐 Raspberry Pi IP: $IP"
echo "📱 Öffne auf Handy: http://$IP:5000"
echo ""
echo "🚀 Starte Server..."
echo "⚠️  Drücke Ctrl+C zum Beenden (oder schließe Terminal)"
echo ""

# Starte Server
python3 relay-web-backend.py
ENDSSH

