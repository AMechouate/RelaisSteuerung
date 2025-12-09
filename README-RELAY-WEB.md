# Relais Web-Steuerung

React-Webseite zur Steuerung des 8-Kanal-Relais-Moduls auf dem Raspberry Pi.

## Setup

### 1. Backend auf Raspberry Pi installieren

```bash
./setup-relay-web.sh
```

Oder manuell:
```bash
ssh raspberrypi
cd ~
mkdir -p relay-web-control
cd relay-web-control
pip3 install flask flask-cors gpiozero
# Kopiere relay-web-backend.py hierher
chmod +x relay-web-backend.py
```

### 2. Frontend bauen und deployen

**Auf dem Mac:**
```bash
cd relay-web-frontend
npm install
npm run build
```

**Kopiere build-Ordner auf Raspberry Pi:**
```bash
scp -r build raspberrypi:~/relay-web-control/
```

Oder automatisch:
```bash
./deploy-relay-web.sh
```

### 3. Server starten

**Auf dem Raspberry Pi:**
```bash
cd ~/relay-web-control
python3 relay-web-backend.py
```

### 4. Aufrufen vom Handy

1. Finde die IP-Adresse des Raspberry Pi:
   ```bash
   hostname -I
   ```

2. Öffne im Browser auf deinem Handy:
   ```
   http://<raspberry-pi-ip>:5000
   ```
   
   Beispiel: `http://192.168.178.46:5000`

## Funktionen

- ✅ Start/Stop Button
- ✅ Status-Anzeige (Läuft/Gestoppt)
- ✅ Responsive Design (funktioniert auf Handy)
- ✅ Automatische Status-Updates
- ✅ Schöne, moderne UI

## Dateien

- `relay-web-backend.py` - Flask-Server für GPIO-Steuerung
- `relay-web-frontend/` - React-Frontend
- `setup-relay-web.sh` - Setup-Skript
- `deploy-relay-web.sh` - Deploy-Skript

## Troubleshooting

**Port 5000 nicht erreichbar?**
- Prüfe Firewall: `sudo ufw allow 5000`
- Prüfe ob Server läuft: `ps aux | grep relay-web-backend`

**Frontend nicht sichtbar?**
- Prüfe ob build-Ordner existiert: `ls ~/relay-web-control/build`
- Prüfe Server-Logs

