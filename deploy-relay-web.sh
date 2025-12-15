#!/bin/bash
# Baut das React-Frontend und kopiert es auf den Raspberry Pi

echo "🔨 Baue React-Frontend..."
cd relay-web-frontend

# Prüfe ob node_modules existiert
if [ ! -d "node_modules" ]; then
    echo "📦 Installiere npm-Pakete..."
    npm install
fi

echo "🏗️  Baue Production-Version..."
npm run build

echo ""
echo "📤 Kopiere auf Raspberry Pi..."

# Versuche mit verschiedenen Methoden
if scp -r ../build adam@raspberrypi.local:~/relay-web-control/ 2>/dev/null; then
    echo "✅ Erfolgreich kopiert!"
elif scp -r ../build raspberrypi:~/relay-web-control/ 2>/dev/null; then
    echo "✅ Erfolgreich kopiert!"
else
    echo "⚠️  Automatisches Kopieren fehlgeschlagen."
    echo ""
    echo "📋 Manuell kopieren:"
    echo "   scp -r build adam@raspberrypi.local:~/relay-web-control/"
    echo "   oder"
    echo "   scp -r build raspberrypi:~/relay-web-control/"
fi

echo ""
echo "🚀 Starte Server auf Raspberry Pi:"
echo "   ssh adam@raspberrypi.local"
echo "   cd ~/relay-web-control"
echo "   python3 relay-web-backend.py"
echo "   oder"
echo "   sudo systemctl restart relay-web.service"

