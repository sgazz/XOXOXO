import Foundation

class TicTacToeAI {
    static let shared = TicTacToeAI()
    
    private init() {}
    
    func makeMove(in board: [String]) -> Int? {
        // First, check if AI can win in the next move
        if let winningMove = findWinningMove(for: "O", in: board) {
            return winningMove
        }
        
        // Then check if we need to block player's winning move
        if let blockingMove = findWinningMove(for: "X", in: board) {
            return blockingMove
        }
        
        // If no winning moves, choose a random empty spot
        let emptySpots = board.enumerated().filter { $0.element.isEmpty }.map { $0.offset }
        return emptySpots.randomElement()
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
} 