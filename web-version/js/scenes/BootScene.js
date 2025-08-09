class BootScene extends Phaser.Scene {
    constructor() {
        super({ key: 'BootScene' });
    }

    preload() {
        // Create loading bar
        this.createLoadingBar();
        
        // Load game assets
        this.loadGameAssets();
        
        // Load sounds
        this.loadSounds();
        
        // Load fonts
        this.loadFonts();
    }

    create() {
        console.log('BootScene: Assets loaded successfully');
        
        // Hide loading screen
        if (gameInstance && gameInstance.hideLoadingScreen) {
            gameInstance.hideLoadingScreen();
        }
        
        // Start menu scene
        this.scene.start('MenuScene');
    }

    // Create loading bar
    createLoadingBar() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Loading bar background
        const progressBarBg = this.add.graphics();
        progressBarBg.fillStyle(0x222222, 0.8);
        progressBarBg.fillRect(width / 2 - 160, height / 2 + 50, 320, 20);
        
        // Loading bar
        const progressBar = this.add.graphics();
        
        // Loading text
        const loadingText = this.add.text(width / 2, height / 2 + 20, 'Učitavanje...', {
            fontFamily: 'Inter',
            fontSize: '24px',
            color: COLORS.WHITE
        }).setOrigin(0.5);
        
        // Progress text
        const progressText = this.add.text(width / 2, height / 2 + 80, '0%', {
            fontFamily: 'Inter',
            fontSize: '16px',
            color: COLORS.PRIMARY_GOLD
        }).setOrigin(0.5);
        
        // Update loading bar
        this.load.on('progress', (value) => {
            progressBar.clear();
            progressBar.fillStyle(COLORS.PRIMARY_GOLD, 1);
            progressBar.fillRect(width / 2 - 160, height / 2 + 50, 320 * value, 20);
            progressText.setText(Math.round(value * 100) + '%');
        });
        
        // Complete loading
        this.load.on('complete', () => {
            progressText.setText('Gotovo!');
            progressText.setColor(COLORS.GREEN);
        });
    }

    // Load game assets
    loadGameAssets() {
        // Load background textures
        this.load.image('background', 'assets/images/background.png');
        
        // Load UI elements
        this.load.image('button-bg', 'assets/images/button-bg.png');
        this.load.image('cell-bg', 'assets/images/cell-bg.png');
        this.load.image('board-bg', 'assets/images/board-bg.png');
        
        // Load symbols
        this.load.image('symbol-x', 'assets/images/symbol-x.png');
        this.load.image('symbol-o', 'assets/images/symbol-o.png');
        
        // Load icons
        this.load.image('icon-pause', 'assets/images/icon-pause.png');
        this.load.image('icon-settings', 'assets/images/icon-settings.png');
        this.load.image('icon-sound', 'assets/images/icon-sound.png');
        this.load.image('icon-vibration', 'assets/images/icon-vibration.png');
        
        // Load particles
        this.load.image('particle-gold', 'assets/images/particle-gold.png');
        this.load.image('particle-blue', 'assets/images/particle-blue.png');
        this.load.image('particle-orange', 'assets/images/particle-orange.png');
    }

    // Load sounds
    loadSounds() {
        // Load sound effects
        this.load.audio('move', 'assets/sounds/move.wav');
        this.load.audio('win', 'assets/sounds/win.wav');
        this.load.audio('lose', 'assets/sounds/lose.wav');
        this.load.audio('draw', 'assets/sounds/draw.wav');
        this.load.audio('tap', 'assets/sounds/tap.wav');
        this.load.audio('error', 'assets/sounds/error.wav');
        
        // Load background music (optional)
        this.load.audio('bg-music', 'assets/sounds/bg-music.mp3');
    }

    // Load fonts
    loadFonts() {
        // Preload Inter font
        const fontLink = document.createElement('link');
        fontLink.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap';
        fontLink.rel = 'stylesheet';
        document.head.appendChild(fontLink);
    }

    // Create fallback assets if images fail to load
    createFallbackAssets() {
        // Create simple colored rectangles as fallbacks
        const graphics = this.add.graphics();
        
        // Background
        graphics.fillStyle(0x1a1a2e);
        graphics.fillRect(0, 0, 100, 100);
        this.textures.addImage('background', graphics.generateTexture());
        
        // Button background
        graphics.clear();
        graphics.fillStyle(0x333333);
        graphics.fillRoundedRect(0, 0, 200, 50, 10);
        this.textures.addImage('button-bg', graphics.generateTexture());
        
        // Cell background
        graphics.clear();
        graphics.fillStyle(0x222222);
        graphics.fillRoundedRect(0, 0, 80, 80, 8);
        this.textures.addImage('cell-bg', graphics.generateTexture());
        
        // Board background
        graphics.clear();
        graphics.fillStyle(0x1a1a2e);
        graphics.fillRoundedRect(0, 0, 300, 300, 12);
        this.textures.addImage('board-bg', graphics.generateTexture());
        
        // Symbols
        graphics.clear();
        graphics.lineStyle(4, 0x4a90e2);
        graphics.beginPath();
        graphics.moveTo(20, 20);
        graphics.lineTo(80, 80);
        graphics.moveTo(80, 20);
        graphics.lineTo(20, 80);
        graphics.strokePath();
        this.textures.addImage('symbol-x', graphics.generateTexture());
        
        graphics.clear();
        graphics.lineStyle(4, 0xff6b35);
        graphics.strokeCircle(50, 50, 30);
        this.textures.addImage('symbol-o', graphics.generateTexture());
        
        graphics.destroy();
    }

    // Handle loading errors
    handleLoadError(file) {
        console.warn('Failed to load asset:', file.src);
        
        // Create fallback assets if needed
        if (!this.textures.exists('background')) {
            this.createFallbackAssets();
        }
    }
}
