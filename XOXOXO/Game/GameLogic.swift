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
        // Основна статистика
        var totalGames: Int = 0
        var gamesWon: Int = 0
        var gamesDrawn: Int = 0
        var totalMoves: Int = 0
        var fastestMove: TimeInterval = .infinity
        var totalMoveTime: TimeInterval = 0
        
        // Мод статистика
        var vsAIGames: Int = 0
        var vsPlayerGames: Int = 0
        var aiWins: Int = 0
        var aiLosses: Int = 0
        var aiDraws: Int = 0
        
        // Временска статистика
        var totalGameTime: TimeInterval = 0
        var averageGameTime: TimeInterval = 0
        var fastestWin: TimeInterval = .infinity
        
        // Позициона статистика
        var centerMoves: Int = 0
        var cornerMoves: Int = 0
        var edgeMoves: Int = 0
        var centerMovePercentage: Double = 0
        var cornerMovePercentage: Double = 0
        var edgeMovePercentage: Double = 0
        
        // Табла статистика
        var boardsWon: Int = 0
        var totalBoards: Int = 0
        
        // Низ статистика
        var currentWinStreak: Int = 0
        var longestWinStreak: Int = 0
        var comebackWins: Int = 0
        
        // Бонус статистика
        var bonusCount: Int = 0
        var penaltyCount: Int = 0
        
        // AI специфична статистика
        var blockedWins: Int = 0
        var winningMoves: Int = 0
        var centerWins: Int = 0
        var cornerWins: Int = 0
        var edgeWins: Int = 0
        
        // Multiplayer специфична статистика
        var multiplayerWins: Int = 0
        var multiplayerLosses: Int = 0
        var multiplayerDraws: Int = 0
        var multiplayerWinStreak: Int = 0
        var multiplayerLongestStreak: Int = 0
        
        var averageMoveTime: TimeInterval {
            return totalMoves > 0 ? totalMoveTime / Double(totalMoves) : 0
        }
        
        var winRate: Double {
            return totalGames > 0 ? Double(gamesWon) / Double(totalGames) * 100 : 0
        }
        
        var aiWinRate: Double {
            return vsAIGames > 0 ? Double(aiWins) / Double(vsAIGames) * 100 : 0
        }
        
        var multiplayerWinRate: Double {
            return vsPlayerGames > 0 ? Double(multiplayerWins) / Double(vsPlayerGames) * 100 : 0
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
            aiWins = 0
            aiLosses = 0
            aiDraws = 0
            totalGameTime = 0
            averageGameTime = 0
            fastestWin = .infinity
            centerMoves = 0
            cornerMoves = 0
            edgeMoves = 0
            centerMovePercentage = 0
            cornerMovePercentage = 0
            edgeMovePercentage = 0
            boardsWon = 0
            totalBoards = 0
            currentWinStreak = 0
            longestWinStreak = 0
            comebackWins = 0
            bonusCount = 0
            penaltyCount = 0
            blockedWins = 0
            winningMoves = 0
            centerWins = 0
            cornerWins = 0
            edgeWins = 0
            multiplayerWins = 0
            multiplayerLosses = 0
            multiplayerDraws = 0
            multiplayerWinStreak = 0
            multiplayerLongestStreak = 0
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
            
            // Ажурирамо позициону статистику
            if position == 4 {
                playerStats.x.centerMoves += 1
            } else if [0, 2, 6, 8].contains(position) {
                playerStats.x.cornerMoves += 1
            } else {
                playerStats.x.edgeMoves += 1
            }
        } else {
            moveTimes[boardIndex].o.append(moveTime)
            playerStats.o.totalMoves += 1
            playerStats.o.totalMoveTime += moveTime
            if moveTime < playerStats.o.fastestMove {
                playerStats.o.fastestMove = moveTime
            }
            
            // Ажурирамо позициону статистику
            if position == 4 {
                playerStats.o.centerMoves += 1
            } else if [0, 2, 6, 8].contains(position) {
                playerStats.o.cornerMoves += 1
            } else {
                playerStats.o.edgeMoves += 1
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
                    
                    // Ажурирамо мод статистику
                    if gameMode == .aiOpponent {
                        playerStats.x.vsAIGames += 1
                        playerStats.o.vsAIGames += 1
                        playerStats.x.aiWins += 1
                        playerStats.o.aiLosses += 1
                    } else {
                        playerStats.x.vsPlayerGames += 1
                        playerStats.o.vsPlayerGames += 1
                        playerStats.x.multiplayerWins += 1
                        playerStats.o.multiplayerLosses += 1
                    }
                    
                    // Ажурирамо позициону статистику победа
                    if position == 4 {
                        playerStats.x.centerWins += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.x.cornerWins += 1
                    } else {
                        playerStats.x.edgeWins += 1
                    }
                    
                    // Ажурирамо статистику nizova
                    playerStats.x.currentWinStreak += 1
                    if playerStats.x.currentWinStreak > playerStats.x.longestWinStreak {
                        playerStats.x.longestWinStreak = playerStats.x.currentWinStreak
                    }
                    if gameMode == .playerVsPlayer {
                        playerStats.x.multiplayerWinStreak += 1
                        if playerStats.x.multiplayerWinStreak > playerStats.x.multiplayerLongestStreak {
                            playerStats.x.multiplayerLongestStreak = playerStats.x.multiplayerWinStreak
                        }
                    }
                    
                    // Ресетујемо nizове за противника
                    playerStats.o.currentWinStreak = 0
                    if gameMode == .playerVsPlayer {
                        playerStats.o.multiplayerWinStreak = 0
                    }
                } else {
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                    winningStreak = currentPlayer == "O" ? winningStreak + 1 : 1
                    playerStats.o.gamesWon += 1
                    playerStats.o.totalGames += 1
                    playerStats.x.totalGames += 1
                    
                    // Ажурирамо мод статистику
                    if gameMode == .aiOpponent {
                        playerStats.o.vsAIGames += 1
                        playerStats.x.vsAIGames += 1
                        playerStats.o.aiWins += 1
                        playerStats.x.aiLosses += 1
                    } else {
                        playerStats.o.vsPlayerGames += 1
                        playerStats.x.vsPlayerGames += 1
                        playerStats.o.multiplayerWins += 1
                        playerStats.x.multiplayerLosses += 1
                    }
                    
                    // Ажурирамо позициону статистику победа
                    if position == 4 {
                        playerStats.o.centerWins += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.o.cornerWins += 1
                    } else {
                        playerStats.o.edgeWins += 1
                    }
                    
                    // Ажурирамо статистику nizova
                    playerStats.o.currentWinStreak += 1
                    if playerStats.o.currentWinStreak > playerStats.o.longestWinStreak {
                        playerStats.o.longestWinStreak = playerStats.o.currentWinStreak
                    }
                    if gameMode == .playerVsPlayer {
                        playerStats.o.multiplayerWinStreak += 1
                        if playerStats.o.multiplayerWinStreak > playerStats.o.multiplayerLongestStreak {
                            playerStats.o.multiplayerLongestStreak = playerStats.o.multiplayerWinStreak
                        }
                    }
                    
                    // Ресетујемо nizове за противника
                    playerStats.x.currentWinStreak = 0
                    if gameMode == .playerVsPlayer {
                        playerStats.x.multiplayerWinStreak = 0
                    }
                }
            } else {
                // Ако нема победника а табла је пуна, то је нерешено
                lastDrawBoard = boardIndex
                winningStreak = 0
                playerStats.x.totalGames += 1
                playerStats.o.totalGames += 1
                
                // Ажурирамо мод статистику
                if gameMode == .aiOpponent {
                    playerStats.x.vsAIGames += 1
                    playerStats.o.vsAIGames += 1
                    playerStats.x.aiDraws += 1
                    playerStats.o.aiDraws += 1
                } else {
                    playerStats.x.vsPlayerGames += 1
                    playerStats.o.vsPlayerGames += 1
                    playerStats.x.multiplayerDraws += 1
                    playerStats.o.multiplayerDraws += 1
                }
                
                // Ресетујемо nizове
                playerStats.x.currentWinStreak = 0
                playerStats.o.currentWinStreak = 0
                if gameMode == .playerVsPlayer {
                    playerStats.x.multiplayerWinStreak = 0
                    playerStats.o.multiplayerWinStreak = 0
                }
            }
            // Reset this board
            boards[boardIndex] = Array(repeating: "", count: 9)
        }

        // Change current player
        currentPlayer = currentPlayer == "X" ? "O" : "X"
        
        // Update board only after both players have made their moves
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
        boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        totalScore = (x: 0, o: 0)
        currentPlayer = "X"
        currentBoard = 0
        totalMoves = 0
        fastestMove = .infinity
        moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        lastMoveTime = Date()
        winningStreak = 0
        gameOver = false
        isThinking = false
        winningIndexes = []
        
        // Resetujemo statistiku
        playerStats.x.reset()
        playerStats.o.reset()
        
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
