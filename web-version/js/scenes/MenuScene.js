class MenuScene extends Phaser.Scene {
    constructor() {
        super({ key: 'MenuScene' });
        this.buttons = [];
        this.background = null;
        this.title = null;
        this.subtitle = null;
    }

    create() {
        console.log('MenuScene: Creating menu');
        
        // Create background
        this.createBackground();
        
        // Create title
        this.createTitle();
        
        // Create menu buttons
        this.createMenuButtons();
        
        // Create floating particles
        this.createParticles();
        
        // Add input handlers
        this.setupInputHandlers();
    }

    // Create animated background
    createBackground() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Main background gradient
        this.background = this.add.graphics();
        this.background.fillGradientStyle(
            0x0a0a0f, 0x0a0a0f, 0x1a1a2e, 0x1a1a2e, 1
        );
        this.background.fillRect(0, 0, width, height);
        
        // Add floating lights
        this.createFloatingLights();
    }

    // Create floating lights
    createFloatingLights() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Gold light (top center)
        const goldLight = this.add.graphics();
        goldLight.fillStyle(COLORS.PRIMARY_GOLD, 0.1);
        goldLight.fillCircle(width / 2, height * 0.2, 150);
        
        // Blue light (top left)
        const blueLight = this.add.graphics();
        blueLight.fillStyle(COLORS.PRIMARY_BLUE, 0.08);
        blueLight.fillCircle(width * 0.2, height * 0.3, 120);
        
        // Orange light (top right)
        const orangeLight = this.add.graphics();
        orangeLight.fillStyle(COLORS.PRIMARY_ORANGE, 0.08);
        orangeLight.fillCircle(width * 0.8, height * 0.3, 120);
        
        // Animate lights
        this.tweens.add({
            targets: [goldLight, blueLight, orangeLight],
            alpha: { from: 0.3, to: 0.8 },
            duration: 2000,
            ease: 'Sine.easeInOut',
            yoyo: true,
            repeat: -1,
            stagger: 500
        });
    }

    // Create title
    createTitle() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Main title
        this.title = this.add.text(width / 2, height * 0.25, 'XO ARENA', {
            fontFamily: 'Inter',
            fontSize: '4rem',
            fontWeight: '800',
            color: COLORS.WHITE,
            stroke: COLORS.PRIMARY_GOLD,
            strokeThickness: 3,
            shadow: {
                offsetX: 2,
                offsetY: 2,
                color: COLORS.BLACK,
                blur: 4,
                fill: true
            }
        }).setOrigin(0.5);
        
        // Subtitle
        this.subtitle = this.add.text(width / 2, height * 0.35, 'Ultimate Tic-Tac-Toe Experience', {
            fontFamily: 'Inter',
            fontSize: '1.2rem',
            fontWeight: '400',
            color: COLORS.PRIMARY_GOLD,
            alpha: 0.8
        }).setOrigin(0.5);
        
        // Animate title
        this.tweens.add({
            targets: this.title,
            scaleX: 1.05,
            scaleY: 1.05,
            duration: 2000,
            ease: 'Sine.easeInOut',
            yoyo: true,
            repeat: -1
        });
    }

    // Create menu buttons
    createMenuButtons() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        const buttonWidth = 280;
        const buttonHeight = 60;
        const spacing = 20;
        
        const buttons = [
            { text: 'Igraj vs AI', action: () => this.startGame(GAME_MODE.AI_OPPONENT) },
            { text: 'Igraj vs Igrač', action: () => this.startGame(GAME_MODE.PLAYER_VS_PLAYER) },
            { text: 'Statistika', action: () => this.showStatistics() },
            { text: 'Podešavanja', action: () => this.showSettings() },
            { text: 'Kako igrati', action: () => this.showTutorial() }
        ];
        
        const startY = height * 0.5;
        
        buttons.forEach((buttonData, index) => {
            const y = startY + (buttonHeight + spacing) * index;
            const button = this.createButton(
                width / 2,
                y,
                buttonWidth,
                buttonHeight,
                buttonData.text,
                buttonData.action
            );
            this.buttons.push(button);
        });
    }

    // Create a button
    createButton(x, y, width, height, text, callback) {
        // Button background
        const buttonBg = this.add.graphics();
        buttonBg.fillStyle(0x333333, 0.8);
        buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 12);
        buttonBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 12);
        
        // Button text
        const buttonText = this.add.text(x, y, text, {
            fontFamily: 'Inter',
            fontSize: '1.1rem',
            fontWeight: '600',
            color: COLORS.WHITE
        }).setOrigin(0.5);
        
        // Interactive area
        const buttonArea = this.add.zone(x, y, width, height);
        buttonArea.setInteractive();
        
        // Hover effects
        buttonArea.on('pointerover', () => {
            buttonBg.clear();
            buttonBg.fillStyle(COLORS.PRIMARY_GOLD, 0.2);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 12);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GOLD, 1);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 12);
            
            this.tweens.add({
                targets: [buttonBg, buttonText],
                scaleX: 1.05,
                scaleY: 1.05,
                duration: 150,
                ease: 'Power2'
            });
        });
        
        buttonArea.on('pointerout', () => {
            buttonBg.clear();
            buttonBg.fillStyle(0x333333, 0.8);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 12);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 12);
            
            this.tweens.add({
                targets: [buttonBg, buttonText],
                scaleX: 1,
                scaleY: 1,
                duration: 150,
                ease: 'Power2'
            });
        });
        
        buttonArea.on('pointerdown', () => {
            soundManager.playSound(SOUNDS.TAP);
            soundManager.playHaptic();
            
            this.tweens.add({
                targets: [buttonBg, buttonText],
                scaleX: 0.95,
                scaleY: 0.95,
                duration: 100,
                ease: 'Power2',
                yoyo: true
            });
            
            // Execute callback after animation
            this.time.delayedCall(100, callback);
        });
        
        return { bg: buttonBg, text: buttonText, area: buttonArea };
    }

    // Create floating particles
    createParticles() {
        try {
            const width = this.cameras.main.width;
            const height = this.cameras.main.height;
            
            // Check if particle texture exists
            if (this.textures.exists('particle-gold')) {
                // Create particle emitter
                const particles = this.add.particles('particle-gold');
                
                const emitter = particles.createEmitter({
                    x: { min: 0, max: width },
                    y: height + 50,
                    speedY: { min: -50, max: -100 },
                    speedX: { min: -20, max: 20 },
                    scale: { start: 0.1, end: 0 },
                    alpha: { start: 0.6, end: 0 },
                    lifespan: 4000,
                    frequency: 500,
                    quantity: 1
                });
            } else {
                console.log('MenuScene: Particle texture not available, skipping particles');
            }
        } catch (error) {
            console.warn('MenuScene: Error creating particles:', error);
        }
    }

    // Setup input handlers
    setupInputHandlers() {
        // Handle keyboard input
        this.input.keyboard.on('keydown', (event) => {
            switch (event.key) {
                case '1':
                    this.startGame(GAME_MODE.AI_OPPONENT);
                    break;
                case '2':
                    this.startGame(GAME_MODE.PLAYER_VS_PLAYER);
                    break;
                case 's':
                    this.showSettings();
                    break;
                case 'h':
                    this.showTutorial();
                    break;
                case 'Escape':
                    // Could show exit confirmation
                    break;
            }
        });
    }

    // Start game
    startGame(gameMode) {
        console.log('MenuScene: Starting game with mode:', gameMode);
        
        // Fade out menu
        this.tweens.add({
            targets: [this.background, this.title, this.subtitle, ...this.buttons.flatMap(b => [b.bg, b.text])],
            alpha: 0,
            duration: 500,
            ease: 'Power2',
            onComplete: () => {
                this.scene.start('GameScene', { gameMode: gameMode });
            }
        });
    }

    // Show statistics
    showStatistics() {
        console.log('MenuScene: Show statistics');
        // TODO: Implement statistics scene
        this.showModal('Statistika', 'Funkcija u razvoju...');
    }

    // Show settings
    showSettings() {
        console.log('MenuScene: Show settings');
        // Create settings modal
        const settingsModal = new SettingsModal(this);
        settingsModal.show();
    }

    // Show tutorial
    showTutorial() {
        console.log('MenuScene: Show tutorial');
        // TODO: Implement tutorial scene
        this.showModal('Kako igrati', 'Funkcija u razvoju...');
    }

    // Show modal dialog
    showModal(title, content) {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Modal background
        const modalBg = this.add.graphics();
        modalBg.fillStyle(0x000000, 0.8);
        modalBg.fillRect(0, 0, width, height);
        
        // Modal content
        const modalWidth = 400;
        const modalHeight = 200;
        const modalX = width / 2;
        const modalY = height / 2;
        
        const modalContent = this.add.graphics();
        modalContent.fillStyle(0x1a1a2e, 0.95);
        modalContent.fillRoundedRect(modalX - modalWidth / 2, modalY - modalHeight / 2, modalWidth, modalHeight, 12);
        modalContent.lineStyle(2, COLORS.PRIMARY_GOLD);
        modalContent.strokeRoundedRect(modalX - modalWidth / 2, modalY - modalHeight / 2, modalWidth, modalHeight, 12);
        
        // Modal title
        const modalTitle = this.add.text(modalX, modalY - 40, title, {
            fontFamily: 'Inter',
            fontSize: '1.5rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GOLD
        }).setOrigin(0.5);
        
        // Modal content text
        const modalText = this.add.text(modalX, modalY, content, {
            fontFamily: 'Inter',
            fontSize: '1rem',
            fontWeight: '400',
            color: COLORS.WHITE,
            align: 'center',
            wordWrap: { width: modalWidth - 40 }
        }).setOrigin(0.5);
        
        // Close button
        const closeButton = this.createButton(modalX, modalY + 50, 120, 40, 'Zatvori', () => {
            this.tweens.add({
                targets: [modalBg, modalContent, modalTitle, modalText, closeButton.bg, closeButton.text],
                alpha: 0,
                duration: 300,
                ease: 'Power2',
                onComplete: () => {
                    modalBg.destroy();
                    modalContent.destroy();
                    modalTitle.destroy();
                    modalText.destroy();
                    closeButton.bg.destroy();
                    closeButton.text.destroy();
                    closeButton.area.destroy();
                }
            });
        });
        
        // Fade in modal
        this.tweens.add({
            targets: [modalBg, modalContent, modalTitle, modalText, closeButton.bg, closeButton.text],
            alpha: { from: 0, to: 1 },
            duration: 300,
            ease: 'Power2'
        });
    }
}
