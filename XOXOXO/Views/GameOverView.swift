import SwiftUI

struct GameOverView: View {
    // Подаци
    let timeoutPlayer: String?
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    
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
                
                if isLandscape {
                    // Landscape layout
                    VStack(spacing: spacing) {
                        Spacer()
                        
                        GameOverIcon(timeoutPlayer: timeoutPlayer)
                            .frame(width: min(geometry.size.width * 0.2, 150))
                        GameOverTitle(timeoutPlayer: timeoutPlayer, score: score)
                        
                        GameStats(
                            playerXTime: playerXTime,
                            playerOTime: playerOTime,
                            score: score
                        )
                        GameModeButtons(
                            onPlayVsAI: { 
                                selectedGameMode = .aiOpponent
                                showGameModeModal = true 
                            },
                            onPlayVsPlayer: { 
                                selectedGameMode = .playerVsPlayer
                                showGameModeModal = true 
                            }
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(spacing)
                } else {
                    // Portrait layout
                    VStack(spacing: spacing) {
                        Spacer()
                        
                        GameOverIcon(timeoutPlayer: timeoutPlayer)
                            .frame(width: min(geometry.size.width * 0.4, 150))
                        GameOverTitle(timeoutPlayer: timeoutPlayer, score: score)
                        GameStats(
                            playerXTime: playerXTime,
                            playerOTime: playerOTime,
                            score: score
                        )
                        GameModeButtons(
                            onPlayVsAI: { 
                                selectedGameMode = .aiOpponent
                                showGameModeModal = true 
                            },
                            onPlayVsPlayer: { 
                                selectedGameMode = .playerVsPlayer
                                showGameModeModal = true 
                            }
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(spacing)
                }
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
}

// MARK: - Подкомпоненте
private struct GameOverIcon: View {
    let timeoutPlayer: String?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Позадински ефекти
            ZStack {
                // Плави светлосни зраци
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(Theme.Colors.primaryBlue)
                        .frame(width: 100, height: 2)
                        .blur(radius: 15)
                        .rotationEffect(.degrees(Double(i) * 45 - 60))
                        .offset(x: -50)
                        .opacity(0.4)
                }
                
                // Наранџасти светлосни зраци
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(Theme.Colors.primaryOrange)
                        .frame(width: 100, height: 2)
                        .blur(radius: 15)
                        .rotationEffect(.degrees(Double(i) * 45 + 60))
                        .offset(x: 50)
                        .opacity(0.4)
                }
            }
            
            // Главни металик прстен
            Circle()
                .fill(Theme.Colors.darkGradient)
                .overlay(
                    ZStack {
                        // Унутрашњи прстен са текстуром
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.6),
                                        Color.black.opacity(0.3),
                                        Color.gray.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 15
                            )
                            .padding(25)
                        
                        // Квадратна "дугмад" на прстену
                        ForEach(0..<12) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(LinearGradient(
                                    colors: [
                                        Theme.Colors.primaryGold,
                                        Theme.Colors.primaryGold.opacity(0.7)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: 12, height: 12)
                                .offset(y: -85)
                                .rotationEffect(.degrees(Double(i) * 30))
                                .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 5)
                        }
                        
                        // XO текст
                        VStack(spacing: 5) {
                            Text("XO")
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Theme.Colors.primaryGold,
                                            Theme.Colors.primaryGold.opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            Text("ARENA")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.Colors.metalGray)
                        }
                        .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 5)
                    }
                )
                .overlay(
                    // Спољашња ивица
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.primaryGold.opacity(0.8),
                                    Theme.Colors.primaryGold.opacity(0.3),
                                    Theme.Colors.primaryGold.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        }
        .shadow(
            color: Theme.Colors.primaryGold.opacity(0.3),
            radius: 20
        )
        .rotation3DEffect(.degrees(isAnimating ? 360 : 0), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

private struct GameOverTitle: View {
    let timeoutPlayer: String?
    let score: (x: Int, o: Int)
    
    var body: some View {
        VStack(spacing: 8) {
            if let player = timeoutPlayer {
                Text("\(player == "X" ? "Player O" : "Player X") Wins!")
                    .font(Theme.TextStyle.title(size: 38))
                    .foregroundColor(Theme.Colors.primaryGold)
                    .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
            } else {
                Text(score.x > score.o ? "Player X Wins!" : "Player O Wins!")
                    .font(Theme.TextStyle.title(size: 38))
                    .foregroundColor(Theme.Colors.primaryGold)
                    .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
            }
        }
    }
}

private struct GameStats: View {
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        HStack(spacing: isCompact ? 20 : 30) {
            // Blue player time
            VStack {
                Text("Blue Time")
                    .font(Theme.TextStyle.body(size: 12))
                    .foregroundColor(Theme.Colors.metalGray)
                Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                    .font(Theme.TextStyle.subtitle(size: isCompact ? 24 : 30))
                    .foregroundColor(Theme.Colors.primaryBlue)
                    .shadow(color: Theme.Colors.primaryBlue.opacity(0.5), radius: 5)
            }
            
            // Score
            VStack {
                Text("Score")
                    .font(Theme.TextStyle.body(size: 12))
                    .foregroundColor(Theme.Colors.metalGray)
                Text("\(score.x):\(score.o)")
                    .font(Theme.TextStyle.title(size: isCompact ? 32 : 40))
                    .foregroundColor(Theme.Colors.primaryGold)
                    .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 5)
            }
            
            // Red player time
            VStack {
                Text("Red Time")
                    .font(Theme.TextStyle.body(size: 12))
                    .foregroundColor(Theme.Colors.metalGray)
                Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                    .font(Theme.TextStyle.subtitle(size: isCompact ? 24 : 30))
                    .foregroundColor(Theme.Colors.primaryOrange)
                    .shadow(color: Theme.Colors.primaryOrange.opacity(0.5), radius: 5)
            }
        }
        .padding(.vertical, isCompact ? 10 : 15)
        .padding(.horizontal, isCompact ? 15 : 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.Colors.darkGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Theme.Colors.primaryGold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Theme.Colors.primaryGold.opacity(0.2), radius: 20)
        )
    }
}

private struct GameModeButtons: View {
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Button(action: onPlayVsAI) {
                HStack {
                    Image(systemName: "cpu")
                    Text("Single Player")
                }
                .font(Theme.TextStyle.subtitle(size: isCompact ? 20 : 24))
                .foregroundColor(Theme.Colors.primaryBlue)
                .frame(width: isCompact ? 250 : 300)
                .padding(.vertical, isCompact ? 15 : 20)
                .glowingBorder(color: Theme.Colors.primaryBlue)
            }
            .buttonStyle(Theme.MetallicButtonStyle())
            
            Button(action: onPlayVsPlayer) {
                HStack {
                    Image(systemName: "person.2")
                    Text("Multiplater")
                }
                .font(Theme.TextStyle.subtitle(size: isCompact ? 20 : 24))
                .foregroundColor(Theme.Colors.primaryOrange)
                .frame(width: isCompact ? 250 : 300)
                .padding(.vertical, isCompact ? 15 : 20)
                .glowingBorder(color: Theme.Colors.primaryOrange)
            }
            .buttonStyle(Theme.MetallicButtonStyle())
        }
        .padding(.top, isCompact ? 30 : 40)
    }
}

#Preview {
    GameOverView(
        timeoutPlayer: "X",
        playerXTime: 0,
        playerOTime: 180,
        score: (x: 3, o: 5),
        onPlayVsAI: {},
        onPlayVsPlayer: {}
    )
} 
