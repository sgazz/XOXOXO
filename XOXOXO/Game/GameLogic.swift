import Foundation

enum GameMode {
    case aiOpponent
    case playerVsPlayer
}

class GameLogic: ObservableObject {
    static let BOARD_COUNT = 8 // Increased from 6 to 8 boards

    @Published var boards: [[String]]
    @Published var currentBoard: Int
    @Published var currentPlayer: String
    @Published var gameOver: Bool
    @Published var winner: String?
    @Published var isThinking: Bool
    @Published var boardScores: [(x: Int, o: Int)]
    @Published var totalScore: (x: Int, o: Int)
    @Published var gameMode: GameMode = .aiOpponent

    static let winningCombinations = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6]             // diagonal
    ]

    init(gameMode: GameMode = .aiOpponent) {
        self.boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        self.currentBoard = 0
        self.currentPlayer = "X"
        self.gameOver = false
        self.winner = nil
        self.isThinking = false
        self.boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        self.totalScore = (x: 0, o: 0)
        self.gameMode = gameMode
    }

    func makeMove(at position: Int, in boardIndex: Int) {
        boards[boardIndex][position] = currentPlayer

        // Check if this board is complete
        if checkBoardComplete(in: boardIndex) {
            // Update scores if there is a winner
            if let boardWinner = checkBoardWinner(in: boardIndex) {
                if boardWinner == "X" {
                    boardScores[boardIndex].x += 1
                    totalScore.x += 1
                } else {
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                }
            }
            // Reset this board
            boards[boardIndex] = Array(repeating: "", count: 9)
        }

        // Check if the entire game is over (tournament winner)
        checkTournamentWinner()

        if !gameOver {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
            // Always update board after any player move
            currentBoard = (boardIndex + 1) % Self.BOARD_COUNT
        }
    }

    private func checkBoardComplete(in boardIndex: Int) -> Bool {
        return checkBoardWinner(in: boardIndex) != nil || !boards[boardIndex].contains("")
    }

    private func checkBoardWinner(in boardIndex: Int) -> String? {
        for combination in Self.winningCombinations {
            if boards[boardIndex][combination[0]] != "" &&
               boards[boardIndex][combination[0]] == boards[boardIndex][combination[1]] &&
               boards[boardIndex][combination[1]] == boards[boardIndex][combination[2]] {
                return boards[boardIndex][combination[0]]
            }
        }
        return nil
    }

    private func checkTournamentWinner() {
        // Define winning score (e.g., first to 3 wins on any board)
        let winningScore = 3

        // Check if any player has reached the winning score on any board
        for score in boardScores {
            if score.x >= winningScore {
                gameOver = true
                winner = "X"
                return
            }
            if score.o >= winningScore {
                gameOver = true
                winner = "O"
                return
            }
        }
    }

    func makeAIMove(in boardIndex: Int, completion: @escaping () -> Void) {
        // AI moves only available in AI mode
        if gameMode == .aiOpponent {
            isThinking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let aiMove = TicTacToeAI.shared.makeMove(in: self.boards[boardIndex]) {
                    self.makeMove(at: aiMove, in: boardIndex)
                }
                self.isThinking = false
                completion()
            }
        } else {
            // In PvP mode, immediately call completion without AI move
            completion()
        }
    }

    func resetGame() {
        boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        totalScore = (x: 0, o: 0)
        currentBoard = 0
        currentPlayer = "X"
        gameOver = false
        winner = nil
        isThinking = false
    }

    func setGameMode(_ mode: GameMode) {
        self.gameMode = mode
        resetGame()
    }

    // Helper method for better player naming depending on mode
    func getPlayerName(for player: String) -> String {
        if gameMode == .playerVsPlayer {
            return player == "X" ? "Player 1" : "Player 2"
        } else {
            return player == "X" ? "You" : "AI"
        }
    }
}
