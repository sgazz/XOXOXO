class Board {
    constructor(scene, x, y, boardIndex, config = {}) {
        this.scene = scene;
        this.x = x;
        this.y = y;
        this.boardIndex = boardIndex;
        this.config = {
            size: 120,
            cellSize: 40,
            spacing: 2,
            ...config
        };
        
        this.state = ['', '', '', '', '', '', '', '', '']; // 3x3 board
        this.cells = [];
        this.isActive = false;
        this.isWon = false;
        this.winner = null;
        
        this.createBoard();
    }

    // Create board visual elements
    createBoard() {
        // Board background
        this.boardBg = this.scene.add.graphics();
        this.boardBg.fillStyle(0x1a1a2e, 0.8);
        this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        this.boardBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        
        // Create cells
        for (let row = 0; row < 3; row++) {
            for (let col = 0; col < 3; col++) {
                const cellIndex = row * 3 + col;
                const cellX = this.x + col * (this.config.cellSize + this.config.spacing) + this.config.spacing;
                const cellY = this.y + row * (this.config.cellSize + this.config.spacing) + this.config.spacing;
                
                // Cell background
                const cellBg = this.scene.add.graphics();
                cellBg.fillStyle(0x333333, 0.8);
                cellBg.fillRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                cellBg.lineStyle(1, COLORS.PRIMARY_GOLD, 0.4);
                cellBg.strokeRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                
                // Cell text (X or O)
                const cellText = this.scene.add.text(
                    cellX + this.config.cellSize / 2,
                    cellY + this.config.cellSize / 2,
                    '',
                    {
                        fontFamily: 'Inter',
                        fontSize: '1.5rem',
                        fontWeight: '800',
                        color: COLORS.WHITE
                    }
                ).setOrigin(0.5);
                
                // Interactive area
                const cellArea = this.scene.add.zone(
                    cellX + this.config.cellSize / 2,
                    cellY + this.config.cellSize / 2,
                    this.config.cellSize,
                    this.config.cellSize
                );
                cellArea.setInteractive();
                
                // Hover effects
                cellArea.on('pointerover', () => {
                    if (this.isActive && this.state[cellIndex] === '') {
                        cellBg.clear();
                        cellBg.fillStyle(COLORS.PRIMARY_GOLD, 0.2);
                        cellBg.fillRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                        cellBg.lineStyle(1, COLORS.PRIMARY_GOLD, 0.8);
                        cellBg.strokeRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                    }
                });
                
                cellArea.on('pointerout', () => {
                    if (this.state[cellIndex] === '') {
                        cellBg.clear();
                        cellBg.fillStyle(0x333333, 0.8);
                        cellBg.fillRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                        cellBg.lineStyle(1, COLORS.PRIMARY_GOLD, 0.4);
                        cellBg.strokeRoundedRect(cellX, cellY, this.config.cellSize, this.config.cellSize, 4);
                    }
                });
                
                cellArea.on('pointerdown', () => {
                    if (this.isActive && this.state[cellIndex] === '') {
                        if (this.makeMove(cellIndex)) {
                            // Notify scene about the move
                            if (this.scene.handleMoveResult) {
                                this.scene.handleMoveResult(this.boardIndex, cellIndex);
                            }
                        }
                    }
                });
                
                this.cells.push({
                    bg: cellBg,
                    text: cellText,
                    area: cellArea,
                    x: cellX,
                    y: cellY,
                    index: cellIndex
                });
            }
        }
    }

    // Make a move on this board
    makeMove(cellIndex) {
        if (this.state[cellIndex] !== '' || this.isWon) return false;
        
        const currentPlayer = this.scene.currentPlayer;
        this.state[cellIndex] = currentPlayer;
        this.cells[cellIndex].text.setText(currentPlayer);
        
        // Set text color based on player
        const textColor = currentPlayer === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE;
        this.cells[cellIndex].text.setColor(textColor);
        
        // Disable cell interaction
        this.cells[cellIndex].area.disableInteractive();
        
        // Check for win
        if (this.checkWin(currentPlayer)) {
            this.handleWin(currentPlayer);
        } else if (this.checkDraw()) {
            this.handleDraw();
        }
        
        return true;
    }

    // Check if a player has won
    checkWin(player) {
        const winCombinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6] // Diagonals
        ];
        
        return winCombinations.some(combination => {
            return combination.every(index => this.state[index] === player);
        });
    }

    // Check if board is a draw
    checkDraw() {
        return this.state.every(cell => cell !== '');
    }

    // Handle win
    handleWin(player) {
        this.isWon = true;
        this.winner = player;
        
        // Highlight winning cells
        this.highlightWinningCells(player);
        
        // Update board appearance
        this.boardBg.clear();
        this.boardBg.fillStyle(player === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE, 0.3);
        this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        this.boardBg.lineStyle(3, player === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE, 1);
        this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        
        // Disable all cells
        this.cells.forEach(cell => {
            cell.area.disableInteractive();
        });
    }

    // Handle draw
    handleDraw() {
        this.isWon = true;
        this.winner = 'draw';
        
        // Update board appearance for draw
        this.boardBg.clear();
        this.boardBg.fillStyle(0x666666, 0.3);
        this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        this.boardBg.lineStyle(3, 0x666666, 1);
        this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        
        // Disable all cells
        this.cells.forEach(cell => {
            cell.area.disableInteractive();
        });
    }

    // Highlight winning cells
    highlightWinningCells(player) {
        const winCombinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6] // Diagonals
        ];
        
        const winningCombination = winCombinations.find(combination => {
            return combination.every(index => this.state[index] === player);
        });
        
        if (winningCombination) {
            winningCombination.forEach(index => {
                const cell = this.cells[index];
                cell.bg.clear();
                cell.bg.fillStyle(player === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE, 0.5);
                cell.bg.fillRoundedRect(cell.x, cell.y, this.config.cellSize, this.config.cellSize, 4);
                cell.bg.lineStyle(2, player === 'X' ? COLORS.PRIMARY_BLUE : COLORS.PRIMARY_ORANGE, 1);
                cell.bg.strokeRoundedRect(cell.x, cell.y, this.config.cellSize, this.config.cellSize, 4);
            });
        }
    }

    // Set board as active/inactive
    setActive(active) {
        this.isActive = active;
        
        if (active) {
            this.boardBg.clear();
            this.boardBg.fillStyle(0x1a1a2e, 0.8);
            this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
            this.boardBg.lineStyle(3, COLORS.PRIMARY_GOLD, 1);
            this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        } else {
            this.boardBg.clear();
            this.boardBg.fillStyle(0x1a1a2e, 0.8);
            this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
            this.boardBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
            this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        }
    }

    // Reset board
    reset() {
        this.state = ['', '', '', '', '', '', '', '', ''];
        this.isWon = false;
        this.winner = null;
        this.isActive = false;
        
        // Reset visual elements
        this.boardBg.clear();
        this.boardBg.fillStyle(0x1a1a2e, 0.8);
        this.boardBg.fillRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        this.boardBg.lineStyle(2, COLORS.PRIMARY_GOLD, 0.6);
        this.boardBg.strokeRoundedRect(this.x, this.y, this.config.size, this.config.size, 8);
        
        // Reset cells
        this.cells.forEach(cell => {
            cell.text.setText('');
            cell.text.setColor(COLORS.WHITE);
            cell.bg.clear();
            cell.bg.fillStyle(0x333333, 0.8);
            cell.bg.fillRoundedRect(cell.x, cell.y, this.config.cellSize, this.config.cellSize, 4);
            cell.bg.lineStyle(1, COLORS.PRIMARY_GOLD, 0.4);
            cell.bg.strokeRoundedRect(cell.x, cell.y, this.config.cellSize, this.config.cellSize, 4);
            cell.area.setInteractive();
        });
    }

    // Get board state
    getState() {
        return this.state;
    }
    
    // Get board info
    getBoardInfo() {
        return {
            state: this.state,
            isWon: this.isWon,
            winner: this.winner,
            isActive: this.isActive
        };
    }

    // Destroy board
    destroy() {
        this.boardBg.destroy();
        this.cells.forEach(cell => {
            cell.bg.destroy();
            cell.text.destroy();
            cell.area.destroy();
        });
        this.cells = [];
    }
}
