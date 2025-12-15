#!/bin/bash
# Diagnose-Skript für Relais-Web-Server
# Auf dem Raspberry Pi ausführen

echo "🔍 Diagnose für Relais-Web-Server"
echo "=================================="
echo ""

# 1. Prüfe IP-Adresse
echo "📡 IP-Adresse des Raspberry Pi:"
IP=$(hostname -I | awk '{print $1}')
echo "   $IP"
echo ""

# 2. Prüfe ob Server läuft
echo "🔍 Prüfe ob Server läuft..."
if pgrep -f "relay-web-backend.py" > /dev/null; then
    echo "   ✅ Server läuft!"
    PID=$(pgrep -f "relay-web-backend.py")
    echo "   PID: $PID"
else
    echo "   ❌ Server läuft NICHT!"
    echo ""
    echo "   💡 Starte den Server mit:"
    echo "      cd ~/relay-web-control"
    echo "      python3 relay-web-backend.py"
fi
echo ""

# 3. Prüfe ob Port 5000 offen ist
echo "🔍 Prüfe Port 5000..."
if netstat -tuln 2>/dev/null | grep -q ":5000 " || ss -tuln 2>/dev/null | grep -q ":5000 "; then
    echo "   ✅ Port 5000 ist offen!"
else
    echo "   ⚠️  Port 5000 scheint nicht offen zu sein"
    echo "   💡 Möglicherweise läuft der Server nicht"
fi
echo ""

# 4. Prüfe ob build-Ordner existiert
echo "🔍 Prüfe Frontend (build-Ordner)..."
if [ -d ~/relay-web-control/build ]; then
    echo "   ✅ build-Ordner existiert!"
    if [ -f ~/relay-web-control/build/index.html ]; then
        echo "   ✅ index.html gefunden!"
    else
        echo "   ⚠️  index.html fehlt!"
    fi
else
    echo "   ❌ build-Ordner fehlt!"
    echo "   💡 Frontend muss gebaut und kopiert werden"
fi
echo ""

# 5. Prüfe Python-Abhängigkeiten
echo "🔍 Prüfe Python-Abhängigkeiten..."
if python3 -c "import flask" 2>/dev/null; then
    echo "   ✅ Flask installiert"
else
    echo "   ❌ Flask fehlt!"
fi

if python3 -c "import flask_cors" 2>/dev/null; then
    echo "   ✅ flask-cors installiert"
else
    echo "   ❌ flask-cors fehlt!"
fi

if python3 -c "import gpiozero" 2>/dev/null; then
    echo "   ✅ gpiozero installiert"
else
    echo "   ❌ gpiozero fehlt!"
fi
echo ""

# 6. Teste Verbindung
echo "🔍 Teste lokale Verbindung..."
if curl -s http://localhost:5000/api/status > /dev/null 2>&1; then
    echo "   ✅ Server antwortet auf localhost:5000!"
    STATUS=$(curl -s http://localhost:5000/api/status)
    echo "   Status: $STATUS"
else
    echo "   ❌ Server antwortet nicht auf localhost:5000"
fi
echo ""

# Zusammenfassung
echo "📋 Zusammenfassung:"
echo "==================="
echo "   IP-Adresse: $IP"
echo "   URL: http://$IP:5000"
echo ""
echo "   💡 Öffne diese URL im Browser auf deinem Handy/Computer"
echo ""

