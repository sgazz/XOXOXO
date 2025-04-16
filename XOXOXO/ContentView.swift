//
//  ContentView.swift
//  XOXOXO
//
//  Created by Gazza on 15. 4. 2025..
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameLogic = GameLogic()
    @State private var isAIEnabled = true
    @State private var winningPlayer: String? = nil
    
    // Dynamic layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
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
                    // Header section
                    VStack(spacing: 10) {
                        // Score display
                        HStack(spacing: 15) {
                            Text("\(gameLogic.totalScore.x)")
                                .foregroundColor(.blue)
                                .font(isIPad ? .system(size: 48, weight: .bold) : .system(size: 36, weight: .bold))
                            
                            Text(":")
                                .font(isIPad ? .system(size: 48, weight: .bold) : .system(size: 36, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Text("\(gameLogic.totalScore.o)")
                                .foregroundColor(.red)
                                .font(isIPad ? .system(size: 48, weight: .bold) : .system(size: 36, weight: .bold))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                                .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.2), 
                                        radius: 5, x: 0, y: 2)
                        )
                        
                        // AI Button
                        Button(action: {
                            if !gameLogic.boards.flatMap({ $0 }).contains(where: { $0 != "" }) {
                                isAIEnabled.toggle()
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playLightHaptic()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isAIEnabled ? "cpu.fill" : "cpu")
                                Text(isAIEnabled ? "AI: ON" : "AI: OFF")
                            }
                            .font(isIPad ? .title3 : .headline)
                            .foregroundColor(isAIEnabled ? .white : .blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isAIEnabled ? Color.blue : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: isAIEnabled ? 0 : 2)
                                    )
                            )
                        }
                        .opacity(gameLogic.boards.flatMap({ $0 }).contains(where: { $0 != "" }) ? 0.5 : 1.0)
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
                                       gameLogic.currentPlayer == "X" &&
                                       gameLogic.currentBoard == index {
                                        
                                        // Звук и хаптика за потез играча
                                        SoundManager.shared.playSound(.move)
                                        SoundManager.shared.playHaptic()
                                        
                                        gameLogic.makeMove(at: position, in: index)
                                        
                                        // Проверавамо да ли је крај игре
                                        checkGameEnd()
                                        
                                        if isAIEnabled && !gameLogic.gameOver {
                                            gameLogic.makeAIMove(in: index) {
                                                // Sound for AI move
                                                SoundManager.shared.playSound(.move)
                                                
                                                // Проверавамо да ли је крај игре након AI потеза
                                                checkGameEnd()
                                            }
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
                        VStack(spacing: 15) {
                            Text(gameLogic.winner != nil ? "Tournament Winner: \(gameLogic.winner!)" : "Tournament Draw!")
                                .font(isIPad ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundColor(gameLogic.winner == "X" ? .blue : (gameLogic.winner == "O" ? .red : .gray))
                                .padding()
                            
                            Button(action: {
                                withAnimation {
                                    resetGame()
                                }
                            }) {
                                Text("Play Again")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                                .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.2), 
                                        radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .onChange(of: gameLogic.winner) { newWinner in
            if let winner = newWinner {
                winningPlayer = winner
                if winner == "X" {
                    // Player win animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SoundManager.shared.playSound(.win)
                        SoundManager.shared.playHeavyHaptic()
                    }
                } else {
                    // AI win
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SoundManager.shared.playSound(.lose)
                        SoundManager.shared.playHaptic(style: .heavy)
                    }
                }
            } else if gameLogic.gameOver {
                // Draw
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SoundManager.shared.playSound(.draw)
                    SoundManager.shared.playHaptic()
                }
            }
        }
    }
    
    private func checkGameEnd() {
        if gameLogic.gameOver && winningPlayer == nil {
            if let winner = gameLogic.winner {
                winningPlayer = winner
            }
        }
    }
    
    private func resetGame() {
        SoundManager.shared.playSound(.tap)
        SoundManager.shared.playLightHaptic()
        
        gameLogic.resetGame()
        winningPlayer = nil
    }
}

struct ContentView: View {
    var body: some View {
        SplashView()
    }
}

#Preview {
    ContentView()
}
