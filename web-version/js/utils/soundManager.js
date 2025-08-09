class SoundManager {
    constructor() {
        this.sounds = {};
        this.isEnabled = this.loadSoundSetting();
        this.audioContext = null;
        this.initAudioContext();
    }

    // Initialize Web Audio API context
    initAudioContext() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        } catch (e) {
            console.warn('Web Audio API not supported');
        }
    }

    // Load sound setting from localStorage
    loadSoundSetting() {
        const saved = localStorage.getItem(STORAGE_KEYS.SOUND_ENABLED);
        return saved !== null ? JSON.parse(saved) : true;
    }

    // Save sound setting to localStorage
    saveSoundSetting(enabled) {
        this.isEnabled = enabled;
        localStorage.setItem(STORAGE_KEYS.SOUND_ENABLED, JSON.stringify(enabled));
    }

    // Toggle sound on/off
    toggleSound() {
        this.saveSoundSetting(!this.isEnabled);
        return this.isEnabled;
    }

    // Preload all sounds
    preloadSounds(scene) {
        const soundFiles = {
            [SOUNDS.MOVE]: 'assets/sounds/move.wav',
            [SOUNDS.WIN]: 'assets/sounds/win.wav',
            [SOUNDS.LOSE]: 'assets/sounds/lose.wav',
            [SOUNDS.DRAW]: 'assets/sounds/draw.wav',
            [SOUNDS.TAP]: 'assets/sounds/tap.wav',
            [SOUNDS.ERROR]: 'assets/sounds/error.wav'
        };

        Object.keys(soundFiles).forEach(key => {
            scene.load.audio(key, soundFiles[key]);
        });
    }

    // Play sound effect
    playSound(soundType) {
        if (!this.isEnabled || !this.audioContext) return;

        try {
            // Resume audio context if suspended (required for mobile browsers)
            if (this.audioContext.state === 'suspended') {
                this.audioContext.resume();
            }

            // Create oscillator for simple sound effects
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            // Configure sound based on type
            switch (soundType) {
                case SOUNDS.MOVE:
                    this.playMoveSound(oscillator, gainNode);
                    break;
                case SOUNDS.WIN:
                    this.playWinSound(oscillator, gainNode);
                    break;
                case SOUNDS.LOSE:
                    this.playLoseSound(oscillator, gainNode);
                    break;
                case SOUNDS.DRAW:
                    this.playDrawSound(oscillator, gainNode);
                    break;
                case SOUNDS.TAP:
                    this.playTapSound(oscillator, gainNode);
                    break;
                case SOUNDS.ERROR:
                    this.playErrorSound(oscillator, gainNode);
                    break;
                default:
                    console.warn(`Unknown sound type: ${soundType}`);
            }
        } catch (error) {
            console.warn('Error playing sound:', error);
        }
    }

    // Move sound - short, positive tone
    playMoveSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(800, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(1200, this.audioContext.currentTime + 0.1);
        
        gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.1);
    }

    // Win sound - ascending, triumphant
    playWinSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(400, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(800, this.audioContext.currentTime + 0.2);
        oscillator.frequency.exponentialRampToValueAtTime(1200, this.audioContext.currentTime + 0.4);
        
        gainNode.gain.setValueAtTime(0.4, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.4);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.4);
    }

    // Lose sound - descending, negative
    playLoseSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(600, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(300, this.audioContext.currentTime + 0.3);
        
        gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.3);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.3);
    }

    // Draw sound - neutral, medium tone
    playDrawSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(500, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(700, this.audioContext.currentTime + 0.15);
        oscillator.frequency.exponentialRampToValueAtTime(500, this.audioContext.currentTime + 0.3);
        
        gainNode.gain.setValueAtTime(0.25, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.3);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.3);
    }

    // Tap sound - very short, light
    playTapSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(1000, this.audioContext.currentTime);
        
        gainNode.gain.setValueAtTime(0.2, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.05);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.05);
    }

    // Error sound - harsh, negative
    playErrorSound(oscillator, gainNode) {
        oscillator.frequency.setValueAtTime(200, this.audioContext.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(100, this.audioContext.currentTime + 0.2);
        
        gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.2);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.2);
    }

    // Play haptic feedback (for mobile devices)
    playHaptic() {
        if ('vibrate' in navigator) {
            try {
                navigator.vibrate(50); // Short vibration
            } catch (e) {
                console.warn('Vibration not supported');
            }
        }
    }

    // Play light haptic feedback
    playLightHaptic() {
        if ('vibrate' in navigator) {
            try {
                navigator.vibrate(20); // Very short vibration
            } catch (e) {
                console.warn('Vibration not supported');
            }
        }
    }
}

// Create global instance
const soundManager = new SoundManager();
