// Main game configuration and initialization
class XOArenaGame {
    constructor() {
        this.config = this.createGameConfig();
        this.game = null;
        this.currentScene = null;
        this.gameState = GAME_STATE.MENU;
        
        this.init();
    }

    // Create Phaser game configuration
    createGameConfig() {
        return {
            type: Phaser.AUTO,
            parent: 'game-container',
            width: window.innerWidth,
            height: window.innerHeight,
            backgroundColor: COLORS.DARK_BACKGROUND,
            scale: {
                mode: Phaser.Scale.RESIZE,
                autoCenter: Phaser.Scale.CENTER_BOTH,
                width: window.innerWidth,
                height: window.innerHeight
            },
            physics: {
                default: 'arcade',
                arcade: {
                    gravity: { y: 0 },
                    debug: false
                }
            },
            scene: [
                BootScene,
                MenuScene,
                GameScene,
                GameOverScene
            ],
            render: {
                pixelArt: false,
                antialias: true
            },
            audio: {
                disableWebAudio: false,
                context: null
            },
            dom: {
                createContainer: true
            }
        };
    }

    // Initialize the game
    init() {
        // Show loading screen
        this.showLoadingScreen();
        
        // Create Phaser game instance
        this.game = new Phaser.Game(this.config);
        
        // Handle window resize
        window.addEventListener('resize', () => {
            this.handleResize();
        });
        
        // Handle visibility change (pause when tab is not active)
        document.addEventListener('visibilitychange', () => {
            this.handleVisibilityChange();
        });
        
        // Handle beforeunload (save state)
        window.addEventListener('beforeunload', () => {
            this.saveGameState();
        });
    }

    // Show loading screen
    showLoadingScreen() {
        const loadingScreen = document.createElement('div');
        loadingScreen.className = 'loading-screen';
        loadingScreen.innerHTML = `
            <h1>XO Arena</h1>
            <div class="spinner"></div>
        `;
        document.body.appendChild(loadingScreen);
        
        this.loadingScreen = loadingScreen;
    }

    // Hide loading screen
    hideLoadingScreen() {
        if (this.loadingScreen) {
            this.loadingScreen.classList.add('hidden');
            setTimeout(() => {
                if (this.loadingScreen.parentNode) {
                    this.loadingScreen.parentNode.removeChild(this.loadingScreen);
                }
            }, 500);
        }
    }

    // Handle window resize
    handleResize() {
        if (this.game) {
            this.game.scale.resize(window.innerWidth, window.innerHeight);
            
            // Notify current scene about resize
            const currentScene = this.game.scene.getScene('GameScene');
            if (currentScene && currentScene.handleResize) {
                currentScene.handleResize();
            }
        }
    }

    // Handle visibility change (pause when tab is not active)
    handleVisibilityChange() {
        if (document.hidden) {
            this.pauseGame();
        } else {
            this.resumeGame();
        }
    }

    // Pause game
    pauseGame() {
        if (this.game && this.gameState === GAME_STATE.PLAYING) {
            this.gameState = GAME_STATE.PAUSED;
            this.game.scene.pause('GameScene');
        }
    }

    // Resume game
    resumeGame() {
        if (this.game && this.gameState === GAME_STATE.PAUSED) {
            this.gameState = GAME_STATE.PLAYING;
            this.game.scene.resume('GameScene');
        }
    }

    // Save game state
    saveGameState() {
        try {
            const gameState = {
                timestamp: new Date().toISOString(),
                gameState: this.gameState,
                currentScene: this.currentScene
            };
            localStorage.setItem('gameState', JSON.stringify(gameState));
        } catch (error) {
            console.warn('Error saving game state:', error);
        }
    }

    // Load game state
    loadGameState() {
        try {
            const savedState = localStorage.getItem('gameState');
            if (savedState) {
                const gameState = JSON.parse(savedState);
                this.gameState = gameState.gameState;
                this.currentScene = gameState.currentScene;
                return gameState;
            }
        } catch (error) {
            console.warn('Error loading game state:', error);
        }
        return null;
    }

    // Start new game
    startNewGame(gameMode = GAME_MODE.AI_OPPONENT, aiDifficulty = AI_DIFFICULTY.MEDIUM) {
        if (this.game) {
            this.gameState = GAME_STATE.PLAYING;
            this.game.scene.start('GameScene', { 
                gameMode: gameMode, 
                aiDifficulty: aiDifficulty 
            });
        }
    }

    // Return to menu
    returnToMenu() {
        if (this.game) {
            this.gameState = GAME_STATE.MENU;
            this.game.scene.start('MenuScene');
        }
    }

    // Show game over
    showGameOver(results) {
        if (this.game) {
            this.gameState = GAME_STATE.GAME_OVER;
            this.game.scene.start('GameOverScene', results);
        }
    }

    // Get current scene
    getCurrentScene() {
        if (this.game) {
            return this.game.scene.getScene('GameScene');
        }
        return null;
    }

    // Get device type
    getDeviceType() {
        const width = window.innerWidth;
        const height = window.innerHeight;
        const ratio = width / height;
        
        if (ratio > 1.2) {
            return 'landscape';
        } else if (ratio < 0.8) {
            return 'portrait';
        } else {
            return 'square';
        }
    }

    // Get device layout
    getDeviceLayout() {
        const deviceType = this.getDeviceType();
        const isMobile = window.innerWidth <= 768;
        
        if (isMobile) {
            return DEVICE_LAYOUT.IPHONE;
        } else {
            return DEVICE_LAYOUT.IPAD;
        }
    }

    // Check if device supports touch
    isTouchDevice() {
        return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    }

    // Check if device supports vibration
    supportsVibration() {
        return 'vibrate' in navigator;
    }

    // Get game settings
    getGameSettings() {
        try {
            const settings = localStorage.getItem(STORAGE_KEYS.GAME_SETTINGS);
            return settings ? JSON.parse(settings) : this.getDefaultSettings();
        } catch (error) {
            console.warn('Error loading game settings:', error);
            return this.getDefaultSettings();
        }
    }

    // Get default settings
    getDefaultSettings() {
        return {
            soundEnabled: true,
            vibrationEnabled: this.supportsVibration(),
            aiDifficulty: AI_DIFFICULTY.MEDIUM,
            gameMode: GAME_MODE.AI_OPPONENT,
            gameDuration: GAME_CONFIG.INITIAL_TIME
        };
    }

    // Save game settings
    saveGameSettings(settings) {
        try {
            localStorage.setItem(STORAGE_KEYS.GAME_SETTINGS, JSON.stringify(settings));
        } catch (error) {
            console.warn('Error saving game settings:', error);
        }
    }
}

// Global game instance
let gameInstance = null;

// Initialize game when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    gameInstance = new XOArenaGame();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = XOArenaGame;
}
