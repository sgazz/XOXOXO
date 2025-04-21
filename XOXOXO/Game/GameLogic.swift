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
    @Published var isThinking: Bool
    @Published var boardScores: [(x: Int, o: Int)]
    @Published var totalScore: (x: Int, o: Int)
    @Published var gameMode: GameMode = .aiOpponent
    @Published var winningIndexes: [Int] = []
    
    // Додајемо променљиву за праћење последњег победника
    private var lastWinner: String?
    private var lastWinningBoard: Int?
    // Додајемо променљиву за праћење нерешеног резултата
    private var lastDrawBoard: Int?

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
        self.isThinking = false
        self.boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        self.totalScore = (x: 0, o: 0)
        self.gameMode = gameMode
        self.winningIndexes = []
    }

    func makeMove(at position: Int, in boardIndex: Int) {
        // Ресетујемо праћење
        lastWinner = nil
        lastWinningBoard = nil
        lastDrawBoard = nil
        winningIndexes = []
        
        boards[boardIndex][position] = currentPlayer

        // Check if this board is complete
        if checkBoardComplete(in: boardIndex) {
            // Update scores if there is a winner
            if let boardWinner = checkBoardWinner(in: boardIndex) {
                // Памтимо победника пре ресетовања табле
                lastWinner = boardWinner
                lastWinningBoard = boardIndex
                
                if boardWinner == "X" {
                    boardScores[boardIndex].x += 1
                    totalScore.x += 1
                } else {
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                }
            } else {
                // Ако нема победника а табла је пуна, то је нерешено
                lastDrawBoard = boardIndex
            }
            // Reset this board
            boards[boardIndex] = Array(repeating: "", count: 9)
        }

        // Change current player
        currentPlayer = currentPlayer == "X" ? "O" : "X"
        
        // Update board only when X's turn comes (after O played)
        if currentPlayer == "X" {
            currentBoard = (boardIndex + 1) % Self.BOARD_COUNT
        }
    }

    private func checkBoardComplete(in boardIndex: Int) -> Bool {
        return checkBoardWinner(in: boardIndex) != nil || !boards[boardIndex].contains("")
    }

    func checkBoardWinner(in boardIndex: Int) -> String? {
        for combination in Self.winningCombinations {
            if boards[boardIndex][combination[0]] != "" &&
               boards[boardIndex][combination[0]] == boards[boardIndex][combination[1]] &&
               boards[boardIndex][combination[1]] == boards[boardIndex][combination[2]] {
                winningIndexes = combination
                return boards[boardIndex][combination[0]]
            }
        }
        winningIndexes = []
        return nil
    }

    func makeAIMove(in boardIndex: Int, thinkingTime: TimeInterval = 0.5, completion: @escaping () -> Void) {
        // AI moves only available in AI mode
        if gameMode == .aiOpponent {
            isThinking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + thinkingTime) {
                if let aiMove = TicTacToeAI.shared.makeMove(in: self.boards[boardIndex]) {
                    self.makeMove(at: aiMove, in: boardIndex)
                }
                self.isThinking = false
                completion()
            }
        } else {
            completion()
        }
    }

    func resetGame() {
        // Resetuj sve table
        boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        totalScore = (x: 0, o: 0)
        currentBoard = 0
        currentPlayer = "X"
        gameOver = false
        isThinking = false
        winningIndexes = []
        
        // Resetuj praćenje
        lastWinner = nil
        lastWinningBoard = nil
        lastDrawBoard = nil
    }

    func setGameMode(_ mode: GameMode) {
        self.gameMode = mode
        resetGame()
    }
    
    // Метод за промену мода игре
    func changeGameMode(to newMode: GameMode) {
        // Не мењај мод ако је исти као тренутни
        guard gameMode != newMode else { return }
        
        gameMode = newMode
            resetGame()
        
        // Обавести UI да се мод променио
        objectWillChange.send()
    }

    // Нова функција за симулацију потеза
    func simulateMove(at position: Int, in boardIndex: Int, for player: String) -> String? {
        // Сачувај тренутно стање
        let originalValue = boards[boardIndex][position]
        
        // Симулирај потез
        boards[boardIndex][position] = player
        
        // Провери победника
        let winner = checkBoardWinner(in: boardIndex)
        
        // Врати на оригинално стање
        boards[boardIndex][position] = originalValue
        
        return winner
    }

    // Нова функција за проверу последњег победника
    func getLastWinner(for boardIndex: Int) -> String? {
        if lastWinningBoard == boardIndex {
            return lastWinner
        }
        return nil
    }

    // Нова функција за проверу нерешеног резултата
    func wasLastMoveDraw(in boardIndex: Int) -> Bool {
        return lastDrawBoard == boardIndex
    }
}
