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
        
        // Create fallback assets
        this.createFallbackAssets();
        
        // Hide loading screen
        if (typeof gameInstance !== 'undefined' && gameInstance && gameInstance.hideLoadingScreen) {
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
        // For now, we'll create fallback assets programmatically
        // In a real project, you would load actual image files
        console.log('BootScene: Creating fallback assets');
    }

    // Load sounds
    loadSounds() {
        // For now, we'll use Web Audio API for sound effects
        // In a real project, you would load actual sound files
        console.log('BootScene: Using Web Audio API for sounds');
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
        
        // Icons
        graphics.clear();
        graphics.fillStyle(0xffd700);
        graphics.fillCircle(25, 25, 20);
        this.textures.addImage('icon-pause', graphics.generateTexture());
        
        graphics.clear();
        graphics.fillStyle(0x4a90e2);
        graphics.fillCircle(25, 25, 20);
        this.textures.addImage('icon-settings', graphics.generateTexture());
        
        graphics.clear();
        graphics.fillStyle(0xff6b35);
        graphics.fillCircle(25, 25, 20);
        this.textures.addImage('icon-sound', graphics.generateTexture());
        
        graphics.clear();
        graphics.fillStyle(0x666666);
        graphics.fillCircle(25, 25, 20);
        this.textures.addImage('icon-vibration', graphics.generateTexture());
        
        // Particles
        graphics.clear();
        graphics.fillStyle(0xffd700);
        graphics.fillCircle(10, 10, 10);
        this.textures.addImage('particle-gold', graphics.generateTexture());
        
        graphics.clear();
        graphics.fillStyle(0x4a90e2);
        graphics.fillCircle(10, 10, 10);
        this.textures.addImage('particle-blue', graphics.generateTexture());
        
        graphics.clear();
        graphics.fillStyle(0xff6b35);
        graphics.fillCircle(10, 10, 10);
        this.textures.addImage('particle-orange', graphics.generateTexture());
        
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
