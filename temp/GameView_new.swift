import SwiftUI
struct GameView: View {
    @StateObject private var gameLogic: GameLogic
    @State private var winningPlayer: String? = nil
    var isPvPUnlocked: Bool = false

    // Dynamic layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme

    // Initializer that accepts a game mode
    init(gameMode: GameMode = .aiOpponent, isPvPUnlocked: Bool = false) {
        _gameLogic = StateObject(wrappedValue: GameLogic(gameMode: gameMode))
        self.isPvPUnlocked = isPvPUnlocked
    }

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
                                .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.3),
                                        radius: 8, x: 0, y: 3)
                        )

                        // Player indicator (for PvP mode)
                        if gameLogic.gameMode == .playerVsPlayer {
                            HStack {
                                Text("Current Player:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text(gameLogic.currentPlayer)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(gameLogic.currentPlayer == "X" ? .blue : .red)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(gameLogic.currentPlayer == "X" ? .blue : .red).opacity(0.1))
                                    )
                            }
                            .padding(.vertical, 5)
                            .transition(.opacity)
                        }
                    }
                    .padding(.top, isIPad ? 20 : 10)

                    // Game boards grid
                    LazyVGrid(
                        columns: gridLayout,
                        spacing: isIPad ? 30 : 25
                    ) {
                        ForEach(0..<8) { index in
                            BoardView(
                                board: .init(
                                    get: { gameLogic.boards[index] },
                                    set: { gameLogic.boards[index] = $0 }
                                ),
                                isActive: gameLogic.currentBoard == index && !gameLogic.gameOver,
                                onTap: { position in
                                    // Check if valid move
                                    if gameLogic.boards[index][position].isEmpty &&
                                       !gameLogic.isThinking &&
                                       gameLogic.currentBoard == index &&
                                       (!gameLogic.gameOver) {

                                        // Sound and haptics for player move
                                        SoundManager.shared.playSound(.move)
                                        SoundManager.shared.playHaptic()

                                        gameLogic.makeMove(at: position, in: index)

                                        // Check if game ended
                                        checkGameEnd()

                                        // For AI mode, make AI move
                                        if gameLogic.gameMode == .aiOpponent && !gameLogic.gameOver {
                                            gameLogic.makeAIMove(in: index) {
                                                // Sound for AI move
                                                SoundManager.shared.playSound(.move)

                                                // Check if game ended after AI move
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
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)

                    // Game over modal
                    if gameLogic.gameOver {
                        VStack(spacing: 15) {
                            Text(gameLogic.winner == "Draw" ? "Tournament Draw!" : "Winner: \(gameLogic.winner)")
                                .font(isIPad ? .system(size: 40, weight: .bold) : .system(size: 32, weight: .bold))
                                .foregroundColor(gameLogic.winner == "X" ? .blue : (gameLogic.winner == "O" ? .red : .primary))
                                .shadow(color: gameLogic.winner == "X" ? .blue.opacity(0.5) : (gameLogic.winner == "O" ? .red.opacity(0.5) : .gray.opacity(0.5)), radius: 2)
                                .padding(.top, 10)

                            // Display player names based on game mode
                            if gameLogic.gameMode == .playerVsPlayer && gameLogic.winner != "Draw" {
                                Text(gameLogic.winner == "X" ? "Player 1 Wins!" : "Player 2 Wins!")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 5)
                            }

                            // Score display
                            HStack(spacing: 20) {
                                VStack {
                                    Text(gameLogic.gameMode == .playerVsPlayer ? "Player 1" : "X")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text("\(gameLogic.totalScore.x)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(gameLogic.winner == "X" ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                        .shadow(color: .gray.opacity(0.2), radius: 5)
                                )
                                .overlay(
                                    gameLogic.winner == "X" ?
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 3)
                                            .shadow(color: .blue.opacity(0.5), radius: 5)
                                    : nil
                                )

                                VStack {
                                    Text(gameLogic.gameMode == .playerVsPlayer ? "Player 2" : "O")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("\(gameLogic.totalScore.o)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(gameLogic.winner == "O" ? Color.red.opacity(0.2) : Color(.systemGray6))
                                        .shadow(color: .gray.opacity(0.2), radius: 5)
                                )
                                .overlay(
                                    gameLogic.winner == "O" ?
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.red, lineWidth: 3)
                                            .shadow(color: .red.opacity(0.5), radius: 5)
                                    : nil
                                )
                            }
                            .padding(.vertical, 10)

                            // Play Again button
                            Button(action: {
                                gameLogic.resetGame()
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                            }) {
                                Text("Play Again")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 3)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 10)
                        )
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(red: 0.12, green: 0.14, blue: 0.22) : Color(red: 0.9, green: 0.95, blue: 1.0),
                        colorScheme == .dark ? Color(red: 0.18, green: 0.2, blue: 0.3) : Color(red: 0.8, green: 0.9, blue: 0.98)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        // Update sound effects based on winner and game mode
        .onChange(of: gameLogic.winner) { newWinner in
            if let winner = newWinner {
                winningPlayer = winner
                
                if gameLogic.gameMode == .playerVsPlayer {
                    // In PvP mode always play win sound
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SoundManager.shared.playSound(.win)
                        SoundManager.shared.playHeavyHaptic()
                    }
                } else {
                    // In AI mode, differentiate between player and AI win
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

    // Helper functions
    private func checkGameEnd() {
        if gameLogic.gameOver && winningPlayer == nil {
            if let winner = gameLogic.winner {
                winningPlayer = winner
            }
        }
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
