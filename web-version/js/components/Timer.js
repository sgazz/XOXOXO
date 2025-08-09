class Timer {
    constructor(scene, x, y, config = {}) {
        this.scene = scene;
        this.x = x;
        this.y = y;
        this.config = {
            initialTime: GAME_CONFIG.INITIAL_TIME,
            bonusTime: GAME_CONFIG.BONUS_TIME,
            penaltyTime: GAME_CONFIG.PENALTY_TIME,
            drawPenaltyTime: GAME_CONFIG.DRAW_PENALTY_TIME,
            ...config
        };
        
        this.playerXTime = this.config.initialTime;
        this.playerOTime = this.config.initialTime;
        this.isRunning = false;
        this.currentPlayer = 'X';
        this.timerEvent = null;
        
        this.createTimerDisplay();
        this.startTimer();
    }

    // Create timer display
    createTimerDisplay() {
        const width = this.scene.cameras.main.width;
        const height = this.scene.cameras.main.height;
        
        // Timer container
        this.timerContainer = this.scene.add.graphics();
        this.timerContainer.fillStyle(0x000000, 0.3);
        this.timerContainer.fillRoundedRect(width * 0.1, height * 0.05, width * 0.8, 80, 12);
        this.timerContainer.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        this.timerContainer.strokeRoundedRect(width * 0.1, height * 0.05, width * 0.8, 80, 12);
        
        // X Timer
        this.xTimerText = this.scene.add.text(width * 0.2, height * 0.15, this.formatTime(this.playerXTime), {
            fontFamily: 'Inter',
            fontSize: '1.5rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_BLUE
        }).setOrigin(0.5);
        
        // X Timer label
        this.xTimerLabel = this.scene.add.text(width * 0.2, height * 0.25, 'IGRAČ X', {
            fontFamily: 'Inter',
            fontSize: '0.9rem',
            fontWeight: '500',
            color: COLORS.WHITE,
            alpha: 0.8
        }).setOrigin(0.5);
        
        // O Timer
        this.oTimerText = this.scene.add.text(width * 0.8, height * 0.15, this.formatTime(this.playerOTime), {
            fontFamily: 'Inter',
            fontSize: '1.5rem',
            fontWeight: '700',
            color: COLORS.PRIMARY_ORANGE
        }).setOrigin(0.5);
        
        // O Timer label
        this.oTimerLabel = this.scene.add.text(width * 0.8, height * 0.25, 'IGRAČ O', {
            fontFamily: 'Inter',
            fontSize: '0.9rem',
            fontWeight: '500',
            color: COLORS.WHITE,
            alpha: 0.8
        }).setOrigin(0.5);
        
        // Current player indicator
        this.currentPlayerIndicator = this.scene.add.graphics();
        this.updateCurrentPlayerIndicator();
    }

    // Start timer
    startTimer() {
        this.isRunning = true;
        this.timerEvent = this.scene.time.addEvent({
            delay: 1000,
            callback: this.updateTimer,
            callbackScope: this,
            loop: true
        });
    }

    // Stop timer
    stopTimer() {
        this.isRunning = false;
        if (this.timerEvent) {
            this.timerEvent.destroy();
            this.timerEvent = null;
        }
    }

    // Update timer
    updateTimer() {
        if (!this.isRunning) return;
        
        if (this.currentPlayer === 'X') {
            this.playerXTime--;
            this.xTimerText.setText(this.formatTime(this.playerXTime));
            
            // Check for timeout
            if (this.playerXTime <= 0) {
                this.handleTimeout('X');
            }
        } else {
            this.playerOTime--;
            this.oTimerText.setText(this.formatTime(this.playerOTime));
            
            // Check for timeout
            if (this.playerOTime <= 0) {
                this.handleTimeout('O');
            }
        }
    }

    // Format time
    formatTime(seconds) {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
    }

    // Set current player
    setCurrentPlayer(player) {
        this.currentPlayer = player;
        this.updateCurrentPlayerIndicator();
    }

    // Update current player indicator
    updateCurrentPlayerIndicator() {
        this.currentPlayerIndicator.clear();
        
        const width = this.scene.cameras.main.width;
        const height = this.scene.cameras.main.height;
        
        if (this.currentPlayer === 'X') {
            this.currentPlayerIndicator.fillStyle(COLORS.PRIMARY_BLUE, 0.3);
            this.currentPlayerIndicator.fillCircle(width * 0.2, height * 0.15, 30);
            this.xTimerText.setColor(COLORS.PRIMARY_BLUE);
            this.oTimerText.setColor(COLORS.WHITE);
        } else {
            this.currentPlayerIndicator.fillStyle(COLORS.PRIMARY_ORANGE, 0.3);
            this.currentPlayerIndicator.fillCircle(width * 0.8, height * 0.15, 30);
            this.oTimerText.setColor(COLORS.PRIMARY_ORANGE);
            this.xTimerText.setColor(COLORS.WHITE);
        }
    }

    // Award bonus time
    awardBonusTime(player) {
        if (player === 'X') {
            this.playerXTime += this.config.bonusTime;
            this.xTimerText.setText(this.formatTime(this.playerXTime));
            this.showBonusAnimation('X', true);
        } else {
            this.playerOTime += this.config.bonusTime;
            this.oTimerText.setText(this.formatTime(this.playerOTime));
            this.showBonusAnimation('O', true);
        }
        
        soundManager.playSound(SOUNDS.WIN);
    }

    // Apply penalty time
    applyPenaltyTime(player) {
        if (player === 'X') {
            this.playerXTime = Math.max(0, this.playerXTime - this.config.penaltyTime);
            this.xTimerText.setText(this.formatTime(this.playerXTime));
            this.showBonusAnimation('X', false);
        } else {
            this.playerOTime = Math.max(0, this.playerOTime - this.config.penaltyTime);
            this.oTimerText.setText(this.formatTime(this.playerOTime));
            this.showBonusAnimation('O', false);
        }
        
        soundManager.playSound(SOUNDS.LOSE);
    }

    // Apply draw penalty
    applyDrawPenalty() {
        this.playerXTime = Math.max(0, this.playerXTime - this.config.drawPenaltyTime);
        this.playerOTime = Math.max(0, this.playerOTime - this.config.drawPenaltyTime);
        
        this.xTimerText.setText(this.formatTime(this.playerXTime));
        this.oTimerText.setText(this.formatTime(this.playerOTime));
        
        this.showDrawPenaltyAnimation();
        soundManager.playSound(SOUNDS.DRAW);
    }

    // Show bonus/penalty animation
    showBonusAnimation(player, isBonus) {
        const width = this.scene.cameras.main.width;
        const x = player === 'X' ? width * 0.2 : width * 0.8;
        const y = this.scene.cameras.main.height * 0.15;
        
        const text = this.scene.add.text(x, y - 40, isBonus ? `+${this.config.bonusTime}s` : `-${this.config.penaltyTime}s`, {
            fontFamily: 'Inter',
            fontSize: '1.2rem',
            fontWeight: '700',
            color: isBonus ? COLORS.GREEN : COLORS.RED
        }).setOrigin(0.5);
        
        // Animate text
        this.scene.tweens.add({
            targets: text,
            scaleX: 1.3,
            scaleY: 1.3,
            alpha: 0,
            duration: 1500,
            ease: 'Power2',
            onComplete: () => {
                text.destroy();
            }
        });
    }

    // Show draw penalty animation
    showDrawPenaltyAnimation() {
        const width = this.scene.cameras.main.width;
        const height = this.scene.cameras.main.height;
        
        const text = this.scene.add.text(width / 2, height * 0.15, `-${this.config.drawPenaltyTime}s`, {
            fontFamily: 'Inter',
            fontSize: '1.2rem',
            fontWeight: '700',
            color: COLORS.ORANGE
        }).setOrigin(0.5);
        
        // Animate text
        this.scene.tweens.add({
            targets: text,
            scaleX: 1.3,
            scaleY: 1.3,
            alpha: 0,
            duration: 1500,
            ease: 'Power2',
            onComplete: () => {
                text.destroy();
            }
        });
    }

    // Handle timeout
    handleTimeout(player) {
        this.stopTimer();
        
        const winner = player === 'X' ? 'O' : 'X';
        
        // Show timeout message
        const width = this.scene.cameras.main.width;
        const height = this.scene.cameras.main.height;
        
        const timeoutText = this.scene.add.text(width / 2, height * 0.4, `VREME JE ISTEKLO ZA ${player}!`, {
            fontFamily: 'Inter',
            fontSize: '1.5rem',
            fontWeight: '700',
            color: COLORS.RED
        }).setOrigin(0.5);
        
        // Animate timeout text
        this.scene.tweens.add({
            targets: timeoutText,
            scaleX: 1.2,
            scaleY: 1.2,
            duration: 200,
            yoyo: true,
            repeat: 3,
            onComplete: () => {
                timeoutText.destroy();
                // Trigger game over
                if (this.onTimeoutCallback) {
                    this.onTimeoutCallback(player, winner);
                }
            }
        });
        
        soundManager.playSound(SOUNDS.LOSE);
    }

    // Reset timer
    resetTimer() {
        this.playerXTime = this.config.initialTime;
        this.playerOTime = this.config.initialTime;
        this.currentPlayer = 'X';
        
        this.xTimerText.setText(this.formatTime(this.playerXTime));
        this.oTimerText.setText(this.formatTime(this.playerOTime));
        this.updateCurrentPlayerIndicator();
        
        this.stopTimer();
        this.startTimer();
    }

    // Set timeout callback
    setTimeoutCallback(callback) {
        this.onTimeoutCallback = callback;
    }

    // Get current times
    getTimes() {
        return {
            x: this.playerXTime,
            o: this.playerOTime
        };
    }

    // Destroy timer
    destroy() {
        this.stopTimer();
        
        if (this.timerContainer) this.timerContainer.destroy();
        if (this.xTimerText) this.xTimerText.destroy();
        if (this.xTimerLabel) this.xTimerLabel.destroy();
        if (this.oTimerText) this.oTimerText.destroy();
        if (this.oTimerLabel) this.oTimerLabel.destroy();
        if (this.currentPlayerIndicator) this.currentPlayerIndicator.destroy();
    }
}
