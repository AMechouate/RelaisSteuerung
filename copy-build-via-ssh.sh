#!/bin/bash
# Kopiert build-Ordner über SSH-Verbindung

echo "📤 Kopiere build-Ordner auf Raspberry Pi..."
echo ""

# Erstelle tar-Archiv
cd build
tar -czf /tmp/build.tar.gz .

# Kopiere über SSH
echo "📤 Übertrage Dateien..."
cat /tmp/build.tar.gz | ssh adam@raspberrypi.local "cd ~/relay-web-control && rm -rf build && mkdir -p build && cd build && tar -xzf - && chmod -R 755 ."

# Lösche temporäres Archiv
rm /tmp/build.tar.gz

echo ""
echo "✅ Dateien kopiert!"
echo ""
echo "🔄 Starte Service neu..."
ssh adam@raspberrypi.local "sudo systemctl restart relay-web.service"

echo ""
echo "✅ Fertig! Öffne http://192.168.178.46:5000"

