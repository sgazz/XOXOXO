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
                    HStack(spacing: spacing) {
                        // Лева страна - икона и наслов
                        VStack(spacing: spacing) {
                            GameOverIcon(timeoutPlayer: timeoutPlayer)
                                .frame(width: min(geometry.size.width * 0.3, 150))
                            GameOverTitle(timeoutPlayer: timeoutPlayer)
                        }
                        .frame(width: geometry.size.width * 0.4)
                        
                        // Десна страна - статистика и дугмад
                        VStack(spacing: spacing) {
                            GameStats(
                                playerXTime: playerXTime,
                                playerOTime: playerOTime,
                                score: score
                            )
                            GameModeButtons(
                                isPvPUnlocked: isPvPUnlocked,
                                onPlayVsAI: onPlayVsAI,
                                onPlayVsPlayer: onPlayVsPlayer,
                                onShowPurchase: onShowPurchase
                            )
                        }
                        .frame(width: geometry.size.width * 0.6)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(spacing)
                } else {
            // Portrait layout
                    VStack(spacing: spacing) {
                GameOverIcon(timeoutPlayer: timeoutPlayer)
                            .frame(width: min(geometry.size.width * 0.4, 150))
                GameOverTitle(timeoutPlayer: timeoutPlayer)
                GameStats(
                    playerXTime: playerXTime,
                    playerOTime: playerOTime,
                    score: score
                )
                GameModeButtons(
                    isPvPUnlocked: isPvPUnlocked,
                    onPlayVsAI: onPlayVsAI,
                    onPlayVsPlayer: onPlayVsPlayer,
                    onShowPurchase: onShowPurchase
                )
            }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(spacing)
                }
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
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Game Over")
                .font(.system(size: 38, weight: .heavy))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2)
            
            if let player = timeoutPlayer {
                Text("\(player == "X" ? "Blue" : "Red") player ran out of time!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
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
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // PvAI дугме
            Button(action: onPlayVsAI) {
                HStack {
                    Image(systemName: "cpu")
                        .font(isCompact ? .title2 : .title)
                    Text("Single Player")
                        .font(isCompact ? .title2.bold() : .title.bold())
                }
                .foregroundColor(.white)
                .frame(width: isCompact ? 200 : 250, height: isCompact ? 45 : 55)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.4, blue: 0.9),
                                    Color(red: 0.2, green: 0.3, blue: 0.7)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.5), radius: 10, x: 0, y: 5)
            }
    
            // PvP дугме
            Button(action: {
                if isPvPUnlocked {
                    onPlayVsPlayer()
                } else {
                    onShowPurchase()
                }
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(isCompact ? .title2 : .title)
                    Text("Multiplayer")
                        .font(isCompact ? .title2.bold() : .title.bold())
                }
                .foregroundColor(.white)
                .frame(width: isCompact ? 200 : 250, height: isCompact ? 45 : 55)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isPvPUnlocked ? [
                                    Color(red: 0.2, green: 0.6, blue: 0.3),
                                    Color(red: 0.1, green: 0.5, blue: 0.2)
                                ] : [
                                    Color.gray.opacity(0.6),
                                    Color.gray.opacity(0.4)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    Group {
                        if !isPvPUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                                .offset(x: isCompact ? 85 : 110, y: -15)
                        }
                    }
                )
                .shadow(color: (isPvPUnlocked ? Color(red: 0.1, green: 0.5, blue: 0.2) : Color.gray).opacity(0.5), radius: 10, x: 0, y: 5)
            }
        }
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
