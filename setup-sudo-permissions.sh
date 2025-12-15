#!/bin/bash
# Konfiguriert sudo-Berechtigungen für systemctl-Befehle
# Auf dem Raspberry Pi ausführen

echo "🔐 Konfiguriere sudo-Berechtigungen für systemctl"
echo "=================================================="
echo ""

ssh adam@raspberrypi.local << 'ENDSSH'
# Prüfe ob bereits konfiguriert
if sudo grep -q "pi ALL=(ALL) NOPASSWD: /bin/systemctl start relay-web.service" /etc/sudoers.d/relay-web 2>/dev/null; then
    echo "✅ sudo-Berechtigungen sind bereits konfiguriert"
    exit 0
fi

echo "📝 Erstelle sudoers-Datei..."

# Erstelle sudoers-Datei für relay-web Service
# Verwende den aktuellen Benutzer (adam)
CURRENT_USER=$(whoami)
sudo tee /etc/sudoers.d/relay-web > /dev/null << SUDOERSEOF
# Erlaube User $CURRENT_USER systemctl-Befehle für relay-web.service ohne Passwort
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl start relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl stop relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl restart relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl status relay-web.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl is-active relay-web.service
SUDOERSEOF

# Setze korrekte Berechtigungen
sudo chmod 0440 /etc/sudoers.d/relay-web

# Validiere sudoers-Datei
if sudo visudo -c -f /etc/sudoers.d/relay-web; then
    echo "✅ sudo-Berechtigungen erfolgreich konfiguriert!"
    echo ""
    echo "📋 Der User '$CURRENT_USER' kann jetzt ohne Passwort folgende Befehle ausführen:"
    echo "   - systemctl start relay-web.service"
    echo "   - systemctl stop relay-web.service"
    echo "   - systemctl restart relay-web.service"
    echo "   - systemctl status relay-web.service"
    echo "   - systemctl is-active relay-web.service"
else
    echo "❌ Fehler bei der Konfiguration!"
    echo "   Bitte manuell prüfen: sudo visudo -c -f /etc/sudoers.d/relay-web"
    exit 1
fi
ENDSSH

echo ""
echo "✅ Konfiguration abgeschlossen!"

