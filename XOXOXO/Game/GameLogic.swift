import Foundation

enum GameMode {
    case aiOpponent
    case playerVsPlayer
}

// Dodajemo enum za težinu AI protivnika
enum AIDifficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard

    var title: String {
        switch self {
        case .easy: return "Lako"
        case .medium: return "Srednje"
        case .hard: return "Teško"
        }
    }

    var description: String {
        switch self {
        case .easy: return "AI igra nasumično i ne blokira uvek."
        case .medium: return "AI blokira i pokušava da pobedi."
        case .hard: return "AI igra optimalno svaki potez."
        }
    }
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
    
    @Published var aiDifficulty: AIDifficulty = .medium
    
    struct PlayerStats: Codable {
        // Osnovna statistika
        var totalGames: Int = 0
        var gamesWon: Int = 0
        var totalMoves: Int = 0
        var averageMoveTime: TimeInterval = 0
        
        // Strategijska statistika
        var centerMoves: Int = 0
        var cornerMoves: Int = 0
        var edgeMoves: Int = 0
        
        // Nizovi
        var longestWinStreak: Int = 0
        
        // Izračunate vrednosti
        var winRate: Double {
            return totalGames > 0 ? Double(gamesWon) / Double(totalGames) * 100 : 0
        }
        
        var drawRate: Double {
            return totalGames > 0 ? Double(totalGames - gamesWon) / Double(totalGames) * 100 : 0
        }
        
        mutating func reset() {
            totalGames = 0
            gamesWon = 0
            totalMoves = 0
            averageMoveTime = 0
            centerMoves = 0
            cornerMoves = 0
            edgeMoves = 0
            longestWinStreak = 0
        }
        
        static func loadFromUserDefaults() -> (x: PlayerStats, o: PlayerStats) {
            let defaults = UserDefaults.standard
            
            if let xData = defaults.data(forKey: "playerStatsX"),
               let oData = defaults.data(forKey: "playerStatsO"),
               let xStats = try? JSONDecoder().decode(PlayerStats.self, from: xData),
               let oStats = try? JSONDecoder().decode(PlayerStats.self, from: oData) {
                return (x: xStats, o: oStats)
            }
            
            return (x: PlayerStats(), o: PlayerStats())
        }
        
        static func saveToUserDefaults(stats: (x: PlayerStats, o: PlayerStats)) {
            let defaults = UserDefaults.standard
            
            if let xData = try? JSONEncoder().encode(stats.x),
               let oData = try? JSONEncoder().encode(stats.o) {
                defaults.set(xData, forKey: "playerStatsX")
                defaults.set(oData, forKey: "playerStatsO")
            }
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
        
        // Učitaj sačuvanu statistiku
        self.playerStats = PlayerStats.loadFromUserDefaults()
        
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
        // Resetujemo praćenje
        lastWinner = nil
        lastWinningBoard = nil
        lastDrawBoard = nil
        winningIndexes = []
        
        // Zapisujemo vreme poteza
        let moveTime = Date().timeIntervalSince(lastMoveTime)
        lastMoveTime = Date()
        
        // Ažuriramo statistiku
        if currentPlayer == "X" {
            moveTimes[boardIndex].x.append(moveTime)
            playerStats.x.totalMoves += 1
            playerStats.x.averageMoveTime = (playerStats.x.averageMoveTime * Double(playerStats.x.totalMoves - 1) + moveTime) / Double(playerStats.x.totalMoves)
            
            // Ažuriramo pozicionu statistiku
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
            playerStats.o.averageMoveTime = (playerStats.o.averageMoveTime * Double(playerStats.o.totalMoves - 1) + moveTime) / Double(playerStats.o.totalMoves)
            
            // Ažuriramo pozicionu statistiku
            if position == 4 {
                playerStats.o.centerMoves += 1
            } else if [0, 2, 6, 8].contains(position) {
                playerStats.o.cornerMoves += 1
            } else {
                playerStats.o.edgeMoves += 1
            }
        }
        
        totalMoves += 1
        boards[boardIndex][position] = currentPlayer

        // Check if this board is complete
        if checkBoardComplete(in: boardIndex) {
            // Update scores if there is a winner
            if let boardWinner = checkBoardWinner(in: boardIndex) {
                // Pamtimo pobednika pre resetovanja table
                lastWinner = boardWinner
                lastWinningBoard = boardIndex
                
                if boardWinner == "X" {
                    boardScores[boardIndex].x += 1
                    totalScore.x += 1
                    playerStats.x.gamesWon += 1
                    playerStats.x.totalGames += 1
                    playerStats.o.totalGames += 1
                    
                    // Ažuriramo niz statistiku
                    if playerStats.x.longestWinStreak < playerStats.x.gamesWon {
                        playerStats.x.longestWinStreak = playerStats.x.gamesWon
                    }
                } else {
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                    playerStats.o.gamesWon += 1
                    playerStats.o.totalGames += 1
                    playerStats.x.totalGames += 1
                    
                    // Ažuriramo niz statistiku
                    if playerStats.o.longestWinStreak < playerStats.o.gamesWon {
                        playerStats.o.longestWinStreak = playerStats.o.gamesWon
                    }
                }
            } else {
                // Ako nema pobednika a tabla je puna, to je nerešeno
                print("Draw detected on board \(boardIndex)")
                lastDrawBoard = boardIndex
                playerStats.x.totalGames += 1
                playerStats.o.totalGames += 1
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
        
        // Sačuvaj statistiku
        PlayerStats.saveToUserDefaults(stats: playerStats)
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
        isThinking = true
        
        // Koristimo novi AI sa izabranim nivoom težine
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkingTime) {
            if let move = TicTacToeAI.shared.makeMove(in: self.boards[boardIndex], difficulty: self.aiDifficulty) {
                self.makeMove(at: move, in: boardIndex)
            }
            self.isThinking = false
            completion()
        }
    }

    func resetGame() {
        boards = Array(repeating: Array(repeating: "", count: 9), count: Self.BOARD_COUNT)
        currentBoard = 0
        currentPlayer = "X"
        gameOver = false
        isThinking = false
        boardScores = Array(repeating: (x: 0, o: 0), count: Self.BOARD_COUNT)
        totalScore = (x: 0, o: 0)
        winningIndexes = []
        moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        totalMoves = 0
        winningStreak = 0
        fastestMove = .infinity
        
        // Resetujemo statistiku poteza za trenutnu partiju
        playerStats.x.totalMoves = 0
        playerStats.x.averageMoveTime = 0
        playerStats.x.centerMoves = 0
        playerStats.x.cornerMoves = 0
        playerStats.x.edgeMoves = 0
        
        playerStats.o.totalMoves = 0
        playerStats.o.averageMoveTime = 0
        playerStats.o.centerMoves = 0
        playerStats.o.cornerMoves = 0
        playerStats.o.edgeMoves = 0
        
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
        
        // Сачувај ресетовану статистику
        PlayerStats.saveToUserDefaults(stats: playerStats)
        
        // Обавести UI да се статистика променила
        objectWillChange.send()
    }
    
    // Додајемо deinit да сачувамо статистику када се app затвори
    deinit {
        PlayerStats.saveToUserDefaults(stats: playerStats)
    }
}
