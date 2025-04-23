import SwiftUI

// MARK: - ActionButton Component
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playSound(.tap)
            action()
        }) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct ResultView: View {
    // Подаци
    let score: (x: Int, o: Int)
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    
    // Акције
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showGameModeModal = false
    @State private var selectedGameMode: GameMode = .aiOpponent
    @State private var showGameView = false
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                // Title
                Text("🏆 Results")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                // Score Block
                HStack(spacing: 16) {
                    scoreBlock(symbol: "X", score: score.x, color: .blue)
                    
                    Text("vs")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    scoreBlock(symbol: "O", score: score.o, color: .red)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Game Statistics")

                Spacer(minLength: 20)
                
                // Buttons
                VStack(spacing: 14) {
                    ActionButton(
                        title: "Single Player",
                        icon: "cpu",
                        color: .blue,
                        action: { 
                            SoundManager.shared.playSound(.tap)
                            selectedGameMode = .aiOpponent
                            showGameModeModal = true 
                        }
                    )
                    
                    ActionButton(
                        title: "Multiplayer",
                        icon: "person.2",
                        color: .green,
                        action: {
                            SoundManager.shared.playSound(.tap)
                            selectedGameMode = .playerVsPlayer
                            showGameModeModal = true
                        }
                    )
                    
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onPlayVsAI()
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Game Options")
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .frame(maxWidth: 400)
            .padding(.horizontal, deviceLayout.gridPadding)
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(), value: score.x + score.o)
            .accessibilityElement(children: .contain)
            
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
    }
    
    // MARK: - Score Block
    private func scoreBlock(symbol: String, score: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(symbol)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text("\(score)")
                .font(.title.bold())
                .foregroundColor(.primary)
        }
        .frame(minWidth: 80)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(symbol): \(score)")
    }
}

#Preview {
    ResultView(
        score: (5, 3),
        playerXTime: 0,
        playerOTime: 0,
        onPlayVsAI: {},
        onPlayVsPlayer: {}
    )
} 