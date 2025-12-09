#!/bin/bash
# Findet die IP-Adresse des Raspberry Pi

echo "🔍 Suche Raspberry Pi IP-Adresse..."
echo ""

# Versuche Hostname
echo "1️⃣ Versuche Hostname (raspberrypi.local)..."
if ping -c 1 -W 1 raspberrypi.local &> /dev/null; then
    IP=$(ping -c 1 raspberrypi.local | grep -oP '\(\K[^)]+' | head -1)
    echo "✅ Gefunden via Hostname: $IP"
    echo ""
    echo "📋 Verbinden mit:"
    echo "   ssh adam@raspberrypi.local"
    echo "   oder"
    echo "   ssh adam@$IP"
    echo ""
    echo "🌐 Web-Interface:"
    echo "   http://$IP:5000"
    exit 0
fi

echo "❌ Hostname nicht erreichbar"
echo ""

# Versuche ARP-Cache
echo "2️⃣ Suche in ARP-Cache..."
ARP_RESULT=$(arp -a | grep -i raspberrypi | head -1)
if [ ! -z "$ARP_RESULT" ]; then
    IP=$(echo $ARP_RESULT | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
    echo "✅ Gefunden in ARP-Cache: $IP"
    echo ""
    echo "📋 Verbinden mit:"
    echo "   ssh adam@$IP"
    echo ""
    echo "🌐 Web-Interface:"
    echo "   http://$IP:5000"
    exit 0
fi

echo "❌ Nicht im ARP-Cache gefunden"
echo ""

# Netzwerk-Scan (benötigt nmap)
echo "3️⃣ Versuche Netzwerk-Scan..."
if command -v nmap &> /dev/null; then
    # Finde lokales Netzwerk
    GATEWAY=$(route -n get default | grep gateway | awk '{print $2}')
    NETWORK=$(echo $GATEWAY | cut -d'.' -f1-3).0/24
    
    echo "   Scanne Netzwerk: $NETWORK"
    echo "   (Das kann einen Moment dauern...)"
    echo ""
    
    # Suche nach Raspberry Pi (typische Ports)
    RESULT=$(nmap -p 22 $NETWORK 2>/dev/null | grep -B 2 "22/tcp.*open" | grep "Nmap scan report" | head -1)
    
    if [ ! -z "$RESULT" ]; then
        IP=$(echo $RESULT | grep -oP '\d+\.\d+\.\d+\.\d+')
        echo "✅ Mögliche Raspberry Pi gefunden: $IP"
        echo ""
        echo "🧪 Teste Verbindung..."
        if ssh -o ConnectTimeout=2 -o BatchMode=yes adam@$IP "echo 'OK'" &> /dev/null; then
            echo "✅ Bestätigt! Das ist dein Raspberry Pi"
            echo ""
            echo "📋 Verbinden mit:"
            echo "   ssh adam@$IP"
            echo ""
            echo "🌐 Web-Interface:"
            echo "   http://$IP:5000"
            exit 0
        fi
    fi
else
    echo "⚠️  nmap nicht installiert. Installiere mit:"
    echo "   brew install nmap  # auf Mac"
    echo "   sudo apt install nmap  # auf Linux"
fi

echo ""
echo "❌ Raspberry Pi nicht gefunden"
echo ""
echo "💡 Manuelle Suche:"
echo "   1. Verbinde dich direkt mit dem Raspberry Pi (Display/Tastatur)"
echo "   2. Führe aus: hostname -I"
echo "   3. Oder schaue in deinem Router nach verbundenen Geräten"
echo ""
echo "📋 Dann verbinden mit:"
echo "   ssh adam@<gefundene-ip>"

