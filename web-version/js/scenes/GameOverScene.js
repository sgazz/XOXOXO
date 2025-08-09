class GameOverScene extends Phaser.Scene {
    constructor() {
        super({ key: 'GameOverScene' });
        this.results = null;
    }

    init(data) {
        this.results = data;
        console.log('GameOverScene: Game over with results:', this.results);
    }

    create() {
        // Create background
        this.createBackground();
        
        // Create game over content
        this.createGameOverContent();
        
        // Create action buttons
        this.createActionButtons();
        
        // Add input handlers
        this.setupInputHandlers();
    }

    // Create background
    createBackground() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Semi-transparent overlay
        this.overlay = this.add.graphics();
        this.overlay.fillStyle(0x000000, 0.8);
        this.overlay.fillRect(0, 0, width, height);
        
        // Animate overlay
        this.tweens.add({
            targets: this.overlay,
            alpha: { from: 0, to: 1 },
            duration: 500,
            ease: 'Power2'
        });
    }

    // Create game over content
    createGameOverContent() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Game over container
        const containerWidth = 500;
        const containerHeight = 400;
        const containerX = width / 2;
        const containerY = height / 2;
        
        // Container background
        this.container = this.add.graphics();
        this.container.fillStyle(0x003300, 0.95);
        this.container.fillRoundedRect(
            containerX - containerWidth / 2,
            containerY - containerHeight / 2,
            containerWidth,
            containerHeight,
            16
        );
        this.container.lineStyle(3, COLORS.PRIMARY_GREEN);
        this.container.strokeRoundedRect(
            containerX - containerWidth / 2,
            containerY - containerHeight / 2,
            containerWidth,
            containerHeight,
            16
        );
        
        // Game over title
        this.title = this.add.text(containerX, containerY - 120, 'GAME OVER', {
            fontFamily: 'Orbitron',
            fontSize: '2.5rem',
            fontWeight: '900',
            color: COLORS.PRIMARY_GREEN,
            stroke: COLORS.PRIMARY_GREEN,
            strokeThickness: 2,
            shadow: {
                offsetX: 0,
                offsetY: 0,
                color: COLORS.PRIMARY_GREEN,
                blur: 25,
                fill: true
            }
        }).setOrigin(0.5);
        
        // Result message
        let resultMessage = '';
        let resultColor = COLORS.WHITE;
        
        if (this.results.reason === 'timeout') {
            resultMessage = `TIME OUT for player ${this.results.timeoutPlayer}!`;
            resultColor = COLORS.RED;
        } else if (this.results.reason === 'victory') {
            resultMessage = `WINNER: ${this.results.winner}!`;
            resultColor = COLORS.GREEN;
        }
        
        this.resultText = this.add.text(containerX, containerY - 60, resultMessage, {
            fontFamily: 'Orbitron',
            fontSize: '1.5rem',
            fontWeight: '700',
            color: resultColor
        }).setOrigin(0.5);
        
        // Final score
        this.scoreText = this.add.text(containerX, containerY, 
            `FINAL SCORE: ${this.results.score.x} : ${this.results.score.o}`, {
            fontFamily: 'Orbitron',
            fontSize: '1.2rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0.5);
        
        // Animate content
        this.tweens.add({
            targets: [this.container, this.title, this.resultText, this.scoreText],
            scaleX: { from: 0.8, to: 1 },
            scaleY: { from: 0.8, to: 1 },
            alpha: { from: 0, to: 1 },
            duration: 600,
            ease: 'Back.easeOut',
            stagger: 100
        });
        
        // Add glow animation for title
        this.tweens.add({
            targets: this.title,
            alpha: { from: 0.7, to: 1 },
            duration: 2000,
            ease: 'Sine.easeInOut',
            yoyo: true,
            repeat: -1
        });
    }

    // Create action buttons
    createActionButtons() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        const buttonWidth = 140;
        const buttonHeight = 50;
        const spacing = 20;
        
        const buttons = [
            { text: 'NEW GAME', action: () => this.startNewGame() },
            { text: 'MAIN MENU', action: () => this.returnToMenu() },
            { text: 'STATISTICS', action: () => this.showStatistics() }
        ];
        
        const startX = width / 2 - (buttons.length * buttonWidth + (buttons.length - 1) * spacing) / 2;
        const buttonY = height / 2 + 80;
        
        buttons.forEach((buttonData, index) => {
            const x = startX + index * (buttonWidth + spacing);
            const button = this.createButton(x, buttonY, buttonWidth, buttonHeight, buttonData.text, buttonData.action);
            
            // Animate button
            this.tweens.add({
                targets: [button.bg, button.text],
                scaleX: { from: 0, to: 1 },
                scaleY: { from: 0, to: 1 },
                duration: 400,
                ease: 'Back.easeOut',
                delay: 800 + index * 100
            });
        });
    }

    // Create button
    createButton(x, y, width, height, text, callback) {
        // Button background
        const buttonBg = this.add.graphics();
        buttonBg.fillStyle(0x003300, 0.8);
        buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        buttonBg.lineStyle(2, COLORS.PRIMARY_GREEN, 0.8);
        buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        
        // Button text
        const buttonText = this.add.text(x, y, text, {
            fontFamily: 'Orbitron',
            fontSize: '1rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0.5);
        
        // Interactive area
        const buttonArea = this.add.zone(x, y, width, height);
        buttonArea.setInteractive();
        
        // Hover effects
        buttonArea.on('pointerover', () => {
            buttonBg.clear();
            buttonBg.fillStyle(COLORS.PRIMARY_GREEN, 0.3);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GREEN, 1);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            
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
            buttonBg.fillStyle(0x003300, 0.8);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GREEN, 0.8);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            
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
                yoyo: true,
                onComplete: callback
            });
        });
        
        return { bg: buttonBg, text: buttonText, area: buttonArea };
    }

    // Start new game
    startNewGame() {
        // Fade out scene
        this.tweens.add({
            targets: [this.overlay, this.container, this.title, this.resultText, this.scoreText],
            alpha: 0,
            duration: 300,
            ease: 'Power2',
            onComplete: () => {
                this.scene.start('GameScene', { 
                    gameMode: GAME_MODE.AI_OPPONENT,
                    aiDifficulty: AI_DIFFICULTY.MEDIUM
                });
            }
        });
    }

    // Return to menu
    returnToMenu() {
        // Fade out scene
        this.tweens.add({
            targets: [this.overlay, this.container, this.title, this.resultText, this.scoreText],
            alpha: 0,
            duration: 300,
            ease: 'Power2',
            onComplete: () => {
                this.scene.start('MenuScene');
            }
        });
    }

    // Show statistics
    showStatistics() {
        // TODO: Implement statistics view
        this.showModal('Statistika', 'Funkcija u razvoju...');
    }

    // Show modal
    showModal(title, content) {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Modal background
        const modalBg = this.add.graphics();
        modalBg.fillStyle(0x000000, 0.9);
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

    // Setup input handlers
    setupInputHandlers() {
        this.input.keyboard.on('keydown', (event) => {
            switch (event.key) {
                case 'Enter':
                    this.startNewGame();
                    break;
                case 'Escape':
                    this.returnToMenu();
                    break;
            }
        });
    }
}
