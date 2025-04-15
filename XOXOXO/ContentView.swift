//
//  ContentView.swift
//  XOXOXO
//
//  Created by Gazza on 15. 4. 2025..
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameLogic = GameLogic()
    @State private var isAIEnabled = true
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button("Reset All") {
                    gameLogic.resetGame()
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Toggle("AI", isOn: $isAIEnabled)
                    .padding()
                    .disabled(gameLogic.boards.flatMap { $0 }.contains { $0 != "" })
            }
            
            Text("XOXOXO")
                .font(.title)
                .padding(.bottom, 5)
            
            if gameLogic.isThinking {
                Text("AI is thinking...")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
            
            VStack(spacing: 15) {
                ForEach(0..<3) { row in
                    HStack(spacing: 15) {
                        ForEach(0..<2) { col in
                            let index = row * 2 + col
                            BoardView(
                                board: .init(
                                    get: { gameLogic.boards[index] },
                                    set: { gameLogic.boards[index] = $0 }
                                ),
                                isActive: gameLogic.currentBoard == index && !gameLogic.gameOver,
                                onTap: { position in
                                    if gameLogic.boards[index][position].isEmpty && 
                                       !gameLogic.isThinking && 
                                       gameLogic.currentPlayer == "X" {
                                        gameLogic.makeMove(at: position, in: index)
                                        if isAIEnabled && !gameLogic.gameOver {
                                            gameLogic.makeAIMove(in: index) {}
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding()
            
            if gameLogic.gameOver {
                Text(gameLogic.winner != nil ? "Победник: \(gameLogic.winner!)" : "Нерешено!")
                    .font(.title2)
                    .padding()
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
