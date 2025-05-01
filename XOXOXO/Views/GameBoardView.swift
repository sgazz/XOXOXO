import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameLogic: GameLogic
    
    var body: some View {
        VStack {
            // Game board
            VStack(spacing: 5) {
                ForEach(0..<3) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<3) { col in
                            let index = row * 3 + col
                            Button(action: {
                                gameLogic.makeMove(at: index, in: gameLogic.currentBoard)
                            }) {
                                Text(gameLogic.boards[gameLogic.currentBoard][index])
                                    .font(.system(size: 40))
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .accessibilityIdentifier("cell_\(row + 1)_\(col + 1)")
                            .accessibilityLabel(gameLogic.boards[gameLogic.currentBoard][index].isEmpty ? "Empty cell at row \(row + 1), column \(col + 1)" : "\(gameLogic.boards[gameLogic.currentBoard][index]) at row \(row + 1), column \(col + 1)")
                        }
                    }
                }
            }
            .accessibilityIdentifier("gameBoard")
            
            // Score display
            HStack {
                Text("X: \(gameLogic.totalScore.x) - O: \(gameLogic.totalScore.o)")
                    .font(.title)
                    .padding()
                    .accessibilityIdentifier("score")
            }
            
            // Game mode button
            Button(action: {
                gameLogic.setGameMode(gameLogic.gameMode == .aiOpponent ? .playerVsPlayer : .aiOpponent)
            }) {
                Text(gameLogic.gameMode == .aiOpponent ? "vs AI" : "Player vs Player")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("gameModeLabel")
            
            // Reset button
            Button(action: {
                gameLogic.resetGame()
            }) {
                Text("Reset Game")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("resetButton")
            
            // Stats button
            Button(action: {
                // Show statistics view
            }) {
                Text("Statistics")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("allTimeStatsButton")
            
            // Tutorial button
            Button(action: {
                // Show tutorial view
            }) {
                Text("How to Play")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("tutorialButton")
            
            // Winner label (hidden by default)
            if let winner = gameLogic.checkBoardWinner(in: gameLogic.currentBoard) {
                Text("\(winner) Wins!")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
                    .accessibilityIdentifier("winner")
            }
            
            // Error message (hidden by default)
            if gameLogic.isThinking {
                Text("Invalid move!")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .accessibilityIdentifier("error")
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("GameBoardView")
    }
} 