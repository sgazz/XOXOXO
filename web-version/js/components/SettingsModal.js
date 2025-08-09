class SettingsModal {
    constructor(scene) {
        this.scene = scene;
        this.isVisible = false;
        this.modalContainer = null;
        this.settings = this.loadSettings();
    }

    // Load settings
    loadSettings() {
        try {
            const saved = localStorage.getItem('game_settings');
            return saved ? JSON.parse(saved) : this.getDefaultSettings();
        } catch (error) {
            console.warn('Error loading settings:', error);
            return this.getDefaultSettings();
        }
    }

    // Get default settings
    getDefaultSettings() {
        return {
            soundEnabled: true,
            vibrationEnabled: true,
            aiDifficulty: AI_DIFFICULTY.MEDIUM,
            gameMode: GAME_MODE.AI_OPPONENT,
            gameDuration: GAME_CONFIG.INITIAL_TIME,
            analyticsEnabled: true
        };
    }

    // Save settings
    saveSettings(settings) {
        try {
            localStorage.setItem('game_settings', JSON.stringify(settings));
            this.settings = settings;
            
            // Track settings change
            if (analytics) {
                analytics.trackSettingsChange('settings_save', settings);
            }
        } catch (error) {
            console.warn('Error saving settings:', error);
        }
    }

    // Show settings modal
    show() {
        if (this.isVisible) return;
        
        this.isVisible = true;
        this.createModal();
    }

    // Hide settings modal
    hide() {
        if (!this.isVisible) return;
        
        this.isVisible = false;
        if (this.modalContainer) {
            this.modalContainer.destroy();
            this.modalContainer = null;
        }
    }

    // Create modal
    createModal() {
        const width = this.scene.cameras.main.width;
        const height = this.scene.cameras.main.height;
        
        // Modal background
        const modalBg = this.scene.add.graphics();
        modalBg.fillStyle(0x000000, 0.8);
        modalBg.fillRect(0, 0, width, height);
        
        // Modal container
        const modalWidth = 500;
        const modalHeight = 600;
        const modalX = width / 2;
        const modalY = height / 2;
        
        this.modalContainer = this.scene.add.container(modalX, modalY);
        
        // Modal background
        const modalContent = this.scene.add.graphics();
        modalContent.fillStyle(0x003300, 0.95);
        modalContent.fillRoundedRect(-modalWidth / 2, -modalHeight / 2, modalWidth, modalHeight, 16);
        modalContent.lineStyle(3, COLORS.PRIMARY_GREEN);
        modalContent.strokeRoundedRect(-modalWidth / 2, -modalHeight / 2, modalWidth, modalHeight, 16);
        
        // Title
        const title = this.scene.add.text(0, -modalHeight / 2 + 40, 'SETTINGS', {
            fontFamily: 'Orbitron',
            fontSize: '2rem',
            fontWeight: '900',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0.5);
        
        // Settings content
        this.createSettingsContent(modalWidth, modalHeight);
        
        // Close button
        const closeButton = this.createButton(0, modalHeight / 2 - 40, 120, 40, 'Zatvori', () => {
            this.hide();
        });
        
        // Add to container
        this.modalContainer.add([modalContent, title, closeButton.bg, closeButton.text]);
        
        // Fade in animation
        this.scene.tweens.add({
            targets: [modalBg, this.modalContainer],
            alpha: { from: 0, to: 1 },
            duration: 300,
            ease: 'Power2'
        });
    }

    // Create settings content
    createSettingsContent(modalWidth, modalHeight) {
        const startY = -modalHeight / 2 + 100;
        const spacing = 60;
        let currentY = startY;
        
        // Sound setting
        this.createToggleSetting('SOUND EFFECTS', this.settings.soundEnabled, (value) => {
            this.settings.soundEnabled = value;
            soundManager.saveSoundSetting(value);
            if (analytics) {
                analytics.trackSettingsChange('sound_enabled', value);
            }
        }, currentY);
        currentY += spacing;
        
        // Vibration setting
        this.createToggleSetting('VIBRATION', this.settings.vibrationEnabled, (value) => {
            this.settings.vibrationEnabled = value;
            if (analytics) {
                analytics.trackSettingsChange('vibration_enabled', value);
            }
        }, currentY);
        currentY += spacing;
        
        // AI Difficulty setting
        this.createDropdownSetting('AI DIFFICULTY', this.settings.aiDifficulty, [
            { value: AI_DIFFICULTY.EASY, label: 'EASY' },
            { value: AI_DIFFICULTY.MEDIUM, label: 'MEDIUM' },
            { value: AI_DIFFICULTY.HARD, label: 'HARD' }
        ], (value) => {
            this.settings.aiDifficulty = value;
            if (analytics) {
                analytics.trackSettingsChange('ai_difficulty', value);
            }
        }, currentY);
        currentY += spacing;
        
        // Game Duration setting
        this.createDropdownSetting('GAME DURATION', this.settings.gameDuration, [
            { value: 120, label: '2 MINUTES' },
            { value: 180, label: '3 MINUTES' },
            { value: 300, label: '5 MINUTES' }
        ], (value) => {
            this.settings.gameDuration = value;
            if (analytics) {
                analytics.trackSettingsChange('game_duration', value);
            }
        }, currentY);
        currentY += spacing;
        
        // Analytics setting
        this.createToggleSetting('ANALYTICS', this.settings.analyticsEnabled, (value) => {
            this.settings.analyticsEnabled = value;
            if (analytics) {
                analytics.saveAnalyticsSetting(value);
                analytics.trackSettingsChange('analytics_enabled', value);
            }
        }, currentY);
        currentY += spacing;
        
        // Save button
        const saveButton = this.createButton(0, currentY, 150, 50, 'SAVE', () => {
            this.saveSettings(this.settings);
            this.hide();
        });
        
        this.modalContainer.add([saveButton.bg, saveButton.text]);
    }

    // Create toggle setting
    createToggleSetting(label, value, onChange, y) {
        const labelText = this.scene.add.text(-150, y, label, {
            fontFamily: 'Orbitron',
            fontSize: '1.1rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0, 0.5);
        
        // Toggle button
        const toggleButton = this.scene.add.graphics();
        toggleButton.fillStyle(value ? COLORS.GREEN : COLORS.RED, 0.8);
        toggleButton.fillRoundedRect(50, y - 15, 60, 30, 15);
        toggleButton.lineStyle(2, COLORS.WHITE);
        toggleButton.strokeRoundedRect(50, y - 15, 60, 30, 15);
        
        // Toggle text
        const toggleText = this.scene.add.text(80, y, value ? 'ON' : 'OFF', {
            fontFamily: 'Orbitron',
            fontSize: '0.9rem',
            fontWeight: '700',
            color: COLORS.WHITE
        }).setOrigin(0.5);
        
        // Make interactive
        const toggleArea = this.scene.add.zone(80, y, 60, 30);
        toggleArea.setInteractive();
        toggleArea.on('pointerdown', () => {
            const newValue = !value;
            toggleButton.clear();
            toggleButton.fillStyle(newValue ? COLORS.GREEN : COLORS.RED, 0.8);
            toggleButton.fillRoundedRect(50, y - 15, 60, 30, 15);
            toggleButton.lineStyle(2, COLORS.WHITE);
            toggleButton.strokeRoundedRect(50, y - 15, 60, 30, 15);
            toggleText.setText(newValue ? 'ON' : 'OFF');
            
            onChange(newValue);
        });
        
        this.modalContainer.add([labelText, toggleButton, toggleText, toggleArea]);
    }

    // Create dropdown setting
    createDropdownSetting(label, value, options, onChange, y) {
        const labelText = this.scene.add.text(-150, y, label, {
            fontFamily: 'Orbitron',
            fontSize: '1.1rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0, 0.5);
        
        // Dropdown background
        const dropdownBg = this.scene.add.graphics();
        dropdownBg.fillStyle(0x003300, 0.8);
        dropdownBg.fillRoundedRect(50, y - 20, 120, 40, 8);
        dropdownBg.lineStyle(2, COLORS.PRIMARY_GREEN, 0.8);
        dropdownBg.strokeRoundedRect(50, y - 20, 120, 40, 8);
        
        // Current value text
        const currentOption = options.find(opt => opt.value === value);
        const valueText = this.scene.add.text(110, y, currentOption ? currentOption.label : 'UNKNOWN', {
            fontFamily: 'Orbitron',
            fontSize: '0.9rem',
            fontWeight: '500',
            color: COLORS.WHITE
        }).setOrigin(0.5);
        
        // Make interactive
        const dropdownArea = this.scene.add.zone(110, y, 120, 40);
        dropdownArea.setInteractive();
        dropdownArea.on('pointerdown', () => {
            this.showDropdownOptions(options, value, onChange, y);
        });
        
        this.modalContainer.add([labelText, dropdownBg, valueText, dropdownArea]);
    }

    // Show dropdown options
    showDropdownOptions(options, currentValue, onChange, y) {
        const dropdownWidth = 120;
        const optionHeight = 30;
        const startX = 50;
        const startY = y + 25;
        
        // Create options container
        const optionsContainer = this.scene.add.container(startX, startY);
        
        options.forEach((option, index) => {
            const optionY = index * optionHeight;
            
            // Option background
            const optionBg = this.scene.add.graphics();
            optionBg.fillStyle(option.value === currentValue ? COLORS.PRIMARY_GOLD : 0x333333, 0.8);
            optionBg.fillRoundedRect(0, optionY, dropdownWidth, optionHeight, 4);
            optionBg.lineStyle(1, COLORS.PRIMARY_GOLD, 0.6);
            optionBg.strokeRoundedRect(0, optionY, dropdownWidth, optionHeight, 4);
            
            // Option text
            const optionText = this.scene.add.text(dropdownWidth / 2, optionY + optionHeight / 2, option.label, {
                fontFamily: 'Inter',
                fontSize: '0.8rem',
                fontWeight: '500',
                color: COLORS.WHITE
            }).setOrigin(0.5);
            
            // Make interactive
            const optionArea = this.scene.add.zone(dropdownWidth / 2, optionY + optionHeight / 2, dropdownWidth, optionHeight);
            optionArea.setInteractive();
            optionArea.on('pointerdown', () => {
                onChange(option.value);
                optionsContainer.destroy();
            });
            
            optionsContainer.add([optionBg, optionText, optionArea]);
        });
        
        this.modalContainer.add(optionsContainer);
        
        // Auto-hide after 3 seconds
        this.scene.time.delayedCall(3000, () => {
            if (optionsContainer.active) {
                optionsContainer.destroy();
            }
        });
    }

    // Create button
    createButton(x, y, width, height, text, callback) {
        // Button background
        const buttonBg = this.scene.add.graphics();
        buttonBg.fillStyle(0x003300, 0.8);
        buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        buttonBg.lineStyle(2, COLORS.PRIMARY_GREEN, 0.8);
        buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        
        // Button text
        const buttonText = this.scene.add.text(x, y, text, {
            fontFamily: 'Orbitron',
            fontSize: '1rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_GREEN
        }).setOrigin(0.5);
        
        // Interactive area
        const buttonArea = this.scene.add.zone(x, y, width, height);
        buttonArea.setInteractive();
        
        // Hover effects
        buttonArea.on('pointerover', () => {
            buttonBg.clear();
            buttonBg.fillStyle(COLORS.PRIMARY_GOLD, 0.2);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GOLD, 1);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        });
        
        buttonArea.on('pointerout', () => {
            buttonBg.clear();
            buttonBg.fillStyle(0x333333, 0.8);
            buttonBg.fillRoundedRect(x - width / 2, y - height / 2, width, height, 8);
            buttonBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
            buttonBg.strokeRoundedRect(x - width / 2, y - height / 2, width, height, 8);
        });
        
        buttonArea.on('pointerdown', () => {
            soundManager.playSound(SOUNDS.TAP);
            soundManager.playHaptic();
            callback();
        });
        
        return { bg: buttonBg, text: buttonText, area: buttonArea };
    }

    // Get settings
    getSettings() {
        return this.settings;
    }

    // Update setting
    updateSetting(key, value) {
        this.settings[key] = value;
        this.saveSettings(this.settings);
    }
}
