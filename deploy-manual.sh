#!/bin/bash
# Manuelle Deploy-Befehle - Kopiere und führe diese Befehle aus

echo "📋 Manuelle Deploy-Befehle für Raspberry Pi"
echo "============================================"
echo ""
echo "Führe diese Befehle manuell in deinem Terminal aus:"
echo ""
echo "1️⃣  Frontend kopieren:"
echo "   scp -r build adam@raspberrypi.local:~/relay-web-control/"
echo ""
echo "2️⃣  Backend kopieren:"
echo "   scp relay-web-backend.py adam@raspberrypi.local:~/relay-web-control/"
echo ""
echo "3️⃣  Service neu starten:"
echo "   ssh adam@raspberrypi.local 'sudo systemctl restart relay-web.service'"
echo ""
echo "🌐 Danach öffne im Browser: http://192.168.178.46:5000"
echo ""
echo "💡 Tipp: Falls raspberrypi.local nicht funktioniert, verwende die IP:"
echo "   scp -r build adam@192.168.178.46:~/relay-web-control/"
echo "   scp relay-web-backend.py adam@192.168.178.46:~/relay-web-control/"
echo "   ssh adam@192.168.178.46 'sudo systemctl restart relay-web.service'"

