# 🎮 XO Arena - Web Version

**Tic-Tac-Toe igra sa 8 tabla - napravljena u Phaser.js**

## 🚀 Brzo Pokretanje

### Opcija 1: Automatski (Preporučeno)
```bash
# Dvokliknite na fajl
./start-game.command
```

### Opcija 2: Manuelno
```bash
# Pređite u direktorijum
cd web-version

# Pokrenite server
python3 -m http.server 8000

# Otvorite browser
open http://localhost:8000
```

## 🛑 Zaustavljanje Servera

### Automatski
```bash
# Dvokliknite na fajl
./stop-server.command
```

### Manuelno
```bash
# Pritisnite Ctrl+C u terminalu gde server radi
# ILI
# Pronađite i prekinite proces
lsof -ti:8000 | xargs kill -9
```

## 🎯 Kako Igrati

### 1. **Odaberite Mod Igre**
- **Igraj vs AI** - igrate protiv veštačke inteligencije
- **Igraj vs Player** - igrate protiv drugog igrača

### 2. **Podešavanja (ako igrate vs AI)**
- **Lako** - AI igra nasumično
- **Srednje** - AI blokira i pokušava da pobedi
- **Teško** - AI igra optimalno (minimax algoritam)

### 3. **Pravila Igre**
- **8 tabla** - svaka tabla je 3x3 Tic-Tac-Toe
- **Aktivirajte tablu** - kliknite na bilo koju tablu da je aktivirate
- **Napravite potez** - kliknite na praznu ćeliju u aktivnoj tabli
- **Pobedite 4 od 8 tabla** da pobedite igru

### 4. **Timer Sistem**
- **Bonus vreme** - dobijate dodatno vreme za pobedu
- **Penalty vreme** - gubite vreme za poraz
- **Draw penalty** - gubite vreme za remi

## 🎮 Funkcionalnosti

### ✅ **Implementirano**
- **8 Tic-Tac-Toe tabla** - glavna mehanika
- **AI protivnik** - 3 nivoa težine
- **Timer sistem** - bonus/penalty vreme
- **Score tracking** - praćenje rezultata
- **Podešavanja** - zvučni efekti, vibracija
- **Statistika** - praćenje igara
- **PWA** - može se instalirati kao app
- **Offline mode** - radi bez interneta
- **Analytics** - praćenje korisnika
- **SEO** - search engine friendly

### 🚧 **Planirano**
- **Online multiplayer** - igra preko interneta
- **Leaderboards** - rang liste
- **Achievements** - dostignuća
- **Custom themes** - različite teme
- **Tournament mode** - turnirski mod

## 📱 PWA Funkcionalnosti

### Instalacija
1. Otvorite igru u Chrome/Safari
2. Kliknite "Add to Home Screen"
3. Igra se instalira kao native app

### Offline Mode
- Igra radi bez interneta
- Sve funkcionalnosti dostupne offline
- Automatska sinhronizacija kada se vratite online

## 🔧 Tehnički Detalji

### **Tehnologije**
- **Phaser.js** - game engine
- **HTML5 Canvas** - rendering
- **Web Audio API** - zvučni efekti
- **LocalStorage** - čuvanje podataka
- **Service Worker** - offline funkcionalnosti
- **PWA** - progressive web app

### **Struktura Fajlova**
```
web-version/
├── index.html              # Glavni HTML fajl
├── css/style.css           # Stilovi
├── js/
│   ├── game.js            # Glavna logika
│   ├── scenes/            # Phaser scene-ovi
│   ├── components/        # Game komponente
│   └── utils/             # Utility funkcije
├── assets/                # Resursi (slike, zvukovi)
├── start-game.command     # Script za pokretanje
├── stop-server.command    # Script za zaustavljanje
└── README-GAME.md         # Ova dokumentacija
```

## 🐛 Troubleshooting

### **Problem: Port 8000 je zauzet**
```bash
# Rešenje: Koristite stop-server.command
./stop-server.command
```

### **Problem: Igra se ne učitava**
```bash
# Proverite da li su svi fajlovi tu
ls -la js/components/
ls -la js/scenes/
```

### **Problem: Zvučni efekti ne rade**
- Proverite da li je zvuk uključen u browser-u
- Proverite podešavanja u igri (Settings)

### **Problem: AI ne reaguje**
- Proverite da li je AI.js fajl učitan
- Proverite konzolu browser-a za greške

## 📊 Statistike

### **Praćenje**
- Broj odigranih igara
- Pobede/porazi
- Vreme igranja
- Najbolji rezultati

### **Analytics**
- Korisničke sesije
- Game events
- Performance metrics
- Error tracking

## 🎨 Customizacija

### **Boje**
```javascript
// U js/utils/constants.js
COLORS = {
    PRIMARY_GOLD: '#FFD700',
    PRIMARY_BLUE: '#4A90E2',
    PRIMARY_ORANGE: '#F5A623',
    // ...
}
```

### **Zvučni Efecti**
```javascript
// U js/utils/soundManager.js
SOUNDS = {
    MOVE: 'move.wav',
    WIN: 'win.wav',
    LOSE: 'lose.wav',
    // ...
}
```

## 🚀 Deployment

### **GitHub Pages**
```bash
# Automatski deployment
git push origin main
```

### **Netlify/Vercel**
```bash
# Upload web-version folder
# Automatski deployment
```

### **Tradicionalni Hosting**
```bash
# Upload sve fajlove
# Konfigurišite .htaccess
```

---

## 🎮 **Uživajte u igri!**

**XO Arena** - najbolja Tic-Tac-Toe igra sa 8 tabla! 🏆
