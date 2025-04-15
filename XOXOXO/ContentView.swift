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
    
    // Dynamic layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var gridLayout: [GridItem] {
        if isLandscape {
            // In landscape, show 8 boards in 2 rows of 4
            Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
        } else {
            // In portrait, show 8 boards in 4 rows of 2
            Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Header section with controls
                    Group {
                        if isIPad {
                            HStack {
                                headerContent
                            }
                            .padding(.horizontal)
                        } else {
                            VStack {
                                headerContent
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, isIPad ? 20 : 10)
                    
                    // Game boards grid
                    LazyVGrid(
                        columns: gridLayout,
                        spacing: isIPad ? 30 : 20
                    ) {
                        ForEach(0..<8) { index in
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
                            .frame(maxWidth: isIPad ? 180 : 120)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    
                    if gameLogic.gameOver {
                        Text(gameLogic.winner != nil ? "Winner: \(gameLogic.winner!)" : "Draw!")
                            .font(isIPad ? .title : .title2)
                            .padding()
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var headerContent: some View {
        Group {
            Text("XO Tournament")
                .font(isIPad ? .largeTitle : .title)
                .padding(.bottom, 5)
            
            HStack {
                Button("Reset All") {
                    gameLogic.resetGame()
                }
                .font(isIPad ? .title2 : .headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Toggle("AI", isOn: $isAIEnabled)
                    .padding()
                    .disabled(gameLogic.boards.flatMap { $0 }.contains { $0 != "" })
            }
        }
    }
}

#Preview {
    ContentView()
}
