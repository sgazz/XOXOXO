import Foundation

class TicTacToeAI {
    static let shared = TicTacToeAI()
    private let playerSettings = PlayerSettings.shared
    
    private init() {}
    
    func makeMove(in board: [String], difficulty: AIDifficulty) -> Int? {
        switch difficulty {
        case .easy:
            return makeEasyMove(in: board)
        case .medium:
            return makeMediumMove(in: board)
        case .hard:
            return makeHardMove(in: board)
        }
    }
    
    private func makeEasyMove(in board: [String]) -> Int? {
        // Samo nasumičan potez
        let emptySpots = board.enumerated().filter { $0.element.isEmpty }.map { $0.offset }
        return emptySpots.randomElement()
    }
    
    private func makeMediumMove(in board: [String]) -> Int? {
        let aiSymbol = playerSettings.aiSymbol
        let playerSymbol = playerSettings.playerSymbol
        
        // Prvo proveri da li AI može da pobedi
        if let winningMove = findWinningMove(for: aiSymbol, in: board) {
            return winningMove
        }
        
        // Onda proveri da li mora da blokira igrača
        if let blockingMove = findWinningMove(for: playerSymbol, in: board) {
            return blockingMove
        }
        
        // Ako nema pobedničkih poteza, bira nasumično
        let emptySpots = board.enumerated().filter { $0.element.isEmpty }.map { $0.offset }
        return emptySpots.randomElement()
    }
    
    private func makeHardMove(in board: [String]) -> Int? {
        let aiSymbol = playerSettings.aiSymbol
        var bestScore = Int.min
        var bestMove: Int?
        
        // Proveri sve moguće poteze
        for i in 0..<9 {
            if board[i].isEmpty {
                var newBoard = board
                newBoard[i] = aiSymbol
                
                // Izračunaj score za ovaj potez koristeći minimax
                let score = minimax(board: newBoard, depth: 0, isMaximizing: false, alpha: Int.min, beta: Int.max)
                
                if score > bestScore {
                    bestScore = score
                    bestMove = i
                }
            }
        }
        
        return bestMove
    }
    
    private func minimax(board: [String], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        let aiSymbol = playerSettings.aiSymbol
        let playerSymbol = playerSettings.playerSymbol
        
        // Proveri da li je igra gotova
        if let winner = checkWinner(in: board) {
            if winner == aiSymbol {
                return 10 - depth // Pobeda AI-a
            } else if winner == playerSymbol {
                return depth - 10 // Pobeda igrača
            }
            return 0 // Nerešeno
        }
        
        if isMaximizing {
            var bestScore = Int.min
            for i in 0..<9 {
                if board[i].isEmpty {
                    var newBoard = board
                    newBoard[i] = aiSymbol
                    let score = minimax(board: newBoard, depth: depth + 1, isMaximizing: false, alpha: alpha, beta: beta)
                    bestScore = max(score, bestScore)
                    let newAlpha = max(alpha, bestScore)
                    if beta <= newAlpha {
                        break // Alpha cutoff
                    }
                }
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for i in 0..<9 {
                if board[i].isEmpty {
                    var newBoard = board
                    newBoard[i] = playerSymbol
                    let score = minimax(board: newBoard, depth: depth + 1, isMaximizing: true, alpha: alpha, beta: beta)
                    bestScore = min(score, bestScore)
                    let newBeta = min(beta, bestScore)
                    if newBeta <= alpha {
                        break // Beta cutoff
                    }
                }
            }
            return bestScore
        }
    }
    
    private func findWinningMove(for player: String, in board: [String]) -> Int? {
        let winningCombinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
            [0, 4, 8], [2, 4, 6]             // diagonal
        ]
        
        for combination in winningCombinations {
            let values = combination.map { board[$0] }
            let playerCount = values.filter { $0 == player }.count
            let emptyCount = values.filter { $0.isEmpty }.count
            
            if playerCount == 2 && emptyCount == 1 {
                return combination.first { board[$0].isEmpty }
            }
        }
        
        return nil
    }
    
    private func checkWinner(in board: [String]) -> String? {
        let winningCombinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
            [0, 4, 8], [2, 4, 6]             // diagonal
        ]
        
        for combination in winningCombinations {
            let values = combination.map { board[$0] }
            if values[0] != "" && values[0] == values[1] && values[1] == values[2] {
                return values[0]
            }
        }
        
        return nil
    }
} 