# 🚀 Quick Start - Morgen in der Arbeit

## Schritt 1: Raspberry Pi IP-Adresse finden

**Option A: Vom Raspberry Pi aus (wenn du Zugriff hast)**
```bash
hostname -I
```

**Option B: Vom Laptop aus (wenn beide im gleichen WLAN sind)**
```bash
# Auf Mac/Linux
ping raspberrypi.local

# Oder scanne das Netzwerk
arp -a | grep raspberrypi
```

**Option C: Vom Raspberry Pi Display (falls angeschlossen)**
- Öffne Terminal auf dem Raspberry Pi
- Führe aus: `hostname -I`

## Schritt 2: Mit Raspberry Pi verbinden

```bash
# Mit Hostname (funktioniert meistens)
sudo ssh adam@raspberrypi.local

# Oder mit direkter IP (falls Hostname nicht funktioniert)
sudo ssh adam@<neue-ip-adresse>
```

## Schritt 3: Server starten

```bash
cd ~/relay-web-control
python3 relay-web-backend.py
```

**Server im Hintergrund starten (optional):**
```bash
cd ~/relay-web-control
nohup python3 relay-web-backend.py > server.log 2>&1 &
```

## Schritt 4: Auf Handy öffnen

1. Stelle sicher, dass dein Handy im **gleichen WLAN** ist
2. Öffne Browser auf dem Handy
3. Gehe zu: `http://<raspberry-pi-ip>:5000`
   - Beispiel: `http://192.168.1.100:5000`

## 🔍 IP-Adresse schnell finden

**Vom Raspberry Pi:**
```bash
hostname -I | awk '{print $1}'
```

**Vom Laptop (wenn beide im gleichen WLAN):**
```bash
# Teste Hostname
ping -c 1 raspberrypi.local

# Oder finde alle Geräte im Netzwerk
nmap -sn 192.168.1.0/24  # Passe Netzwerk an!
```

## ⚠️ Wichtige Hinweise

1. **Alle Geräte müssen im gleichen WLAN sein!**
   - Laptop
   - Raspberry Pi
   - Handy

2. **Server muss laufen!**
   - Prüfe: `ps aux | grep relay-web-backend`
   - Falls nicht: Starte neu (Schritt 3)

3. **Port 5000 muss offen sein!**
   ```bash
   sudo ufw allow 5000
   # Oder Firewall deaktivieren
   sudo ufw disable
   ```

## 🛠️ Troubleshooting

**"Connection refused" auf Handy?**
- Prüfe ob Server läuft
- Prüfe ob richtige IP-Adresse verwendet wird
- Prüfe Firewall

**"No route to host"?**
- Prüfe ob alle Geräte im gleichen WLAN sind
- Prüfe IP-Adresse des Raspberry Pi

**SSH funktioniert nicht?**
- Versuche: `sudo ssh adam@raspberrypi.local`
- Oder: `sudo ssh adam@<ip-adresse>`
- Prüfe ob SSH auf Raspberry Pi aktiviert ist

## 📱 Schnelltest

1. Finde IP: `hostname -I` (auf Raspberry Pi)
2. Starte Server: `python3 relay-web-backend.py` (auf Raspberry Pi)
3. Öffne auf Handy: `http://<ip>:5000`

**Fertig!** 🎉

