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
        console.log('BootScene: Creating fallback assets using Canvas API');
        
        // Create background texture
        this.createTexture('background', 100, 100, 0x1a1a2e);
        
        // Create button background texture
        this.createTexture('button-bg', 200, 50, 0x333333, true);
        
        // Create cell background texture
        this.createTexture('cell-bg', 80, 80, 0x222222, true);
        
        // Create board background texture
        this.createTexture('board-bg', 300, 300, 0x1a1a2e, true);
        
        // Create symbol X texture
        this.createSymbolTexture('symbol-x', 100, 100, 'X', 0x4a90e2);
        
        // Create symbol O texture
        this.createSymbolTexture('symbol-o', 100, 100, 'O', 0xff6b35);
        
        // Create icon textures
        this.createIconTexture('icon-pause', 50, 50, 0xffd700);
        this.createIconTexture('icon-settings', 50, 50, 0x4a90e2);
        this.createIconTexture('icon-sound', 50, 50, 0xff6b35);
        this.createIconTexture('icon-vibration', 50, 50, 0x666666);
        
        // Create particle textures
        this.createParticleTexture('particle-gold', 20, 20, 0xffd700);
        this.createParticleTexture('particle-blue', 20, 20, 0x4a90e2);
        this.createParticleTexture('particle-orange', 20, 20, 0xff6b35);
    }
    
    // Create simple texture
    createTexture(key, width, height, color, rounded = false) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        
        ctx.fillStyle = '#' + color.toString(16).padStart(6, '0');
        if (rounded) {
            ctx.beginPath();
            ctx.roundRect(0, 0, width, height, 8);
            ctx.fill();
        } else {
            ctx.fillRect(0, 0, width, height);
        }
        
        this.textures.addImage(key, canvas);
    }
    
    // Create symbol texture
    createSymbolTexture(key, width, height, symbol, color) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        
        ctx.strokeStyle = '#' + color.toString(16).padStart(6, '0');
        ctx.lineWidth = 4;
        ctx.lineCap = 'round';
        
        if (symbol === 'X') {
            ctx.beginPath();
            ctx.moveTo(20, 20);
            ctx.lineTo(80, 80);
            ctx.moveTo(80, 20);
            ctx.lineTo(20, 80);
            ctx.stroke();
        } else if (symbol === 'O') {
            ctx.beginPath();
            ctx.arc(50, 50, 30, 0, 2 * Math.PI);
            ctx.stroke();
        }
        
        this.textures.addImage(key, canvas);
    }
    
    // Create icon texture
    createIconTexture(key, width, height, color) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        
        ctx.fillStyle = '#' + color.toString(16).padStart(6, '0');
        ctx.beginPath();
        ctx.arc(width/2, height/2, width/2 - 2, 0, 2 * Math.PI);
        ctx.fill();
        
        this.textures.addImage(key, canvas);
    }
    
    // Create particle texture
    createParticleTexture(key, width, height, color) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        
        ctx.fillStyle = '#' + color.toString(16).padStart(6, '0');
        ctx.beginPath();
        ctx.arc(width/2, height/2, width/2 - 1, 0, 2 * Math.PI);
        ctx.fill();
        
        this.textures.addImage(key, canvas);
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
