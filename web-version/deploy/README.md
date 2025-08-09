# XO Arena - Web Version

Web verzija popularne XO Arena igre, napravljena sa Phaser.js.

## 🎮 O igri

XO Arena je napredna verzija klasične igre XO (Tic-Tac-Toe) sa sledećim funkcionalnostima:

- **8 tabla** umesto jedne
- **Tajmer sistem** sa bonus/penalty vremenom
- **AI protivnik** sa različitim nivoima težine
- **Lepi UI** sa gradijentima i animacijama
- **Zvučni efekti** i haptic feedback
- **Statistika igre** i praćenje rezultata

## 🚀 Kako pokrenuti

### Lokalno pokretanje

1. **Klonirajte repozitorijum:**
   ```bash
   git clone <repository-url>
   cd XOXOXO/web-version
   ```

2. **Pokrenite lokalni server:**
   ```bash
   # Koristeći Python
   python -m http.server 8000
   
   # Ili koristeći Node.js
   npx http-server -p 8000
   
   # Ili koristeći PHP
   php -S localhost:8000
   ```

3. **Otvorite u browseru:**
   ```
   http://localhost:8000
   ```

### Deployment

Možete deployovati na bilo koji statički hosting:

- **GitHub Pages**
- **Netlify**
- **Vercel**
- **Firebase Hosting**

## 🛠️ Tehnologije

- **Phaser 3** - Game engine
- **HTML5 Canvas** - Rendering
- **Web Audio API** - Zvučni efekti
- **LocalStorage** - Čuvanje podataka
- **CSS3** - Stilovi i animacije
- **JavaScript ES6+** - Game logic

## 📁 Struktura projekta

```
web-version/
├── index.html              # Glavni HTML fajl
├── css/
│   └── style.css          # Stilovi
├── js/
│   ├── game.js            # Glavna game konfiguracija
│   ├── scenes/            # Phaser scene-ovi
│   │   ├── BootScene.js
│   │   ├── MenuScene.js
│   │   ├── GameScene.js
│   │   └── GameOverScene.js
│   ├── components/        # Game komponente
│   │   ├── Board.js
│   │   ├── Timer.js
│   │   ├── ScoreDisplay.js
│   │   └── AI.js
│   └── utils/            # Utility funkcije
│       ├── constants.js
│       ├── soundManager.js
│       └── statistics.js
└── assets/
    ├── sounds/           # Zvučni fajlovi
    └── images/           # Slike i teksture
```

## 🎯 Funkcionalnosti

### Game Modes
- **vs AI** - Igrajte protiv veštačke inteligencije
- **vs Player** - Igrajte protiv drugog igrača

### AI Difficulty Levels
- **Lako** - AI igra nasumično
- **Srednje** - AI blokira i pokušava da pobedi
- **Teško** - AI igra optimalno

### Timer System
- **Bonus vreme** (+15s) za pobednika
- **Penalty vreme** (-10s) za gubitnika
- **Draw penalty** (-5s) za oba igrača

### Statistics
- Praćenje pobeda/poraza
- Prosečno vreme po potezu
- Najduži niz pobeda
- Poziciona statistika (centar/ugao/ivica)

## 🎨 UI/UX Features

- **Responsive dizajn** - Radi na svim uređajima
- **Dark theme** - Moderna tamna tema
- **Animacije** - Smooth animacije i tranzicije
- **Haptic feedback** - Vibracija na mobilnim uređajima
- **Zvučni efekti** - Atmosferični zvukovi

## 🔧 Konfiguracija

### Game Settings
```javascript
const GAME_CONFIG = {
    BOARD_COUNT: 8,        // Broj tabla
    INITIAL_TIME: 180,     // Početno vreme (sekunde)
    BONUS_TIME: 15,        // Bonus vreme
    PENALTY_TIME: 10,      // Penalty vreme
    DRAW_PENALTY_TIME: 5   // Draw penalty
};
```

### Colors
```javascript
const COLORS = {
    PRIMARY_GOLD: '#ffd700',
    PRIMARY_BLUE: '#4a90e2',
    PRIMARY_ORANGE: '#ff6b35',
    DARK_BACKGROUND: '#0a0a0f'
};
```

## 📱 Browser Support

- ✅ Chrome 60+
- ✅ Firefox 55+
- ✅ Safari 12+
- ✅ Edge 79+
- ✅ Mobile browsers

## 🎮 Controls

### Keyboard
- `1` - Igraj vs AI
- `2` - Igraj vs Player
- `S` - Podešavanja
- `H` - Kako igrati
- `ESC` - Pause/Back

### Touch/Mouse
- Tap na ćelije za potez
- Tap na dugmad za akcije
- Swipe za navigaciju

## 🔄 Razvoj

### Dodavanje novih funkcionalnosti

1. **Nova scena:**
   ```javascript
   class NewScene extends Phaser.Scene {
       constructor() {
           super({ key: 'NewScene' });
       }
       
       create() {
           // Scene logic
       }
   }
   ```

2. **Nova komponenta:**
   ```javascript
   class NewComponent {
       constructor(scene, config) {
           this.scene = scene;
           this.config = config;
       }
   }
   ```

### Debug mode
```javascript
// Uključite debug mode u game.js
debug: true
```

## 📊 Performance

- **FPS:** 60fps na većini uređaja
- **Memory:** < 50MB RAM
- **Load time:** < 3s na 3G
- **Bundle size:** < 2MB

## 🤝 Contributing

1. Fork repozitorijum
2. Napravite feature branch
3. Commit promene
4. Push na branch
5. Otvorite Pull Request

## 📄 License

MIT License - pogledajte LICENSE fajl za detalje.

## 🙏 Credits

- **Phaser.js** - Game engine
- **Inter font** - Typography
- **Original Swift app** - Game design i logika

---

**Napomena:** Ova web verzija je u razvoju. Neke funkcionalnosti možda nisu potpuno implementirane.
