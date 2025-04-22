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
    let playerXScore: Int
    let playerOScore: Int
    let draws: Int
    let onNewGame: () -> Void
    let onClose: () -> Void
    let onShowPurchase: () -> Void
    let onPlayVsPlayer: () -> Void
    let isGamePaused: Bool
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showGameModeModal = false
    @State private var selectedGameMode: GameMode = .aiOpponent
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                // Title
                Text("🏆 Results")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                if isGamePaused {
                    Text("⏸️ Game Paused")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // Score Block
                HStack(spacing: 16) {
                    scoreBlock(symbol: "X", score: playerXScore, color: .blue)
                    
                    Text("vs")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    scoreBlock(symbol: "O", score: playerOScore, color: .red)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Game Statistics")

                // Draw info
                if draws > 0 {
                    Text("\(draws) Draw\(draws == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
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
                        title: purchaseManager.isPvPUnlocked ? "Multiplayer" : "Multiplayer (Locked)",
                        icon: "person.2",
                        color: purchaseManager.isPvPUnlocked ? .green : .gray,
                        action: {
                            SoundManager.shared.playSound(.tap)
                            if purchaseManager.isPvPUnlocked {
                                selectedGameMode = .playerVsPlayer
                                showGameModeModal = true
                            } else {
                                onShowPurchase()
                            }
                        }
                    )
                    
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onClose()
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
            .animation(.spring(), value: playerXScore + playerOScore + draws)
            .accessibilityElement(children: .contain)
            
            if showGameModeModal {
                GameModeModalView(
                    isPvPUnlocked: purchaseManager.isPvPUnlocked,
                    gameMode: selectedGameMode,
                    onPlayVsAI: {
                        showGameModeModal = false
                        onNewGame()
                    },
                    onPlayVsPlayer: {
                        showGameModeModal = false
                        onPlayVsPlayer()
                    },
                    onShowPurchase: {
                        showGameModeModal = false
                        onShowPurchase()
                    },
                    onClose: {
                        showGameModeModal = false
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
        playerXScore: 5,
        playerOScore: 3,
        draws: 1,
        onNewGame: {},
        onClose: {},
        onShowPurchase: {},
        onPlayVsPlayer: {},
        isGamePaused: true
    )
} 