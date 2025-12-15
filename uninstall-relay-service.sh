#!/bin/bash
# Deinstalliert den Relais-Web-Server systemd Service
# Auf dem Raspberry Pi ausführen

echo "🗑️  Deinstalliere Relais-Web-Server Service"
echo "============================================"
echo ""

ssh adam@raspberrypi.local << 'ENDSSH'
# Stoppe Service
echo "⏹️  Stoppe Service..."
sudo systemctl stop relay-web.service 2>/dev/null

# Deaktiviere Service
echo "🔌 Deaktiviere Service..."
sudo systemctl disable relay-web.service 2>/dev/null

# Entferne Service-Datei
echo "🗑️  Entferne Service-Datei..."
sudo rm /etc/systemd/system/relay-web.service 2>/dev/null

# Lade systemd neu
echo "🔄 Lade systemd neu..."
sudo systemctl daemon-reload

echo ""
echo "✅ Service deinstalliert!"
echo ""
echo "💡 Der Server startet jetzt NICHT mehr automatisch beim Boot"
echo "   Du kannst ihn manuell starten mit: python3 ~/relay-web-control/relay-web-backend.py"
ENDSSH

echo ""
echo "✅ Deinstallation abgeschlossen!"

