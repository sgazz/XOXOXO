class GameScene extends Phaser.Scene {
    constructor() {
        super({ key: 'GameScene' });
        this.boards = [];
        this.currentBoard = 0;
        this.currentPlayer = 'X';
        this.gameMode = GAME_MODE.AI_OPPONENT;
        this.aiDifficulty = AI_DIFFICULTY.MEDIUM;
        this.gameOver = false;
        this.isThinking = false;
        this.totalScore = { x: 0, o: 0 };
        this.boardScores = [];
        this.lastMoveTime = Date.now();
        
        // Components
        this.timer = null;
        this.scoreDisplay = null;
        this.ai = null;
    }

    init(data) {
        this.gameMode = data.gameMode || GAME_MODE.AI_OPPONENT;
        this.aiDifficulty = data.aiDifficulty || AI_DIFFICULTY.MEDIUM;
        console.log('GameScene: Initializing with mode:', this.gameMode, 'difficulty:', this.aiDifficulty);
        
        // Track game start
        if (analytics) {
            analytics.trackGameStart(this.gameMode, this.aiDifficulty);
        }
    }

    create() {
        console.log('GameScene: Creating game scene');
        
        // Initialize game state
        this.initializeGameState();
        
        // Create background
        this.createBackground();
        
        // Create components
        this.createComponents();
        
        // Create game boards
        this.createBoards();
        
        // Setup input handlers
        this.setupInputHandlers();
        
        // If AI goes first
        if (this.gameMode === GAME_MODE.AI_OPPONENT) {
            this.makeAIMove();
        }
    }

    // Initialize game state
    initializeGameState() {
        // Initialize boards
        for (let i = 0; i < GAME_CONFIG.BOARD_COUNT; i++) {
            this.boards[i] = Array(9).fill('');
            this.boardScores[i] = { x: 0, o: 0 };
        }
        
        // Reset game state
        this.currentBoard = 0;
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.isThinking = false;
        this.totalScore = { x: 0, o: 0 };
        this.lastMoveTime = Date.now();
    }

    // Create background
    createBackground() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Clean background
        this.background = this.add.graphics();
        this.background.fillStyle(0x000000, 1);
        this.background.fillRect(0, 0, width, height);
        
        // Add floating lights
        this.createFloatingLights();
    }

    // Create floating lights
    createFloatingLights() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Green light (top center)
        const greenLight = this.add.graphics();
        greenLight.fillStyle(COLORS.PRIMARY_GREEN, 0.05);
        greenLight.fillCircle(width / 2, height * 0.1, 200);
        
        // Blue light (top left)
        const blueLight = this.add.graphics();
        blueLight.fillStyle(COLORS.PRIMARY_BLUE, 0.03);
        blueLight.fillCircle(width * 0.2, height * 0.2, 150);
        
        // Orange light (top right)
        const orangeLight = this.add.graphics();
        orangeLight.fillStyle(COLORS.PRIMARY_ORANGE, 0.03);
        orangeLight.fillCircle(width * 0.8, height * 0.2, 150);
    }

    // Create components
    createComponents() {
        // Create timer
        this.timer = new Timer(this, 0, 0);
        this.timer.setTimeoutCallback((timeoutPlayer, winner) => {
            this.handleTimeout(timeoutPlayer, winner);
        });
        
        // Create score display
        this.scoreDisplay = new ScoreDisplay(this, 0, 0);
        
        // Create AI
        this.ai = new AI(this.aiDifficulty);
        
        // Create pause button
        this.createPauseButton();
    }

    // Create pause button
    createPauseButton() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Pause button
        const pauseButton = this.add.graphics();
        pauseButton.fillStyle(COLORS.PRIMARY_GREEN, 0.8);
        pauseButton.fillCircle(width - 50, 50, 25);
        pauseButton.lineStyle(3, COLORS.PRIMARY_GREEN);
        pauseButton.strokeCircle(width - 50, 50, 25);
        
        // Pause icon
        const pauseIcon = this.add.text(width - 50, 50, '⏸', {
            fontFamily: 'Orbitron',
            fontSize: '1.2rem',
            color: COLORS.PRIMARY_GREEN,
            stroke: COLORS.PRIMARY_GREEN,
            strokeThickness: 1,
            shadow: {
                offsetX: 0,
                offsetY: 0,
                color: COLORS.PRIMARY_GREEN,
                blur: 15,
                fill: true
            }
        }).setOrigin(0.5);
        
        // Make interactive
        const pauseArea = this.add.zone(width - 50, 50, 50, 50);
        pauseArea.setInteractive();
        pauseArea.on('pointerdown', () => {
            this.pauseGame();
        });
    }

    // Create game boards
    createBoards() {
        const width = this.cameras.main.width;
        const height = this.cameras.main.height;
        
        // Calculate board layout
        const boardSize = Math.min(width, height) * 0.15;
        const spacing = boardSize * 0.1;
        const startX = (width - (4 * boardSize + 3 * spacing)) / 2;
        const startY = height * 0.25;
        
        for (let i = 0; i < GAME_CONFIG.BOARD_COUNT; i++) {
            const row = Math.floor(i / 4);
            const col = i % 4;
            const x = startX + col * (boardSize + spacing);
            const y = startY + row * (boardSize + spacing);
            
            this.createBoard(i, x, y, boardSize);
        }
        
        // Highlight current board
        this.highlightCurrentBoard();
    }

    // Create individual board
    createBoard(boardIndex, x, y, size) {
        // Use Board class from Board.js
        const board = new Board(this, x, y, boardIndex, {
            size: size,
            cellSize: size / 3,
            spacing: 2
        });
        
        // Store board instance
        this.boards[boardIndex] = board;
    }

    // Create individual cell (no longer needed - handled by Board class)
    createCell(boardIndex, cellIndex, x, y, size) {
        // This method is no longer used - Board class handles cell creation
        console.warn('createCell method is deprecated - use Board class instead');
    }

    // Handle cell click
    handleCellClick(boardIndex, cellIndex) {
        if (this.gameOver || this.isThinking) return;
        if (boardIndex !== this.currentBoard) return;
        
        // Use Board class method
        const board = this.boards[boardIndex];
        if (board && board.makeMove(cellIndex)) {
            // Move was successful
            this.handleMoveResult(boardIndex, cellIndex);
        }
    }

    // Handle move result
    handleMoveResult(boardIndex, cellIndex) {
        // Update statistics
        const moveTime = Date.now() - this.lastMoveTime;
        this.lastMoveTime = Date.now();
        statisticsManager.updateMoveStats(this.currentPlayer, moveTime / 1000, cellIndex);
        
        // Track move
        if (analytics) {
            analytics.trackMove(boardIndex, cellIndex, this.currentPlayer, moveTime / 1000);
        }
        
        // Play sound
        soundManager.playSound(SOUNDS.MOVE);
        soundManager.playHaptic();
        
        // Check for win
        if (this.checkBoardWin(boardIndex)) {
            this.handleBoardWin(boardIndex);
        } else if (this.checkBoardDraw(boardIndex)) {
            this.handleBoardDraw(boardIndex);
        } else {
            // Switch player
            this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
            this.currentBoard = (boardIndex + 1) % GAME_CONFIG.BOARD_COUNT;
            
            // Update timer
            this.timer.setCurrentPlayer(this.currentPlayer);
            
            // Highlight current board
            this.highlightCurrentBoard();
            
            // AI move if needed
            if (this.gameMode === GAME_MODE.AI_OPPONENT && this.currentPlayer === 'O') {
                this.makeAIMove();
            }
        }
    }

    // Check board win
    checkBoardWin(boardIndex) {
        const board = this.boards[boardIndex];
        if (!board) return null;
        
        return board.checkWin(this.currentPlayer);
    }

    // Check board draw
    checkBoardDraw(boardIndex) {
        const board = this.boards[boardIndex];
        if (!board) return false;
        
        return board.checkDraw();
    }

    // Handle board win
    handleBoardWin(boardIndex) {
        const winner = this.currentPlayer;
        
        // Update score
        this.totalScore[winner.toLowerCase()]++;
        this.scoreDisplay.updateScore(this.totalScore);
        
        // Update statistics
        statisticsManager.updateGameResult(winner);
        
        // Track board win
        if (analytics) {
            analytics.trackBoardWin(boardIndex, winner);
        }
        
        // Play win sound
        soundManager.playSound(SOUNDS.WIN);
        
        // Award bonus time to winner
        this.timer.awardBonusTime(winner);
        
        // Apply penalty to loser
        const loser = winner === 'X' ? 'O' : 'X';
        this.timer.applyPenaltyTime(loser);
        
        // Highlight winning cells
        this.highlightWinningCells(boardIndex);
        
        // Check game over
        if (this.totalScore.x >= 4 || this.totalScore.o >= 4) {
            this.endGame(winner);
        } else {
            // Reset board
            this.resetBoard(boardIndex);
            this.currentBoard = (boardIndex + 1) % GAME_CONFIG.BOARD_COUNT;
            this.highlightCurrentBoard();
        }
    }

    // Handle board draw
    handleBoardDraw(boardIndex) {
        // Track board draw
        if (analytics) {
            analytics.trackBoardDraw(boardIndex);
        }
        
        // Play draw sound
        soundManager.playSound(SOUNDS.DRAW);
        
        // Apply draw penalty
        this.timer.applyDrawPenalty();
        
        // Reset board
        this.resetBoard(boardIndex);
        this.currentBoard = (boardIndex + 1) % GAME_CONFIG.BOARD_COUNT;
        this.highlightCurrentBoard();
    }

    // Reset board
    resetBoard(boardIndex) {
        const board = this.boards[boardIndex];
        if (board) {
            board.reset();
        }
    }

    // Highlight current board
    highlightCurrentBoard() {
        this.boards.forEach((board, index) => {
            if (board) {
                const isActive = index === this.currentBoard;
                board.setActive(isActive);
            }
        });
    }

    // Highlight winning cells
    highlightWinningCells(boardIndex) {
        const board = this.boards[boardIndex];
        if (board) {
            board.highlightWinningCells(this.currentPlayer);
        }
    }

    // Make AI move
    makeAIMove() {
        this.isThinking = true;
        
        const board = this.boards[this.currentBoard];
        if (!board) {
            this.isThinking = false;
            return;
        }
        
        // Get available moves
        const availableMoves = board.getState().map((cell, index) => cell === '' ? index : null).filter(index => index !== null);
        
        // Get AI move
        const move = this.ai.getMove(board.getState(), availableMoves);
        
        if (move !== null && board.getState()[move] === '') {
            // Make AI move with delay
            this.ai.getMoveWithDelay(board.getState(), availableMoves, (aiMove) => {
                if (aiMove !== null && board.getState()[aiMove] === '') {
                    board.makeMove(aiMove);
                    this.handleMoveResult(this.currentBoard, aiMove);
                }
                this.isThinking = false;
            });
        } else {
            this.isThinking = false;
        }
    }

    // Handle timeout
    handleTimeout(timeoutPlayer, winner) {
        this.gameOver = true;
        
        // Track timeout
        if (analytics) {
            analytics.trackTimeout(timeoutPlayer);
        }
        
        // Show game over
        this.scene.start('GameOverScene', {
            winner: winner,
            reason: 'timeout',
            timeoutPlayer: timeoutPlayer,
            score: this.totalScore
        });
    }

    // End game
    endGame(winner) {
        this.gameOver = true;
        
        // Track game end
        if (analytics) {
            const duration = Date.now() - this.lastMoveTime;
            analytics.trackGameEnd(winner, 'victory', this.totalScore, duration);
        }
        
        soundManager.playSound(SOUNDS.WIN);
        
        // Show game over
        this.scene.start('GameOverScene', {
            winner: winner,
            reason: 'victory',
            score: this.totalScore
        });
    }

    // Pause game
    pauseGame() {
        this.scene.pause();
        // TODO: Show pause menu
    }

    // Setup input handlers
    setupInputHandlers() {
        this.input.keyboard.on('keydown', (event) => {
            switch (event.key) {
                case 'Escape':
                    this.pauseGame();
                    break;
            }
        });
    }

    // Handle resize
    handleResize() {
        // TODO: Implement resize handling
    }
}
