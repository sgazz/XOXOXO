import SwiftUI

struct GameOverView: View {
    // Подаци
    let timeoutPlayer: String?
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    let isPvPUnlocked: Bool
    
    // Акције
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    let onShowPurchase: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showGameModeModal = false
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    var body: some View {
        ZStack {
            // Замагљена позадина са градијентом
            backgroundGradient
                .blur(radius: 20)
                .opacity(0.98)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let spacing = deviceLayout.adaptiveSpacing
                
                if isLandscape {
                    // Landscape layout
                    VStack(spacing: spacing) {
                        Spacer()
                        
                        // Икона и наслов
                        GameOverIcon(timeoutPlayer: timeoutPlayer)
                            .frame(width: min(geometry.size.width * 0.2, 150))
                        GameOverTitle(timeoutPlayer: timeoutPlayer, score: score)
                        
                        // Статистика и дугмад
                        GameStats(
                            playerXTime: playerXTime,
                            playerOTime: playerOTime,
                            score: score
                        )
                        GameModeButtons(
                            isPvPUnlocked: purchaseManager.isPvPUnlocked,
                            onPlayVsAI: { showGameModeModal = true },
                            onPlayVsPlayer: { showGameModeModal = true },
                            onShowPurchase: onShowPurchase
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
                            isPvPUnlocked: purchaseManager.isPvPUnlocked,
                            onPlayVsAI: { showGameModeModal = true },
                            onPlayVsPlayer: { showGameModeModal = true },
                            onShowPurchase: onShowPurchase
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(spacing)
                }
            }
            
            if showGameModeModal {
                GameModeModalView(
                    isPvPUnlocked: purchaseManager.isPvPUnlocked,
                    onPlayVsAI: {
                        showGameModeModal = false
                        onPlayVsAI()
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
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        ))
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.2, blue: 0.45), // Deep blue
                Color(red: 0.2, green: 0.3, blue: 0.7),  // Medium blue
                Color(red: 0.3, green: 0.4, blue: 0.9)   // Light blue
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Подкомпоненте
private struct GameOverIcon: View {
    let timeoutPlayer: String?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        timeoutPlayer == nil ? Color.green : Color.red,
                        timeoutPlayer == nil ? Color.blue : Color.orange
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: (timeoutPlayer == nil ? Color.green : Color.red).opacity(0.5), radius: 15)
            
            Image(systemName: timeoutPlayer == nil ? "trophy.fill" : "timer")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2)
        }
        .scaleEffect(1.2)
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
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2)
            } else {
                Text(score.x > score.o ? "Player X Wins!" : "Player O Wins!")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2)
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
            // Време плавог играча
            VStack {
                Text("Blue Time")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                    .font(isCompact ? .title2.bold() : .title.bold())
                    .foregroundColor(.blue)
            }
            
            // Резултат
            VStack {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(score.x):\(score.o)")
                    .font(isCompact ? .title.bold() : .largeTitle.bold())
                    .foregroundColor(.white)
            }
            
            // Време црвеног играча
            VStack {
                Text("Red Time")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                    .font(isCompact ? .title2.bold() : .title.bold())
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, isCompact ? 10 : 15)
        .padding(.horizontal, isCompact ? 15 : 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
}

private struct GameModeButtons: View {
    let isPvPUnlocked: Bool
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    let onShowPurchase: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 15 : 10) {
            // Single Player mode button
            Button(action: {
                SoundManager.shared.playSound(.tap)
                onPlayVsAI()
            }) {
                aiButtonContent(isIPad: isIPad)
            }
            
            // Multiplayer mode button
            Button(action: {
                SoundManager.shared.playSound(.tap)
                if isPvPUnlocked {
                    onPlayVsPlayer()
                } else {
                    onShowPurchase()
                }
            }) {
                pvpButtonContent(isIPad: isIPad)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func aiButtonContent(isIPad: Bool) -> some View {
        let fontSize = isIPad ? 32.0 : 22.0
        
        return HStack(spacing: isIPad ? 20.0 : 15.0) {
            Image(systemName: "cpu")
                .font(.system(size: fontSize))
                .layoutPriority(1)
            Text("Single Player")
                .font(.system(size: fontSize, weight: .bold))
                .layoutPriority(2)
                .minimumScaleFactor(0.5)
        }
        .foregroundColor(.white)
        .frame(maxWidth: isIPad ? 500.0 : 400.0)
        .padding(.horizontal, isIPad ? 20.0 : 15.0)
        .padding(.vertical, isIPad ? 15.0 : 10.0)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.7))
                .shadow(color: Color.black.opacity(0.3), radius: isIPad ? 8.0 : 5.0)
        )
    }
    
    private func pvpButtonContent(isIPad: Bool) -> some View {
        let fontSize = isIPad ? 32.0 : 22.0
        
        let isUnlocked = isPvPUnlocked
        let backgroundColor = isUnlocked ? Color.purple.opacity(0.3) : Color.white.opacity(0.15)
        let shadowColor = isUnlocked ? Color.purple.opacity(0.3) : Color.black.opacity(0.1)
        
        return HStack(spacing: isIPad ? 20.0 : 15.0) {
            Image(systemName: "person.2")
                .font(.system(size: fontSize))
                .layoutPriority(1)
            Text("Multiplayer")
                .font(.system(size: fontSize, weight: .bold))
                .layoutPriority(2)
                .minimumScaleFactor(0.5)
            
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: fontSize * 0.8))
                    .foregroundColor(.yellow)
                    .layoutPriority(1)
            }
        }
        .foregroundColor(.white.opacity(0.8))
        .frame(maxWidth: isIPad ? 500.0 : 400.0)
        .padding(.horizontal, isIPad ? 20.0 : 15.0)
        .padding(.vertical, isIPad ? 15.0 : 10.0)
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: isIPad ? 8.0 : 5.0)
        )
    }
}

#Preview {
    GameOverView(
        timeoutPlayer: "X",
        playerXTime: 0,
        playerOTime: 180,
        score: (x: 3, o: 5),
        isPvPUnlocked: false,
        onPlayVsAI: {},
        onPlayVsPlayer: {},
        onShowPurchase: {}
    )
} 
