#!/bin/bash
# Installiert den Relais-Web-Server als systemd Service
# Auf dem Raspberry Pi ausführen

echo "🔧 Installiere Relais-Web-Server als systemd Service"
echo "===================================================="
echo ""

ssh adam@raspberrypi.local << 'ENDSSH'
cd ~

# Prüfe ob Service-Datei bereits existiert
if [ -f /etc/systemd/system/relay-web.service ]; then
    echo "⚠️  Service existiert bereits. Stoppe und entferne alten Service..."
    sudo systemctl stop relay-web.service
    sudo systemctl disable relay-web.service
    sudo rm /etc/systemd/system/relay-web.service
fi

# Erstelle Service-Datei
echo "📝 Erstelle Service-Datei..."
sudo tee /etc/systemd/system/relay-web.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Relais Web Control Server
After=network.target

[Service]
Type=simple
User=adam
WorkingDirectory=/home/adam/relay-web-control
ExecStart=/usr/bin/python3 /home/adam/relay-web-control/relay-web-backend.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Lade systemd neu
echo "🔄 Lade systemd neu..."
sudo systemctl daemon-reload

# Aktiviere Service
echo "✅ Aktiviere Service..."
sudo systemctl enable relay-web.service

# Starte Service
echo "🚀 Starte Service..."
sudo systemctl start relay-web.service

# Warte kurz
sleep 2

# Konfiguriere sudo-Berechtigungen für Web-Interface
echo ""
echo "🔐 Konfiguriere sudo-Berechtigungen für Web-Interface..."
CURRENT_USER=$(whoami)
if [ ! -f /etc/sudoers.d/relay-web ]; then
    sudo tee /etc/sudoers.d/relay-web > /dev/null << SUDOERSEOF
# Erlaube User $CURRENT_USER systemctl-Befehle für relay-web.service ohne Passwort
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl start relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl stop relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl restart relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl status relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl is-active relay-web.service
SUDOERSEOF
    sudo chmod 0440 /etc/sudoers.d/relay-web
    if sudo visudo -c -f /etc/sudoers.d/relay-web > /dev/null 2>&1; then
        echo "   ✅ sudo-Berechtigungen konfiguriert für User: $CURRENT_USER"
    else
        echo "   ⚠️  Fehler bei sudo-Konfiguration (kann manuell nachgeholt werden)"
    fi
else
    echo "   ✅ sudo-Berechtigungen bereits vorhanden"
fi

# Zeige Status
echo ""
echo "📊 Service-Status:"
sudo systemctl status relay-web.service --no-pager -l

echo ""
echo "✅ Service installiert und gestartet!"
echo ""
echo "📋 Nützliche Befehle:"
echo "   Status prüfen:  sudo systemctl status relay-web.service"
echo "   Logs anzeigen:  sudo journalctl -u relay-web.service -f"
echo "   Service stoppen: sudo systemctl stop relay-web.service"
echo "   Service starten: sudo systemctl start relay-web.service"
echo "   Service neu starten: sudo systemctl restart relay-web.service"
echo ""
echo "🌐 Server sollte jetzt erreichbar sein unter:"
IP=$(hostname -I | awk '{print $1}')
echo "   http://$IP:5000"
echo ""
echo "💡 Du kannst den Server jetzt auch vom Web-Interface aus starten/stoppen!"
ENDSSH

echo ""
echo "✅ Installation abgeschlossen!"
echo ""
echo "💡 Der Server startet jetzt automatisch beim Boot des Raspberry Pi"

