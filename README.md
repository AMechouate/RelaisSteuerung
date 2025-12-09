# Relais Steuerung - Raspberry Pi

Web-basierte Steuerung für ein 8-Kanal-Relais-Modul auf dem Raspberry Pi 5.

## 🚀 Features

- ✅ Web-Interface mit React
- ✅ Start/Stop Steuerung
- ✅ Responsive Design (funktioniert auf Handy)
- ✅ REST API für Relais-Steuerung
- ✅ Kompatibel mit Raspberry Pi 5 (gpiozero)

## 📋 Voraussetzungen

- Raspberry Pi 5 (oder Pi 4)
- 8-Kanal-Relais-Modul
- Python 3
- Node.js (für Frontend-Build)

## 🔧 Installation

### 1. Backend auf Raspberry Pi installieren

```bash
# SSH zum Raspberry Pi
ssh adam@raspberrypi.local

# Setup ausführen
cd ~/relay-web-control
pip3 install flask flask-cors gpiozero
```

### 2. Frontend bauen

```bash
cd relay-web-frontend
npm install
npm run build
```

### 3. Frontend auf Raspberry Pi kopieren

```bash
scp -r build raspberrypi:~/relay-web-control/
```

### 4. Server starten

```bash
cd ~/relay-web-control
python3 relay-web-backend.py
```

## 📱 Verwendung

1. Finde die IP-Adresse des Raspberry Pi:
   ```bash
   hostname -I
   ```

2. Öffne im Browser (Handy oder PC):
   ```
   http://<raspberry-pi-ip>:5000
   ```

3. Verwende die Start/Stop Buttons zum Steuern der Relais

## 🔌 GPIO-Pins

Das Relais-Modul ist an folgende GPIO-Pins angeschlossen:

| GPIO | Relais |
|------|--------|
| 26   | 01     |
| 19   | 02     |
| 13   | 03     |
| 6    | 04     |
| 12   | 05     |
| 16   | 06     |
| 20   | 07     |
| 21   | 08     |

## 📁 Projektstruktur

```
RelaisSteuerung/
├── relay-web-backend.py      # Flask Backend
├── relay-web-frontend/        # React Frontend
├── build/                     # Gebautes Frontend
├── gpiotest2_pi5.py          # Test-Skript (gpiozero)
├── gpiotest_pi5.py           # Test-Skript (lgpio)
├── setup-relay-web.sh        # Setup-Skript
├── deploy-relay-web.sh       # Deploy-Skript
└── start-relay-server.sh     # Start-Skript
```

## 🛠️ API Endpoints

- `GET /api/status` - Status abfragen
- `POST /api/start` - Relais starten
- `POST /api/stop` - Relais stoppen

## 🐛 Troubleshooting

**Port 5000 nicht erreichbar?**
```bash
sudo ufw allow 5000
sudo ufw disable  # Oder Firewall deaktivieren
```

**GPIO busy Fehler?**
- Stelle sicher, dass keine anderen Prozesse die GPIO-Pins verwenden
- Reboote den Raspberry Pi falls nötig

**Frontend nicht sichtbar?**
- Prüfe ob `build/` Ordner auf dem Raspberry Pi existiert
- Prüfe Server-Logs

## 📝 Lizenz

Dieses Projekt ist für den privaten Gebrauch erstellt.

