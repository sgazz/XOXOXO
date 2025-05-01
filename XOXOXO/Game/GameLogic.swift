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
    
    struct PlayerStats: Codable {
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
        
        // Статистика када Human игра као X
        var humanAsXGames: Int = 0
        var humanAsXWins: Int = 0
        var humanAsXLosses: Int = 0
        var humanAsXDraws: Int = 0
        var humanAsXFastestWin: TimeInterval = .infinity
        var humanAsXLongestWin: TimeInterval = 0
        var humanAsXFastestMove: TimeInterval = .infinity
        var humanAsXTotalMoves: Int = 0
        var humanAsXCenterMoves: Int = 0
        var humanAsXCornerMoves: Int = 0
        var humanAsXEdgeMoves: Int = 0
        var humanAsXCenterWins: Int = 0
        var humanAsXCornerWins: Int = 0
        var humanAsXEdgeWins: Int = 0
        var humanAsXCurrentStreak: Int = 0
        var humanAsXLongestStreak: Int = 0
        var humanAsXComebackWins: Int = 0
        var humanAsXFastestWinMoves: Int = .max
        var humanAsXLongestWinMoves: Int = 0
        
        // Статистика када Human игра као O
        var humanAsOGames: Int = 0
        var humanAsOWins: Int = 0
        var humanAsOLosses: Int = 0
        var humanAsODraws: Int = 0
        var humanAsOFastestWin: TimeInterval = .infinity
        var humanAsOLongestWin: TimeInterval = 0
        var humanAsOFastestMove: TimeInterval = .infinity
        var humanAsOTotalMoves: Int = 0
        var humanAsOCenterMoves: Int = 0
        var humanAsOCornerMoves: Int = 0
        var humanAsOEdgeMoves: Int = 0
        var humanAsOCenterWins: Int = 0
        var humanAsOCornerWins: Int = 0
        var humanAsOEdgeWins: Int = 0
        var humanAsOCurrentStreak: Int = 0
        var humanAsOLongestStreak: Int = 0
        var humanAsOComebackWins: Int = 0
        var humanAsOFastestWinMoves: Int = .max
        var humanAsOLongestWinMoves: Int = 0
        
        // Статистика када AI игра као X
        var aiAsXGames: Int = 0
        var aiAsXWins: Int = 0
        var aiAsXLosses: Int = 0
        var aiAsXDraws: Int = 0
        var aiAsXFastestWin: TimeInterval = .infinity
        var aiAsXLongestWin: TimeInterval = 0
        var aiAsXFastestMove: TimeInterval = .infinity
        var aiAsXTotalMoves: Int = 0
        var aiAsXCenterMoves: Int = 0
        var aiAsXCornerMoves: Int = 0
        var aiAsXEdgeMoves: Int = 0
        var aiAsXCenterWins: Int = 0
        var aiAsXCornerWins: Int = 0
        var aiAsXEdgeWins: Int = 0
        var aiAsXCurrentStreak: Int = 0
        var aiAsXLongestStreak: Int = 0
        var aiAsXBlockedWins: Int = 0
        var aiAsXWinningMoves: Int = 0
        var aiAsXFastestWinMoves: Int = .max
        var aiAsXLongestWinMoves: Int = 0
        
        // Статистика када AI игра као O
        var aiAsOGames: Int = 0
        var aiAsOWins: Int = 0
        var aiAsOLosses: Int = 0
        var aiAsODraws: Int = 0
        var aiAsOFastestWin: TimeInterval = .infinity
        var aiAsOLongestWin: TimeInterval = 0
        var aiAsOFastestMove: TimeInterval = .infinity
        var aiAsOTotalMoves: Int = 0
        var aiAsOCenterMoves: Int = 0
        var aiAsOCornerMoves: Int = 0
        var aiAsOEdgeMoves: Int = 0
        var aiAsOCenterWins: Int = 0
        var aiAsOCornerWins: Int = 0
        var aiAsOEdgeWins: Int = 0
        var aiAsOCurrentStreak: Int = 0
        var aiAsOLongestStreak: Int = 0
        var aiAsOBlockedWins: Int = 0
        var aiAsOWinningMoves: Int = 0
        var aiAsOFastestWinMoves: Int = .max
        var aiAsOLongestWinMoves: Int = 0
        
        // Временска статистика
        var totalGameTime: TimeInterval = 0
        var averageGameTime: TimeInterval = 0
        var fastestWin: TimeInterval = .infinity
        var longestWin: TimeInterval = 0
        var fastestWinVsAI: TimeInterval = .infinity
        var longestWinVsAI: TimeInterval = 0
        var fastestWinVsHuman: TimeInterval = .infinity
        var longestWinVsHuman: TimeInterval = 0
        
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
        
        // Нова статистика за најбрже/најдуже победе
        var fastestWinMoves: Int = .max
        var longestWinMoves: Int = 0
        var mostDrawsInGame: Int = 0
        var leastDrawsInGame: Int = .max
        
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
            // Resetujemo Human statistiku za X
            humanAsXGames = 0
            humanAsXWins = 0
            humanAsXLosses = 0
            humanAsXDraws = 0
            humanAsXFastestWin = .infinity
            humanAsXLongestWin = 0
            humanAsXFastestMove = .infinity
            humanAsXTotalMoves = 0
            humanAsXCenterMoves = 0
            humanAsXCornerMoves = 0
            humanAsXEdgeMoves = 0
            humanAsXCenterWins = 0
            humanAsXCornerWins = 0
            humanAsXEdgeWins = 0
            humanAsXCurrentStreak = 0
            humanAsXLongestStreak = 0
            humanAsXComebackWins = 0
            humanAsXFastestWinMoves = .max
            humanAsXLongestWinMoves = 0
            
            // Resetujemo Human statistiku za O
            humanAsOGames = 0
            humanAsOWins = 0
            humanAsOLosses = 0
            humanAsODraws = 0
            humanAsOFastestWin = .infinity
            humanAsOLongestWin = 0
            humanAsOFastestMove = .infinity
            humanAsOTotalMoves = 0
            humanAsOCenterMoves = 0
            humanAsOCornerMoves = 0
            humanAsOEdgeMoves = 0
            humanAsOCenterWins = 0
            humanAsOCornerWins = 0
            humanAsOEdgeWins = 0
            humanAsOCurrentStreak = 0
            humanAsOLongestStreak = 0
            humanAsOComebackWins = 0
            humanAsOFastestWinMoves = .max
            humanAsOLongestWinMoves = 0
            
            // Resetujemo AI statistiku za X
            aiAsXGames = 0
            aiAsXWins = 0
            aiAsXLosses = 0
            aiAsXDraws = 0
            aiAsXFastestWin = .infinity
            aiAsXLongestWin = 0
            aiAsXFastestMove = .infinity
            aiAsXTotalMoves = 0
            aiAsXCenterMoves = 0
            aiAsXCornerMoves = 0
            aiAsXEdgeMoves = 0
            aiAsXCenterWins = 0
            aiAsXCornerWins = 0
            aiAsXEdgeWins = 0
            aiAsXCurrentStreak = 0
            aiAsXLongestStreak = 0
            aiAsXBlockedWins = 0
            aiAsXWinningMoves = 0
            aiAsXFastestWinMoves = .max
            aiAsXLongestWinMoves = 0
            
            // Resetujemo AI statistiku za O
            aiAsOGames = 0
            aiAsOWins = 0
            aiAsOLosses = 0
            aiAsODraws = 0
            aiAsOFastestWin = .infinity
            aiAsOLongestWin = 0
            aiAsOFastestMove = .infinity
            aiAsOTotalMoves = 0
            aiAsOCenterMoves = 0
            aiAsOCornerMoves = 0
            aiAsOEdgeMoves = 0
            aiAsOCenterWins = 0
            aiAsOCornerWins = 0
            aiAsOEdgeWins = 0
            aiAsOCurrentStreak = 0
            aiAsOLongestStreak = 0
            aiAsOBlockedWins = 0
            aiAsOWinningMoves = 0
            aiAsOFastestWinMoves = .max
            aiAsOLongestWinMoves = 0
            
            // Resetujemo opštu statistiku
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
            longestWin = 0
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
            fastestWinMoves = .max
            longestWinMoves = 0
            mostDrawsInGame = 0
            leastDrawsInGame = .max
        }
        
        // Нове методе за чување и учитавање статистике
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
            
            if gameMode == .aiOpponent {
                if playerSettings.isPlayerX {
                    // Human igra kao X
                    playerStats.x.humanAsXTotalMoves += 1
                    if moveTime < playerStats.x.humanAsXFastestMove {
                        playerStats.x.humanAsXFastestMove = moveTime
                    }
                    
                    // Ažuriramo pozicionu statistiku
                    if position == 4 {
                        playerStats.x.humanAsXCenterMoves += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.x.humanAsXCornerMoves += 1
                    } else {
                        playerStats.x.humanAsXEdgeMoves += 1
                    }
                } else {
                    // AI igra kao X
                    playerStats.x.aiAsXTotalMoves += 1
                    if moveTime < playerStats.x.aiAsXFastestMove {
                        playerStats.x.aiAsXFastestMove = moveTime
                    }
                    
                    // Ažuriramo pozicionu statistiku
                    if position == 4 {
                        playerStats.x.aiAsXCenterMoves += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.x.aiAsXCornerMoves += 1
                    } else {
                        playerStats.x.aiAsXEdgeMoves += 1
                    }
                }
            }
        } else {
            moveTimes[boardIndex].o.append(moveTime)
            
            if gameMode == .aiOpponent {
                if !playerSettings.isPlayerX {
                    // Human igra kao O
                    playerStats.o.humanAsOTotalMoves += 1
                    if moveTime < playerStats.o.humanAsOFastestMove {
                        playerStats.o.humanAsOFastestMove = moveTime
                    }
                    
                    // Ažuriramo pozicionu statistiku
                    if position == 4 {
                        playerStats.o.humanAsOCenterMoves += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.o.humanAsOCornerMoves += 1
                    } else {
                        playerStats.o.humanAsOEdgeMoves += 1
                    }
                } else {
                    // AI igra kao O
                    playerStats.o.aiAsOTotalMoves += 1
                    if moveTime < playerStats.o.aiAsOFastestMove {
                        playerStats.o.aiAsOFastestMove = moveTime
                    }
                    
                    // Ažuriramo pozicionu statistiku
                    if position == 4 {
                        playerStats.o.aiAsOCenterMoves += 1
                    } else if [0, 2, 6, 8].contains(position) {
                        playerStats.o.aiAsOCornerMoves += 1
                    } else {
                        playerStats.o.aiAsOEdgeMoves += 1
                    }
                }
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
                
                // Ажурирамо статистику за најбрже/најдуже победе
                let gameTime = Date().timeIntervalSince(lastMoveTime)
                let movesInGame = moveTimes[boardIndex].x.count + moveTimes[boardIndex].o.count
                
                if boardWinner == "X" {
                    // Ажурирамо временску статистику
                    if gameTime < playerStats.x.fastestWin {
                        playerStats.x.fastestWin = gameTime
                    }
                    if gameTime > playerStats.x.longestWin {
                        playerStats.x.longestWin = gameTime
                    }
                    
                    // Ажурирамо статистику по модовима
                    if gameMode == .aiOpponent {
                        if gameTime < playerStats.x.fastestWinVsAI {
                            playerStats.x.fastestWinVsAI = gameTime
                        }
                        if gameTime > playerStats.x.longestWinVsAI {
                            playerStats.x.longestWinVsAI = gameTime
                        }
                    } else {
                        if gameTime < playerStats.x.fastestWinVsHuman {
                            playerStats.x.fastestWinVsHuman = gameTime
                        }
                        if gameTime > playerStats.x.longestWinVsHuman {
                            playerStats.x.longestWinVsHuman = gameTime
                        }
                    }
                    
                    // Ажурирамо статистику броја потеза
                    if movesInGame < playerStats.x.fastestWinMoves {
                        playerStats.x.fastestWinMoves = movesInGame
                    }
                    if movesInGame > playerStats.x.longestWinMoves {
                        playerStats.x.longestWinMoves = movesInGame
                    }
                    
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
                    
                    // У делу где се ажурира статистика победника:
                    if gameMode == .aiOpponent {
                        if playerSettings.isPlayerX {
                            // Human је победио као X
                            playerStats.x.humanAsXGames += 1
                            playerStats.x.humanAsXWins += 1
                            if gameTime < playerStats.x.humanAsXFastestWin {
                                playerStats.x.humanAsXFastestWin = gameTime
                            }
                            if gameTime > playerStats.x.humanAsXLongestWin {
                                playerStats.x.humanAsXLongestWin = gameTime
                            }
                            if movesInGame < playerStats.x.humanAsXFastestWinMoves {
                                playerStats.x.humanAsXFastestWinMoves = movesInGame
                            }
                            if movesInGame > playerStats.x.humanAsXLongestWinMoves {
                                playerStats.x.humanAsXLongestWinMoves = movesInGame
                            }
                            playerStats.x.humanAsXCurrentStreak += 1
                            if playerStats.x.humanAsXCurrentStreak > playerStats.x.humanAsXLongestStreak {
                                playerStats.x.humanAsXLongestStreak = playerStats.x.humanAsXCurrentStreak
                            }
                            
                            // Ažuriramo pozicionu statistiku pobeda
                            if position == 4 {
                                playerStats.x.humanAsXCenterWins += 1
                            } else if [0, 2, 6, 8].contains(position) {
                                playerStats.x.humanAsXCornerWins += 1
                            } else {
                                playerStats.x.humanAsXEdgeWins += 1
                            }
                            
                            // Resetujemo AI streak
                            playerStats.o.aiAsOCurrentStreak = 0
                        } else {
                            // AI је победио као X
                            playerStats.x.aiAsXGames += 1
                            playerStats.x.aiAsXWins += 1
                            if gameTime < playerStats.x.aiAsXFastestWin {
                                playerStats.x.aiAsXFastestWin = gameTime
                            }
                            if gameTime > playerStats.x.aiAsXLongestWin {
                                playerStats.x.aiAsXLongestWin = gameTime
                            }
                            if movesInGame < playerStats.x.aiAsXFastestWinMoves {
                                playerStats.x.aiAsXFastestWinMoves = movesInGame
                            }
                            if movesInGame > playerStats.x.aiAsXLongestWinMoves {
                                playerStats.x.aiAsXLongestWinMoves = movesInGame
                            }
                            playerStats.x.aiAsXCurrentStreak += 1
                            if playerStats.x.aiAsXCurrentStreak > playerStats.x.aiAsXLongestStreak {
                                playerStats.x.aiAsXLongestStreak = playerStats.x.aiAsXCurrentStreak
                            }
                            
                            // Ažuriramo pozicionu statistiku pobeda
                            if position == 4 {
                                playerStats.x.aiAsXCenterWins += 1
                            } else if [0, 2, 6, 8].contains(position) {
                                playerStats.x.aiAsXCornerWins += 1
                            } else {
                                playerStats.x.aiAsXEdgeWins += 1
                            }
                            
                            // Resetujemo Human streak
                            playerStats.o.humanAsOCurrentStreak = 0
                        }
                    }
                } else {
                    // Ажурирамо временску статистику
                    if gameTime < playerStats.o.fastestWin {
                        playerStats.o.fastestWin = gameTime
                    }
                    if gameTime > playerStats.o.longestWin {
                        playerStats.o.longestWin = gameTime
                    }
                    
                    // Ажурирамо статистику по модовима
                    if gameMode == .aiOpponent {
                        if gameTime < playerStats.o.fastestWinVsAI {
                            playerStats.o.fastestWinVsAI = gameTime
                        }
                        if gameTime > playerStats.o.longestWinVsAI {
                            playerStats.o.longestWinVsAI = gameTime
                        }
                    } else {
                        if gameTime < playerStats.o.fastestWinVsHuman {
                            playerStats.o.fastestWinVsHuman = gameTime
                        }
                        if gameTime > playerStats.o.longestWinVsHuman {
                            playerStats.o.longestWinVsHuman = gameTime
                        }
                    }
                    
                    // Ажурирамо статистику броја потеза
                    if movesInGame < playerStats.o.fastestWinMoves {
                        playerStats.o.fastestWinMoves = movesInGame
                    }
                    if movesInGame > playerStats.o.longestWinMoves {
                        playerStats.o.longestWinMoves = movesInGame
                    }
                    
                    boardScores[boardIndex].o += 1
                    totalScore.o += 1
                    winningStreak = currentPlayer == "O" ? winningStreak + 1 : 1
                    playerStats.o.gamesWon += 1
                    playerStats.o.totalGames += 1
                    playerStats.x.totalGames += 1
                    
                    // У делу где се ажурира статистика победника:
                    if gameMode == .aiOpponent {
                        if !playerSettings.isPlayerX {
                            // Human је победио као O
                            playerStats.o.humanAsOGames += 1
                            playerStats.o.humanAsOWins += 1
                            if gameTime < playerStats.o.humanAsOFastestWin {
                                playerStats.o.humanAsOFastestWin = gameTime
                            }
                            if gameTime > playerStats.o.humanAsOLongestWin {
                                playerStats.o.humanAsOLongestWin = gameTime
                            }
                            if movesInGame < playerStats.o.humanAsOFastestWinMoves {
                                playerStats.o.humanAsOFastestWinMoves = movesInGame
                            }
                            if movesInGame > playerStats.o.humanAsOLongestWinMoves {
                                playerStats.o.humanAsOLongestWinMoves = movesInGame
                            }
                            playerStats.o.humanAsOCurrentStreak += 1
                            if playerStats.o.humanAsOCurrentStreak > playerStats.o.humanAsOLongestStreak {
                                playerStats.o.humanAsOLongestStreak = playerStats.o.humanAsOCurrentStreak
                            }
                            
                            // Ažuriramo pozicionu statistiku pobeda
                            if position == 4 {
                                playerStats.o.humanAsOCenterWins += 1
                            } else if [0, 2, 6, 8].contains(position) {
                                playerStats.o.humanAsOCornerWins += 1
                            } else {
                                playerStats.o.humanAsOEdgeWins += 1
                            }
                            
                            // Resetujemo AI streak
                            playerStats.x.aiAsXCurrentStreak = 0
                        } else {
                            // AI је победио као O
                            playerStats.o.aiAsOGames += 1
                            playerStats.o.aiAsOWins += 1
                            if gameTime < playerStats.o.aiAsOFastestWin {
                                playerStats.o.aiAsOFastestWin = gameTime
                            }
                            if gameTime > playerStats.o.aiAsOLongestWin {
                                playerStats.o.aiAsOLongestWin = gameTime
                            }
                            if movesInGame < playerStats.o.aiAsOFastestWinMoves {
                                playerStats.o.aiAsOFastestWinMoves = movesInGame
                            }
                            if movesInGame > playerStats.o.aiAsOLongestWinMoves {
                                playerStats.o.aiAsOLongestWinMoves = movesInGame
                            }
                            playerStats.o.aiAsOCurrentStreak += 1
                            if playerStats.o.aiAsOCurrentStreak > playerStats.o.aiAsOLongestStreak {
                                playerStats.o.aiAsOLongestStreak = playerStats.o.aiAsOCurrentStreak
                            }
                            
                            // Ažuriramo pozicionu statistiku pobeda
                            if position == 4 {
                                playerStats.o.aiAsOCenterWins += 1
                            } else if [0, 2, 6, 8].contains(position) {
                                playerStats.o.aiAsOCornerWins += 1
                            } else {
                                playerStats.o.aiAsOEdgeWins += 1
                            }
                            
                            // Resetujemo Human streak
                            playerStats.x.humanAsXCurrentStreak = 0
                        }
                    }
                }
            } else {
                // Ако нема победника а табла је пуна, то је нерешено
                lastDrawBoard = boardIndex
                winningStreak = 0
                playerStats.x.totalGames += 1
                playerStats.o.totalGames += 1
                
                // Ажурирамо статистику за нерешене партије
                let drawsInGame = moveTimes[boardIndex].x.count + moveTimes[boardIndex].o.count
                if drawsInGame > playerStats.x.mostDrawsInGame {
                    playerStats.x.mostDrawsInGame = drawsInGame
                }
                if drawsInGame < playerStats.x.leastDrawsInGame {
                    playerStats.x.leastDrawsInGame = drawsInGame
                }
                if drawsInGame > playerStats.o.mostDrawsInGame {
                    playerStats.o.mostDrawsInGame = drawsInGame
                }
                if drawsInGame < playerStats.o.leastDrawsInGame {
                    playerStats.o.leastDrawsInGame = drawsInGame
                }
                
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
        
        // Resetujemo statistiku trenutne igre
        moveTimes = Array(repeating: (x: [], o: []), count: Self.BOARD_COUNT)
        totalMoves = 0
        winningStreak = 0
        fastestMove = .infinity
        lastMoveTime = Date()
        
        // Ако је играч изабрао O, AI треба да игра први
        if gameMode == .aiOpponent && !playerSettings.isPlayerX {
            makeAIMove(in: currentBoard, thinkingTime: 0.1) {}
        }
        // Multiplayer: resetuj simbol igrača на X
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
