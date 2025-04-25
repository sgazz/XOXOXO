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
    @State private var ringRotation = 0.0
    
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
            
            // Ротирајући метални прстен
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
                    }
                )
                .rotationEffect(.degrees(ringRotation))
            
            // XO текст (статичан)
            VStack(spacing: 5) {
                Text("XO")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.Colors.primaryGold.opacity(0.9),
                                Theme.Colors.primaryGold.opacity(0.7),
                                Theme.Colors.primaryGold.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Text("XO")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .offset(x: 1, y: 1)
                            .mask(
                                Text("XO")
                                    .font(.system(size: 36, weight: .heavy))
                            )
                    )
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.Colors.primaryGold.opacity(0.3),
                                        Theme.Colors.primaryGold.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 5)
                            .frame(width: 100, height: 100)
                    )
                
                Text("ARENA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.Colors.primaryGold.opacity(0.8),
                                Theme.Colors.primaryGold.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Text("ARENA")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .offset(x: 0.5, y: 0.5)
                            .mask(
                                Text("ARENA")
                                    .font(.system(size: 14, weight: .bold))
                            )
                    )
            }
            .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 5)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.Colors.primaryGold.opacity(0.2),
                                Theme.Colors.primaryGold.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
            )
        }
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
        .shadow(
            color: Theme.Colors.primaryGold.opacity(0.3),
            radius: 20
        )
        .onAppear {
            // Покрећемо бесконачну ротацију прстена
            withAnimation(
                .linear(duration: 10)
                .repeatForever(autoreverses: false)
            ) {
                ringRotation = 360
            }
            
            // Анимација појављивања иконе
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
            // Плави играч
            StatBox(
                title: "Blue Time",
                value: String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60),
                color: Theme.Colors.primaryBlue
            )
            
            // Резултат
            StatBox(
                title: "Score",
                value: "\(score.x):\(score.o)",
                color: Theme.Colors.primaryGold,
                isScore: true
            )
            
            // Црвени играч
            StatBox(
                title: "Red Time",
                value: String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60),
                color: Theme.Colors.primaryOrange
            )
        }
        .padding(.vertical, isCompact ? 10 : 15)
        .padding(.horizontal, isCompact ? 15 : 25)
        .background(
            ZStack {
                // Основни градијент
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.Colors.darkGradient)
                
                // Горње светло
                Circle()
                    .fill(Theme.Colors.primaryGold)
                    .frame(width: 100, height: 100)
                    .offset(y: -50)
                    .blur(radius: 70)
                    .opacity(0.1)
                
                // Лево светло
                Circle()
                    .fill(Theme.Colors.primaryBlue)
                    .frame(width: 80, height: 80)
                    .offset(x: -40)
                    .blur(radius: 60)
                    .opacity(0.08)
                
                // Десно светло
                Circle()
                    .fill(Theme.Colors.primaryOrange)
                    .frame(width: 80, height: 80)
                    .offset(x: 40)
                    .blur(radius: 60)
                    .opacity(0.08)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Theme.Colors.primaryGold.opacity(0.5),
                            Theme.Colors.primaryGold.opacity(0.2),
                            Theme.Colors.primaryGold.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Theme.Colors.primaryGold.opacity(0.15), radius: 15)
    }
}

private struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    var isScore: Bool = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(Theme.TextStyle.body(size: 12))
                .foregroundColor(Theme.Colors.metalGray)
            Text(value)
                .font(Theme.TextStyle.subtitle(size: isScore ? (isCompact ? 32 : 40) : (isCompact ? 24 : 30)))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 5)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1),
                            color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
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
