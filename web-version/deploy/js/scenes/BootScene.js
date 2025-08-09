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
        
        // Skip fallback assets creation for now - focus on core functionality
        console.log('BootScene: Skipping fallback assets creation');
        
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

    // Fallback assets creation removed - focusing on core functionality
    
    // Texture creation methods removed - focusing on core functionality

    // Handle loading errors
    handleLoadError(file) {
        console.warn('Failed to load asset:', file.src);
        // Fallback assets creation removed - focusing on core functionality
    }
}
