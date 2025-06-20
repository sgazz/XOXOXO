import SwiftUI

struct GameOverView: View {
    // Подаци
    let timeoutPlayer: String?
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    let gameLogic: GameLogic
    
    // Акције
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    let onStart: () -> Void
    let onResetStatistics: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showGameModeModal = false
    @State private var selectedGameMode: GameMode = .aiOpponent
    @State private var isAISelected = false
    @State private var isMultiplayerSelected = false
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            // Metallic background with accent lights
            Theme.Colors.darkGradient
                .overlay(
                    ZStack {
                        // Victory light beam
                        Circle()
                            .fill(Theme.Colors.primaryGold)
                            .frame(width: UIScreen.main.bounds.width * 1.5)
                            .offset(y: -UIScreen.main.bounds.height * 0.8)
                            .blur(radius: 100)
                            .opacity(0.3)
                        
                        // Accent lights
                        Circle()
                            .fill(Theme.Colors.primaryBlue)
                            .frame(width: UIScreen.main.bounds.width)
                            .offset(x: -UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.3)
                            .blur(radius: 100)
                            .opacity(0.2)
                        
                        Circle()
                            .fill(Theme.Colors.primaryOrange)
                            .frame(width: UIScreen.main.bounds.width)
                            .offset(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.3)
                            .blur(radius: 100)
                            .opacity(0.2)
                    }
                )
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let spacing = deviceLayout.adaptiveSpacing
                gameOverContent(geometry: geometry, spacing: spacing)
            }
            
            if showGameModeModal {
                GameModeModalView(
                    gameMode: selectedGameMode,
                    onPlayVsAI: {
                        showGameModeModal = false
                        onPlayVsAI()
                    },
                    onPlayVsPlayer: {
                        showGameModeModal = false
                        onPlayVsPlayer()
                    },
                    onClose: {
                        showGameModeModal = false
                    },
                    onGameModeChange: { newMode in
                        selectedGameMode = newMode
                    }
                )
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        ))
    }

    private func gameOverContent(geometry: GeometryProxy, spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
            GameOverTitle(timeoutPlayer: timeoutPlayer, score: score)
            StatisticsView(
                playerXTime: playerXTime,
                playerOTime: playerOTime,
                score: score,
                totalMoves: gameLogic.totalMoves,
                playerStats: gameLogic.playerStats,
                onResetStatistics: onResetStatistics
            )
            
            GameModeButtons(
                onStart: {
                    showGameModeModal = true
                }
            )
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(spacing)
    }
}

// MARK: - Подкомпоненте
private struct GameOverTitle: View {
    let timeoutPlayer: String?
    let score: (x: Int, o: Int)
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        let title: String = {
            if let player = timeoutPlayer {
                return "\((player == "X") ? "Player O" : "Player X") Wins!"
            } else {
                return score.x > score.o ? "Player X Wins!" : "Player O Wins!"
            }
        }()
        Text(title)
            .font(Theme.TextStyle.title(size: isCompact ? 32 : 38))
            .foregroundColor(Theme.Colors.primaryGold)
            .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
            .frame(width: isCompact ? 250 : 300)
            .padding(.vertical, isCompact ? 12 : 15)
            .glowingBorder(color: Theme.Colors.primaryGold)
    }
}

private struct GameModeButtons: View {
    let onStart: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Button(action: {
                SoundManager.shared.playSound(.tap)
                SoundManager.shared.playHaptic()
                onStart()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play Again")
                }
                .font(Theme.TextStyle.subtitle(size: isCompact ? 16 : 18))
                .foregroundColor(Theme.Colors.primaryGold)
                .frame(width: isCompact ? 250 : 300)
                .padding(.vertical, isCompact ? 12 : 15)
                .glowingBorder(color: Theme.Colors.primaryGold)
            }
            .buttonStyle(Theme.MetallicButtonStyle())
        }
    }
}

#Preview {
    GameOverView(
        timeoutPlayer: nil,
        playerXTime: 120,
        playerOTime: 180,
        score: (x: 3, o: 5),
        gameLogic: GameLogic(),
        onPlayVsAI: {},
        onPlayVsPlayer: {},
        onStart: {},
        onResetStatistics: {}
    )
    .preferredColorScheme(.dark)
} 
