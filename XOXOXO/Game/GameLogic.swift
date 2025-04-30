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
    
    // Нова променљива за праћење времена потеза
    @Published var moveTimes: [(x: [TimeInterval], o: [TimeInterval])] = []
    @Published var totalMoves: Int = 0
    @Published var winningStreak: Int = 0
    @Published var fastestMove: TimeInterval = .infinity
    
    // Нове променљиве за праћење статистике по играчу
    @Published var playerStats: (x: PlayerStats, o: PlayerStats) = (
        x: PlayerStats(),
        o: PlayerStats()
    )
    
    struct PlayerStats {
        var totalGames: Int = 0
        var gamesWon: Int = 0
        var gamesDrawn: Int = 0
        var totalMoves: Int = 0
        var fastestMove: TimeInterval = .infinity
        var totalMoveTime: TimeInterval = 0
        var vsAIGames: Int = 0
        var vsPlayerGames: Int = 0
        var totalGameTime: TimeInterval = 0
        var averageGameTime: TimeInterval = 0
        var fastestWin: TimeInterval = .infinity
        var centerMoves: Int = 0
        var cornerMoves: Int = 0
        var centerMovePercentage: Double = 0
        var cornerMovePercentage: Double = 0
        var boardsWon: Int = 0
        var totalBoards: Int = 0
        var currentWinStreak: Int = 0
        var longestWinStreak: Int = 0
        var comebackWins: Int = 0
        var bonusCount: Int = 0
        var penaltyCount: Int = 0
        
        var averageMoveTime: TimeInterval {
            return totalMoves > 0 ? totalMoveTime / Double(totalMoves) : 0
        }
        
        var winRate: Double {
            return totalGames > 0 ? Double(gamesWon) / Double(totalGames) * 100 : 0
        }
        
        mutating func reset() {
            totalGames = 0
            gamesWon = 0
            gamesDrawn = 0
            totalMoves = 0
            fastestMove = .infinity
            totalMoveTime = 0
            vsAIGames = 0
            vsPlayerGames = 0
            totalGameTime = 0
            averageGameTime = 0
            fastestWin = .infinity
            centerMoves = 0
            cornerMoves = 0
            centerMovePercentage = 0
            cornerMovePercentage = 0
            boardsWon = 0
            totalBoards = 0
            currentWinStreak = 0
            longestWinStreak = 0
            comebackWins = 0
            bonusCount = 0
            penaltyCount = 0
        }
    }
    
    private let playerSettings = PlayerSettings.shared
    
    // Додајемо променљиву за праћење последњег победника
    private var lastWinner: String?
    private var lastWinningBoard: Int?
    // Додајемо променљиву за праћење нерешеног резултата
    private var lastDrawBoard: Int?

    // Нова променљива за праћење последњег времена потеза
    private var lastMoveTime: Date = Date()
    
    static let winningCombinations = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6]             // diagonal
    ]

    init(gameMode: GameMode = .aiOpponent) {
        self.boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        self.currentBoard = 0
        self.currentPlayer = "X" // Почињемо увек са X
        self.gameOver = false
        self.isThinking = false
        self.boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        self.totalScore = (x: 0, o: 0)
        self.gameMode = gameMode
        self.winningIndexes = []
        self.moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        
        // Ако је играч изабрао O, AI треба да игра први
        if gameMode == .aiOpponent && !playerSettings.isPlayerX {
            makeAIMove(in: currentBoard, thinkingTime: 0.1) {}
        }
        // Multiplayer: resetuj simbol igrača na X
        if gameMode == .playerVsPlayer {
            playerSettings.playerSymbol = "X"
        }
    }

    func makeMove(at position: Int, in boardIndex: Int) {
        // Ресетујемо праћење
        lastWinner = nil
        lastWinningBoard = nil
        lastDrawBoard = nil
        winningIndexes = []
        
        // Записујемо време потеза
        let moveTime = Date().timeIntervalSince(lastMoveTime)
        lastMoveTime = Date()
        
        // Ажурирамо статистику
        if currentPlayer == "X" {
            moveTimes[boardIndex].x.append(moveTime)
            playerStats.x.totalMoves += 1
            playerStats.x.totalMoveTime += moveTime
            if moveTime < playerStats.x.fastestMove {
                playerStats.x.fastestMove = moveTime
            }
        } else {
            moveTimes[boardIndex].o.append(moveTime)
            playerStats.o.totalMoves += 1
            playerStats.o.totalMoveTime += moveTime
            if moveTime < playerStats.o.fastestMove {
                playerStats.o.fastestMove = moveTime
            }
        }
        
        // Ажурирамо најбржи потез
        if moveTime < fastestMove {
            fastestMove = moveTime
        }
        
        totalMoves += 1
        
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
                    winningStreak = currentPlayer == "X" ? winningStreak + 1 : 1
                    playerStats.x.gamesWon += 1
                    playerStats.x.totalGames += 1
                    playerStats.o.totalGames += 1
                } else {
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                    winningStreak = currentPlayer == "O" ? winningStreak + 1 : 1
                    playerStats.o.gamesWon += 1
                    playerStats.o.totalGames += 1
                    playerStats.x.totalGames += 1
                }
            } else {
                // Ако нема победника а табла је пуна, то је нерешено
                lastDrawBoard = boardIndex
                winningStreak = 0
                playerStats.x.totalGames += 1
                playerStats.o.totalGames += 1
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
        currentPlayer = "X" // Почињемо увек са X
        gameOver = false
        isThinking = false
        winningIndexes = []
        
        // Resetuj статистику
        moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        totalMoves = 0
        winningStreak = 0
        fastestMove = .infinity
        lastMoveTime = Date()
        
        // Ресетујемо статистику играча
        playerStats.x.reset()
        playerStats.o.reset()
        
        // Resetuj praćenje
        lastWinner = nil
        lastWinningBoard = nil
        lastDrawBoard = nil
        
        // Ако је играч изабрао O, AI треба да игра први
        if gameMode == .aiOpponent && !playerSettings.isPlayerX {
            makeAIMove(in: currentBoard, thinkingTime: 0.1) {}
        }
        // Multiplayer: resetuj simbol igrača na X
        if gameMode == .playerVsPlayer {
            playerSettings.playerSymbol = "X"
        }
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
    
    // Нова функција за проверу да ли је AI на потезу
    var isAITurn: Bool {
        if gameMode == .aiOpponent {
            return currentPlayer == playerSettings.aiSymbol
        }
        return false
    }
    
    // Нова функција за проверу да ли је играч на потезу
    var isPlayerTurn: Bool {
        if gameMode == .aiOpponent {
            return currentPlayer == playerSettings.playerSymbol
        }
        return true
    }

    // Нова рачунска особина за просечно време по потезу
    var averageTimePerMove: (x: TimeInterval, o: TimeInterval) {
        var xTotal: TimeInterval = 0
        var oTotal: TimeInterval = 0
        var xCount = 0
        var oCount = 0
        
        for board in moveTimes {
            xTotal += board.x.reduce(0, +)
            oTotal += board.o.reduce(0, +)
            xCount += board.x.count
            oCount += board.o.count
        }
        
        return (
            x: xCount > 0 ? xTotal / Double(xCount) : 0,
            o: oCount > 0 ? oTotal / Double(oCount) : 0
        )
    }
    
    // Нова метода за ресетовање само статистике
    func resetStatistics() {
        moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        totalMoves = 0
        winningStreak = 0
        fastestMove = .infinity
        lastMoveTime = Date()
        
        // Ресетујемо статистику играча
        playerStats.x.reset()
        playerStats.o.reset()
        
        // Обавести UI да се статистика променила
        objectWillChange.send()
    }
}
