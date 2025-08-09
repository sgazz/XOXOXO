class AI {
    constructor(difficulty = AI_DIFFICULTY.MEDIUM) {
        this.difficulty = difficulty;
        this.winCombinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6] // Diagonals
        ];
    }

    // Set AI difficulty
    setDifficulty(difficulty) {
        this.difficulty = difficulty;
    }

    // Get AI move
    getMove(boardState, availableMoves) {
        switch (this.difficulty) {
            case AI_DIFFICULTY.EASY:
                return this.getEasyMove(availableMoves);
            case AI_DIFFICULTY.MEDIUM:
                return this.getMediumMove(boardState, availableMoves);
            case AI_DIFFICULTY.HARD:
                return this.getHardMove(boardState, availableMoves);
            default:
                return this.getMediumMove(boardState, availableMoves);
        }
    }

    // Easy AI - random moves
    getEasyMove(availableMoves) {
        if (availableMoves.length === 0) return null;
        return availableMoves[Math.floor(Math.random() * availableMoves.length)];
    }

    // Medium AI - basic strategy
    getMediumMove(boardState, availableMoves) {
        if (availableMoves.length === 0) return null;

        // Try to win
        const winningMove = this.findWinningMove(boardState, availableMoves, 'O');
        if (winningMove !== null) return winningMove;

        // Block opponent's win
        const blockingMove = this.findWinningMove(boardState, availableMoves, 'X');
        if (blockingMove !== null) return blockingMove;

        // Try to take center
        if (availableMoves.includes(4)) return 4;

        // Try to take corners
        const corners = [0, 2, 6, 8];
        const availableCorners = corners.filter(corner => availableMoves.includes(corner));
        if (availableCorners.length > 0) {
            return availableCorners[Math.floor(Math.random() * availableCorners.length)];
        }

        // Random move
        return this.getEasyMove(availableMoves);
    }

    // Hard AI - minimax algorithm
    getHardMove(boardState, availableMoves) {
        if (availableMoves.length === 0) return null;

        let bestScore = -Infinity;
        let bestMove = null;

        for (const move of availableMoves) {
            const newState = [...boardState];
            newState[move] = 'O';
            
            const score = this.minimax(newState, 0, false);
            
            if (score > bestScore) {
                bestScore = score;
                bestMove = move;
            }
        }

        return bestMove;
    }

    // Minimax algorithm
    minimax(boardState, depth, isMaximizing) {
        // Check for terminal states
        if (this.checkWin(boardState, 'O')) return 10 - depth;
        if (this.checkWin(boardState, 'X')) return depth - 10;
        if (this.checkDraw(boardState)) return 0;

        const availableMoves = this.getAvailableMoves(boardState);

        if (isMaximizing) {
            let bestScore = -Infinity;
            for (const move of availableMoves) {
                const newState = [...boardState];
                newState[move] = 'O';
                const score = this.minimax(newState, depth + 1, false);
                bestScore = Math.max(bestScore, score);
            }
            return bestScore;
        } else {
            let bestScore = Infinity;
            for (const move of availableMoves) {
                const newState = [...boardState];
                newState[move] = 'X';
                const score = this.minimax(newState, depth + 1, true);
                bestScore = Math.min(bestScore, score);
            }
            return bestScore;
        }
    }

    // Find winning move for a player
    findWinningMove(boardState, availableMoves, player) {
        for (const move of availableMoves) {
            const newState = [...boardState];
            newState[move] = player;
            
            if (this.checkWin(newState, player)) {
                return move;
            }
        }
        return null;
    }

    // Check if a player has won
    checkWin(boardState, player) {
        return this.winCombinations.some(combination => {
            return combination.every(index => boardState[index] === player);
        });
    }

    // Check if board is a draw
    checkDraw(boardState) {
        return boardState.every(cell => cell !== '');
    }

    // Get available moves
    getAvailableMoves(boardState) {
        return boardState
            .map((cell, index) => cell === '' ? index : null)
            .filter(index => index !== null);
    }

    // Get AI move with delay for realistic feel
    getMoveWithDelay(boardState, availableMoves, callback) {
        const delay = this.getDelayByDifficulty();
        
        setTimeout(() => {
            const move = this.getMove(boardState, availableMoves);
            callback(move);
        }, delay);
    }

    // Get delay based on difficulty
    getDelayByDifficulty() {
        switch (this.difficulty) {
            case AI_DIFFICULTY.EASY:
                return Math.random() * 1000 + 500; // 500-1500ms
            case AI_DIFFICULTY.MEDIUM:
                return Math.random() * 800 + 300; // 300-1100ms
            case AI_DIFFICULTY.HARD:
                return Math.random() * 600 + 200; // 200-800ms
            default:
                return Math.random() * 800 + 300;
        }
    }

    // Get AI difficulty name
    getDifficultyName() {
        switch (this.difficulty) {
            case AI_DIFFICULTY.EASY:
                return 'Lako';
            case AI_DIFFICULTY.MEDIUM:
                return 'Srednje';
            case AI_DIFFICULTY.HARD:
                return 'Teško';
            default:
                return 'Srednje';
        }
    }

    // Get AI difficulty description
    getDifficultyDescription() {
        switch (this.difficulty) {
            case AI_DIFFICULTY.EASY:
                return 'AI igra nasumično';
            case AI_DIFFICULTY.MEDIUM:
                return 'AI blokira i pokušava da pobedi';
            case AI_DIFFICULTY.HARD:
                return 'AI igra optimalno';
            default:
                return 'AI blokira i pokušava da pobedi';
        }
    }
}
