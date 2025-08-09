class StatisticsManager {
    constructor() {
        this.playerStats = this.loadPlayerStats();
    }

    // Player statistics structure
    createPlayerStats() {
        return {
            totalGames: 0,
            gamesWon: 0,
            totalMoves: 0,
            averageMoveTime: 0,
            centerMoves: 0,
            cornerMoves: 0,
            edgeMoves: 0,
            longestWinStreak: 0,
            currentWinStreak: 0
        };
    }

    // Load player statistics from localStorage
    loadPlayerStats() {
        try {
            const xData = localStorage.getItem(STORAGE_KEYS.PLAYER_STATS_X);
            const oData = localStorage.getItem(STORAGE_KEYS.PLAYER_STATS_O);
            
            const xStats = xData ? JSON.parse(xData) : this.createPlayerStats();
            const oStats = oData ? JSON.parse(oData) : this.createPlayerStats();
            
            return { x: xStats, o: oStats };
        } catch (error) {
            console.warn('Error loading player stats:', error);
            return { x: this.createPlayerStats(), o: this.createPlayerStats() };
        }
    }

    // Save player statistics to localStorage
    savePlayerStats() {
        try {
            localStorage.setItem(STORAGE_KEYS.PLAYER_STATS_X, JSON.stringify(this.playerStats.x));
            localStorage.setItem(STORAGE_KEYS.PLAYER_STATS_O, JSON.stringify(this.playerStats.o));
        } catch (error) {
            console.warn('Error saving player stats:', error);
        }
    }

    // Reset all statistics
    resetStatistics() {
        this.playerStats.x = this.createPlayerStats();
        this.playerStats.o = this.createPlayerStats();
        this.savePlayerStats();
    }

    // Update move statistics
    updateMoveStats(player, moveTime, position) {
        const stats = this.playerStats[player.toLowerCase()];
        
        stats.totalMoves++;
        stats.averageMoveTime = (stats.averageMoveTime * (stats.totalMoves - 1) + moveTime) / stats.totalMoves;
        
        // Update position statistics
        if (position === 4) {
            stats.centerMoves++;
        } else if ([0, 2, 6, 8].includes(position)) {
            stats.cornerMoves++;
        } else {
            stats.edgeMoves++;
        }
        
        this.savePlayerStats();
    }

    // Update game result
    updateGameResult(winner) {
        if (winner === 'X') {
            this.playerStats.x.gamesWon++;
            this.playerStats.x.totalGames++;
            this.playerStats.o.totalGames++;
            
            this.playerStats.x.currentWinStreak++;
            this.playerStats.o.currentWinStreak = 0;
            
            if (this.playerStats.x.currentWinStreak > this.playerStats.x.longestWinStreak) {
                this.playerStats.x.longestWinStreak = this.playerStats.x.currentWinStreak;
            }
        } else if (winner === 'O') {
            this.playerStats.o.gamesWon++;
            this.playerStats.o.totalGames++;
            this.playerStats.x.totalGames++;
            
            this.playerStats.o.currentWinStreak++;
            this.playerStats.x.currentWinStreak = 0;
            
            if (this.playerStats.o.currentWinStreak > this.playerStats.o.longestWinStreak) {
                this.playerStats.o.longestWinStreak = this.playerStats.o.currentWinStreak;
            }
        } else {
            // Draw
            this.playerStats.x.totalGames++;
            this.playerStats.o.totalGames++;
            this.playerStats.x.currentWinStreak = 0;
            this.playerStats.o.currentWinStreak = 0;
        }
        
        this.savePlayerStats();
    }

    // Get win rate for a player
    getWinRate(player) {
        const stats = this.playerStats[player.toLowerCase()];
        return stats.totalGames > 0 ? (stats.gamesWon / stats.totalGames) * 100 : 0;
    }

    // Get draw rate for a player
    getDrawRate(player) {
        const stats = this.playerStats[player.toLowerCase()];
        return stats.totalGames > 0 ? ((stats.totalGames - stats.gamesWon) / stats.totalGames) * 100 : 0;
    }

    // Get most common move position for a player
    getMostCommonMove(player) {
        const stats = this.playerStats[player.toLowerCase()];
        const moves = [
            { type: 'center', count: stats.centerMoves },
            { type: 'corner', count: stats.cornerMoves },
            { type: 'edge', count: stats.edgeMoves }
        ];
        
        return moves.reduce((prev, current) => 
            (prev.count > current.count) ? prev : current
        );
    }

    // Get player statistics summary
    getPlayerStatsSummary(player) {
        const stats = this.playerStats[player.toLowerCase()];
        const winRate = this.getWinRate(player);
        const drawRate = this.getDrawRate(player);
        const mostCommonMove = this.getMostCommonMove(player);
        
        return {
            totalGames: stats.totalGames,
            gamesWon: stats.gamesWon,
            totalMoves: stats.totalMoves,
            averageMoveTime: stats.averageMoveTime,
            winRate: winRate,
            drawRate: drawRate,
            longestWinStreak: stats.longestWinStreak,
            currentWinStreak: stats.currentWinStreak,
            centerMoves: stats.centerMoves,
            cornerMoves: stats.cornerMoves,
            edgeMoves: stats.edgeMoves,
            mostCommonMove: mostCommonMove
        };
    }

    // Get overall game statistics
    getOverallStats() {
        const xStats = this.getPlayerStatsSummary('X');
        const oStats = this.getPlayerStatsSummary('O');
        
        return {
            totalGames: xStats.totalGames + oStats.totalGames,
            totalMoves: xStats.totalMoves + oStats.totalMoves,
            averageMoveTime: (xStats.averageMoveTime + oStats.averageMoveTime) / 2,
            xPlayer: xStats,
            oPlayer: oStats
        };
    }

    // Export statistics for backup
    exportStats() {
        return {
            timestamp: new Date().toISOString(),
            version: '1.0',
            stats: this.playerStats
        };
    }

    // Import statistics from backup
    importStats(data) {
        try {
            if (data && data.stats) {
                this.playerStats = data.stats;
                this.savePlayerStats();
                return true;
            }
            return false;
        } catch (error) {
            console.warn('Error importing stats:', error);
            return false;
        }
    }
}

// Create global instance
const statisticsManager = new StatisticsManager();

// Make it globally available
if (typeof window !== 'undefined') {
    window.statisticsManager = statisticsManager;
}
