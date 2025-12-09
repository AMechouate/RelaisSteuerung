#!/bin/bash
# Aktualisiert das Backend auf dem Raspberry Pi

echo "🔄 Aktualisiere Backend auf Raspberry Pi..."
echo ""

# Prüfe ob Datei existiert
if [ ! -f "relay-web-backend.py" ]; then
    echo "❌ relay-web-backend.py nicht gefunden!"
    echo "   Bitte führe dieses Skript aus dem RelaisSteuerung-Ordner aus."
    exit 1
fi

echo "📋 Kopiere Backend..."
sudo scp relay-web-backend.py raspberrypi:~/relay-web-control/

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Backend kopiert!"
    echo ""
    echo "📝 Nächste Schritte auf dem Raspberry Pi:"
    echo "   1. Stoppe den Server (Ctrl+C im Server-Terminal)"
    echo "   2. Starte neu: cd ~/relay-web-control && python3 relay-web-backend.py"
    echo ""
    echo "🔧 Oder führe aus:"
    echo "   sudo ssh adam@raspberrypi.local 'cd ~/relay-web-control && pkill -f relay-web-backend.py && python3 relay-web-backend.py &'"
else
    echo ""
    echo "❌ Fehler beim Kopieren!"
    echo "   Versuche es manuell:"
    echo "   sudo scp relay-web-backend.py raspberrypi:~/relay-web-control/"
fi

