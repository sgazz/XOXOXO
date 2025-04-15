import Foundation

class GameLogic: ObservableObject {
    static let BOARD_COUNT = 8 // Increased from 6 to 8 boards
    
    @Published var boards: [[String]]
    @Published var currentBoard: Int
    @Published var currentPlayer: String
    @Published var gameOver: Bool
    @Published var winner: String?
    @Published var isThinking: Bool
    
    static let winningCombinations = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6]             // diagonal
    ]
    
    init() {
        self.boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        self.currentBoard = 0
        self.currentPlayer = "X"
        self.gameOver = false
        self.winner = nil
        self.isThinking = false
    }
    
    func makeMove(at position: Int, in boardIndex: Int) {
        boards[boardIndex][position] = currentPlayer
        checkWinner(in: boardIndex)
        if !gameOver {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
            if currentPlayer == "X" {  // Only update board after AI's move
                currentBoard = (boardIndex + 1) % Self.BOARD_COUNT
            }
        }
    }
    
    func makeAIMove(in boardIndex: Int, completion: @escaping () -> Void) {
        isThinking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let aiMove = TicTacToeAI.shared.makeMove(in: self.boards[boardIndex]) {
                self.makeMove(at: aiMove, in: boardIndex)
            }
            self.isThinking = false
            completion()
        }
    }
    
    private func checkWinner(in boardIndex: Int) {
        for combination in Self.winningCombinations {
            if boards[boardIndex][combination[0]] != "" &&
               boards[boardIndex][combination[0]] == boards[boardIndex][combination[1]] &&
               boards[boardIndex][combination[1]] == boards[boardIndex][combination[2]] {
                gameOver = true
                winner = boards[boardIndex][combination[0]]
                return
            }
        }
        
        if !boards[boardIndex].contains("") {
            if !boards.contains(where: { $0.contains("") }) {
                gameOver = true
            }
        }
    }
    
    func resetGame() {
        boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        currentBoard = 0
        currentPlayer = "X"
        gameOver = false
        winner = nil
        isThinking = false
    }
} 