class Analytics {
    constructor() {
        this.sessionId = this.generateSessionId();
        this.startTime = Date.now();
        this.events = [];
        this.isEnabled = this.loadAnalyticsSetting();
        
        this.init();
    }

    // Initialize analytics
    init() {
        if (!this.isEnabled) return;
        
        // Track page view
        this.trackEvent('page_view', {
            page: window.location.pathname,
            title: document.title,
            referrer: document.referrer
        });
        
        // Track session start
        this.trackEvent('session_start', {
            session_id: this.sessionId,
            user_agent: navigator.userAgent,
            screen_resolution: `${screen.width}x${screen.height}`,
            viewport: `${window.innerWidth}x${window.innerHeight}`
        });
        
        // Track beforeunload
        window.addEventListener('beforeunload', () => {
            this.trackEvent('session_end', {
                session_id: this.sessionId,
                duration: Date.now() - this.startTime
            });
        });
    }

    // Generate session ID
    generateSessionId() {
        return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    // Load analytics setting
    loadAnalyticsSetting() {
        const saved = localStorage.getItem('analytics_enabled');
        return saved !== null ? JSON.parse(saved) : true;
    }

    // Save analytics setting
    saveAnalyticsSetting(enabled) {
        this.isEnabled = enabled;
        localStorage.setItem('analytics_enabled', JSON.stringify(enabled));
    }

    // Track event
    trackEvent(eventName, parameters = {}) {
        if (!this.isEnabled) return;
        
        const event = {
            event: eventName,
            timestamp: Date.now(),
            session_id: this.sessionId,
            ...parameters
        };
        
        this.events.push(event);
        
        // Send to analytics service (in real app, you'd send to Google Analytics, etc.)
        this.sendToAnalytics(event);
        
        console.log('Analytics:', event);
    }

    // Send to analytics service
    sendToAnalytics(event) {
        // In a real app, you would send to Google Analytics, Mixpanel, etc.
        // For now, we'll just log to console
        if (window.gtag) {
            window.gtag('event', event.event, event);
        }
    }

    // Track game events
    trackGameStart(gameMode, aiDifficulty) {
        this.trackEvent('game_start', {
            game_mode: gameMode,
            ai_difficulty: aiDifficulty
        });
    }

    trackGameEnd(winner, reason, score, duration) {
        this.trackEvent('game_end', {
            winner: winner,
            reason: reason,
            score_x: score.x,
            score_o: score.o,
            duration: duration
        });
    }

    trackMove(boardIndex, cellIndex, player, moveTime) {
        this.trackEvent('move', {
            board_index: boardIndex,
            cell_index: cellIndex,
            player: player,
            move_time: moveTime
        });
    }

    trackBoardWin(boardIndex, winner) {
        this.trackEvent('board_win', {
            board_index: boardIndex,
            winner: winner
        });
    }

    trackBoardDraw(boardIndex) {
        this.trackEvent('board_draw', {
            board_index: boardIndex
        });
    }

    trackTimeout(player) {
        this.trackEvent('timeout', {
            player: player
        });
    }

    trackBonusTime(player, bonusAmount) {
        this.trackEvent('bonus_time', {
            player: player,
            bonus_amount: bonusAmount
        });
    }

    trackPenaltyTime(player, penaltyAmount) {
        this.trackEvent('penalty_time', {
            player: player,
            penalty_amount: penaltyAmount
        });
    }

    trackSettingsChange(setting, value) {
        this.trackEvent('settings_change', {
            setting: setting,
            value: value
        });
    }

    trackError(error, context) {
        this.trackEvent('error', {
            error: error,
            context: context
        });
    }

    // Get analytics data
    getAnalyticsData() {
        return {
            session_id: this.sessionId,
            start_time: this.startTime,
            duration: Date.now() - this.startTime,
            events: this.events,
            event_count: this.events.length
        };
    }

    // Export analytics data
    exportAnalyticsData() {
        return {
            timestamp: new Date().toISOString(),
            version: '1.0',
            data: this.getAnalyticsData()
        };
    }

    // Clear analytics data
    clearAnalyticsData() {
        this.events = [];
        this.startTime = Date.now();
        this.sessionId = this.generateSessionId();
    }
}

// Create global instance
const analytics = new Analytics();
