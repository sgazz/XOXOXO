class ScoreDisplay {
    constructor(scene, x, y, config = {}) {
        this.scene = scene;
        this.x = x;
        this.y = y;
        this.config = {
            width: 300,
            height: 80,
            spacing: 20,
            ...config
        };
        
        this.score = { x: 0, o: 0 };
        this.createScoreDisplay();
    }

    // Create score display
    createScoreDisplay() {
        // Background
        this.background = this.scene.add.graphics();
        this.background.fillStyle(0x1a1a2e, 0.9);
        this.background.fillRoundedRect(this.x, this.y, this.config.width, this.config.height, 12);
        this.background.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        this.background.strokeRoundedRect(this.x, this.y, this.config.width, this.config.height, 12);
        
        // Player X score
        this.createPlayerScore('X', this.x + this.config.spacing, this.y + this.config.height / 2, COLORS.PRIMARY_BLUE);
        
        // VS text
        this.vsText = this.scene.add.text(
            this.x + this.config.width / 2,
            this.y + this.config.height / 2,
            'VS',
            {
                fontFamily: 'Inter',
                fontSize: '1.2rem',
                fontWeight: '700',
                color: COLORS.PRIMARY_GOLD
            }
        ).setOrigin(0.5);
        
        // Player O score
        this.createPlayerScore('O', this.x + this.config.width - this.config.spacing, this.y + this.config.height / 2, COLORS.PRIMARY_ORANGE);
    }

    // Create player score display
    createPlayerScore(player, x, y, color) {
        const isPlayerX = player === 'X';
        const xOffset = isPlayerX ? -40 : 40;
        
        // Player symbol
        this[`${player.toLowerCase()}Symbol`] = this.scene.add.text(
            x + xOffset,
            y - 15,
            player,
            {
                fontFamily: 'Inter',
                fontSize: '1.5rem',
                fontWeight: '800',
                color: color
            }
        ).setOrigin(0.5);
        
        // Score text
        this[`${player.toLowerCase()}ScoreText`] = this.scene.add.text(
            x + xOffset,
            y + 15,
            '0',
            {
                fontFamily: 'Inter',
                fontSize: '2rem',
                fontWeight: '900',
                color: COLORS.WHITE
            }
        ).setOrigin(0.5);
        
        // Score background
        this[`${player.toLowerCase()}ScoreBg`] = this.scene.add.graphics();
        this[`${player.toLowerCase()}ScoreBg`].fillStyle(color, 0.3);
        this[`${player.toLowerCase()}ScoreBg`].fillCircle(x + xOffset, y + 15, 20);
    }

    // Update score
    updateScore(score) {
        this.score = { ...score };
        
        // Update X score
        this.xScoreText.setText(this.score.x.toString());
        this.updateScoreBackground('x', this.score.x);
        
        // Update O score
        this.oScoreText.setText(this.score.o.toString());
        this.updateScoreBackground('o', this.score.o);
        
        // Highlight leading player
        this.highlightLeadingPlayer();
    }

    // Update score background
    updateScoreBackground(player, score) {
        const scoreBg = this[`${player}ScoreBg`];
        const color = player === 'x' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE;
        
        scoreBg.clear();
        scoreBg.fillStyle(color, 0.3);
        scoreBg.fillCircle(
            this.x + (player === 'x' ? this.config.spacing : this.config.width - this.config.spacing) + (player === 'x' ? -40 : 40),
            this.y + this.config.height / 2 + 15,
            20
        );
    }

    // Highlight leading player
    highlightLeadingPlayer() {
        const xScore = this.score.x;
        const oScore = this.score.o;
        
        // Reset all highlights
        this.xSymbol.setColor(COLORS.PRIMARY_BLUE);
        this.oSymbol.setColor(COLORS.PRIMARY_ORANGE);
        this.xScoreText.setColor(COLORS.WHITE);
        this.oScoreText.setColor(COLORS.WHITE);
        
        // Highlight leading player
        if (xScore > oScore) {
            this.xSymbol.setColor(COLORS.PRIMARY_GOLD);
            this.xScoreText.setColor(COLORS.PRIMARY_GOLD);
        } else if (oScore > xScore) {
            this.oSymbol.setColor(COLORS.PRIMARY_GOLD);
            this.oScoreText.setColor(COLORS.PRIMARY_GOLD);
        }
    }

    // Add point to player
    addPoint(player) {
        this.score[player.toLowerCase()]++;
        this.updateScore(this.score);
        
        // Animate score increase
        this.animateScoreIncrease(player);
    }

    // Animate score increase
    animateScoreIncrease(player) {
        const scoreText = this[`${player.toLowerCase()}ScoreText`];
        const originalScale = scoreText.scale;
        
        // Scale up
        this.scene.tweens.add({
            targets: scoreText,
            scaleX: 1.3,
            scaleY: 1.3,
            duration: 150,
            ease: 'Power2',
            yoyo: true,
            onComplete: () => {
                scoreText.setScale(originalScale);
            }
        });
        
        // Play sound
        soundManager.playSound(SOUNDS.WIN);
    }

    // Reset score
    resetScore() {
        this.score = { x: 0, o: 0 };
        this.updateScore(this.score);
    }

    // Get current score
    getScore() {
        return { ...this.score };
    }

    // Set score
    setScore(score) {
        this.score = { ...score };
        this.updateScore(this.score);
    }

    // Show winner animation
    showWinnerAnimation(winner) {
        if (!winner) return;
        
        const winnerSymbol = this[`${winner.toLowerCase()}Symbol`];
        const winnerScoreText = this[`${winner.toLowerCase()}ScoreText`];
        
        // Winner celebration animation
        this.scene.tweens.add({
            targets: [winnerSymbol, winnerScoreText],
            scaleX: 1.2,
            scaleY: 1.2,
            duration: 200,
            ease: 'Power2',
            yoyo: true,
            repeat: 2
        });
        
        // Particle effect
        this.createWinnerParticles(winner);
    }

    // Create winner particles
    createWinnerParticles(winner) {
        try {
            const color = winner === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE;
            const x = this.x + (winner === 'X' ? this.config.spacing : this.config.width - this.config.spacing) + (winner === 'X' ? -40 : 40);
            const y = this.y + this.config.height / 2;
            
            // Check if particle texture exists
            if (this.scene.textures.exists('particle-gold')) {
                // Create particle emitter
                const particles = this.scene.add.particles(x, y, 'particle-gold', {
                    speed: { min: 50, max: 100 },
                    scale: { start: 0.5, end: 0 },
                    lifespan: 1000,
                    quantity: 10,
                    tint: color
                });
                
                // Auto-destroy particles
                this.scene.time.delayedCall(1000, () => {
                    particles.destroy();
                });
            } else {
                console.log('ScoreDisplay: Particle texture not available, skipping particles');
            }
        } catch (error) {
            console.warn('ScoreDisplay: Error creating winner particles:', error);
        }
    }

    // Update display position
    updatePosition(x, y) {
        this.x = x;
        this.y = y;
        
        // Update background
        this.background.clear();
        this.background.fillStyle(0x1a1a2e, 0.9);
        this.background.fillRoundedRect(this.x, this.y, this.config.width, this.config.height, 12);
        this.background.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        this.background.strokeRoundedRect(this.x, this.y, this.config.width, this.config.height, 12);
        
        // Update VS text
        this.vsText.setPosition(this.x + this.config.width / 2, this.y + this.config.height / 2);
        
        // Update player scores
        this.updatePlayerScorePosition('X', this.x + this.config.spacing, this.y + this.config.height / 2);
        this.updatePlayerScorePosition('O', this.x + this.config.width - this.config.spacing, this.y + this.config.height / 2);
    }

    // Update player score position
    updatePlayerScorePosition(player, x, y) {
        const isPlayerX = player === 'X';
        const xOffset = isPlayerX ? -40 : 40;
        
        this[`${player.toLowerCase()}Symbol`].setPosition(x + xOffset, y - 15);
        this[`${player.toLowerCase()}ScoreText`].setPosition(x + xOffset, y + 15);
        
        this[`${player.toLowerCase()}ScoreBg`].clear();
        const color = player === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE;
        this[`${player.toLowerCase()}ScoreBg`].fillStyle(color, 0.3);
        this[`${player.toLowerCase()}ScoreBg`].fillCircle(x + xOffset, y + 15, 20);
    }

    // Destroy score display
    destroy() {
        this.background.destroy();
        this.vsText.destroy();
        this.xSymbol.destroy();
        this.oSymbol.destroy();
        this.xScoreText.destroy();
        this.oScoreText.destroy();
        this.xScoreBg.destroy();
        this.oScoreBg.destroy();
    }
}
