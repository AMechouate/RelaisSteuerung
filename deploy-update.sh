#!/bin/bash
# Deploy-Skript für Frontend und Backend Update
# Führe aus, wenn der Raspberry Pi erreichbar ist

PI_HOST="raspberrypi.local"
PI_IP="192.168.178.46"
PI_USER="adam"
PI_PATH="~/relay-web-control"

echo "🚀 Deploye Updates auf Raspberry Pi"
echo "====================================="
echo ""

# Versuche zuerst mit Hostname, dann mit IP
echo "🔍 Prüfe Verbindung..."
FINAL_HOST=""
if ssh -o ConnectTimeout=3 -o BatchMode=yes $PI_USER@$PI_HOST "echo 'OK'" > /dev/null 2>&1; then
    echo "✅ Verbindung mit $PI_HOST erfolgreich"
    FINAL_HOST=$PI_HOST
elif ssh -o ConnectTimeout=3 -o BatchMode=yes $PI_USER@$PI_IP "echo 'OK'" > /dev/null 2>&1; then
    echo "✅ Verbindung mit $PI_IP erfolgreich"
    FINAL_HOST=$PI_IP
else
    echo "⚠️  Automatische Verbindung fehlgeschlagen"
    echo ""
    echo "📋 Versuche manuell zu verbinden..."
    echo "   Versuche zuerst: $PI_HOST"
    FINAL_HOST=$PI_HOST
fi

# Baue Frontend (falls noch nicht gebaut)
if [ ! -d "build" ]; then
    echo "🔨 Baue Frontend..."
    cd relay-web-frontend
    npm run build
    cd ..
fi

# Kopiere Frontend
echo ""
echo "📤 Kopiere Frontend..."
if scp -r build $PI_USER@$FINAL_HOST:$PI_PATH/; then
    echo "✅ Frontend kopiert!"
else
    # Versuche mit IP falls Hostname fehlschlägt
    if [ "$FINAL_HOST" != "$PI_IP" ]; then
        echo "   Versuche mit IP-Adresse..."
        if scp -r build $PI_USER@$PI_IP:$PI_PATH/; then
            echo "✅ Frontend kopiert (mit IP)!"
            FINAL_HOST=$PI_IP
        else
            echo "❌ Fehler beim Kopieren des Frontends"
            echo ""
            echo "💡 Manuelle Befehle:"
            echo "   scp -r build $PI_USER@$PI_HOST:$PI_PATH/"
            echo "   oder"
            echo "   scp -r build $PI_USER@$PI_IP:$PI_PATH/"
            exit 1
        fi
    else
        echo "❌ Fehler beim Kopieren des Frontends"
        exit 1
    fi
fi

# Kopiere Backend
echo ""
echo "📤 Kopiere Backend..."
if scp relay-web-backend.py $PI_USER@$FINAL_HOST:$PI_PATH/; then
    echo "✅ Backend kopiert!"
else
    echo "❌ Fehler beim Kopieren des Backends"
    exit 1
fi

# Starte Service neu
echo ""
echo "🔄 Starte Service neu..."
if ssh $PI_USER@$FINAL_HOST "sudo systemctl restart relay-web.service"; then
    echo "✅ Service neu gestartet!"
else
    echo "⚠️  Fehler beim Neustarten des Services"
    echo "   Starte manuell: ssh $PI_USER@$FINAL_HOST 'sudo systemctl restart relay-web.service'"
fi

# Hole IP-Adresse für Anzeige (falls nicht bereits bekannt)
DISPLAY_IP=$PI_IP
if [ "$FINAL_HOST" = "$PI_HOST" ]; then
    DISPLAY_IP=$(ssh $PI_USER@$FINAL_HOST "hostname -I | awk '{print \$1}'" 2>/dev/null || echo "$PI_IP")
fi

echo ""
echo "✅ Deployment abgeschlossen!"
echo ""
echo "🌐 Öffne im Browser: http://$DISPLAY_IP:5000"
echo ""
echo "💡 Neue Features:"
echo "   - Server-Status anzeigen"
echo "   - Server vom Web-Interface starten/stoppen"

