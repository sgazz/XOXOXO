import SwiftUI

struct GameModeModalView: View {
    let gameMode: GameMode
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    let onClose: () -> Void
    let onGameModeChange: (GameMode) -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var playerSettings = PlayerSettings.shared
    @StateObject private var timerSettings = GameTimerSettings.shared
    
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
            // Замућена позадина са металик градијентом
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Модални прозор
            VStack(spacing: isIPad ? 20 : 15) {
                // Title
                Text("Choose Your Game Mode")
                    .font(Theme.TextStyle.title(size: isIPad ? 32 : 24))
                    .foregroundColor(Theme.Colors.primaryGold)
                    .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
                
                // Game mode buttons
                HStack(spacing: isIPad ? 20 : 15) {
                    // Single Player button
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onGameModeChange(.aiOpponent)
                    }) {
                        HStack {
                            Image(systemName: "cpu")
                            Text("Single Player")
                        }
                        .font(Theme.TextStyle.subtitle(size: isIPad ? 24 : 20))
                        .foregroundColor(gameMode == .aiOpponent ? Theme.Colors.primaryBlue : Theme.Colors.metalGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isIPad ? 15 : 12)
                        .glowingBorder(color: gameMode == .aiOpponent ? Theme.Colors.primaryBlue : Theme.Colors.metalGray.opacity(0.3))
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                    
                    // Multiplayer button
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onGameModeChange(.playerVsPlayer)
                    }) {
                        HStack {
                            Image(systemName: "person.2")
                            Text("Multiplayer")
                        }
                        .font(Theme.TextStyle.subtitle(size: isIPad ? 24 : 20))
                        .foregroundColor(gameMode == .playerVsPlayer ? Theme.Colors.primaryOrange : Theme.Colors.metalGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isIPad ? 15 : 12)
                        .glowingBorder(color: gameMode == .playerVsPlayer ? Theme.Colors.primaryOrange : Theme.Colors.metalGray.opacity(0.3))
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                }
                .padding(.bottom, isIPad ? 15 : 10)
                
                // Symbol selection
                VStack(spacing: isIPad ? 10 : 8) {
                    HStack(spacing: isIPad ? 20 : 15) {
                        // X button
                        Button(action: { 
                            SoundManager.shared.playSound(.tap)
                            playerSettings.playerSymbol = "X" 
                        }) {
                            Text("X")
                                .font(Theme.TextStyle.title(size: isIPad ? 32 : 28))
                                .foregroundColor(playerSettings.isPlayerX ? Theme.Colors.primaryBlue : Theme.Colors.metalGray)
                                .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                                .background(
                                    Circle()
                                        .fill(Theme.Colors.darkGradient)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(playerSettings.isPlayerX ? Theme.Colors.primaryBlue : Theme.Colors.metalGray.opacity(0.3), lineWidth: 2)
                                        )
                                        .shadow(color: playerSettings.isPlayerX ? Theme.Colors.primaryBlue.opacity(0.5) : Color.clear, radius: 10)
                                )
                        }
                        
                        // O button
                        Button(action: { 
                            SoundManager.shared.playSound(.tap)
                            playerSettings.playerSymbol = "O" 
                        }) {
                            Text("O")
                                .font(Theme.TextStyle.title(size: isIPad ? 32 : 28))
                                .foregroundColor(playerSettings.isPlayerO ? Theme.Colors.primaryOrange : Theme.Colors.metalGray)
                                .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                                .background(
                                    Circle()
                                        .fill(Theme.Colors.darkGradient)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(playerSettings.isPlayerO ? Theme.Colors.primaryOrange : Theme.Colors.metalGray.opacity(0.3), lineWidth: 2)
                                        )
                                        .shadow(color: playerSettings.isPlayerO ? Theme.Colors.primaryOrange.opacity(0.5) : Color.clear, radius: 10)
                                )
                        }
                    }
                    
                    Text(playerSettings.isPlayerX ? "You play first (X)" : "AI plays first (X)")
                        .font(Theme.TextStyle.body(size: isIPad ? 18 : 16))
                        .foregroundColor(Theme.Colors.metalGray)
                        .padding(.top, 5)
                }
                .padding(.vertical, isIPad ? 15 : 10)
                
                // Time selection buttons
                VStack(spacing: isIPad ? 15 : 10) {
                    // 1 minute button
                    timeButton(
                        duration: "1 Minute",
                        color: Theme.Colors.primaryBlue,
                        action: {
                            SoundManager.shared.playSound(.tap)
                            timerSettings.gameDuration = .oneMinute
                        }
                    )
                    
                    // 3 minutes button
                    timeButton(
                        duration: "3 Minutes",
                        color: Theme.Colors.primaryGold,
                        action: {
                            SoundManager.shared.playSound(.tap)
                            timerSettings.gameDuration = .threeMinutes
                        }
                    )
                    
                    // 5 minutes button
                    timeButton(
                        duration: "5 Minutes",
                        color: Theme.Colors.primaryOrange,
                        action: {
                            SoundManager.shared.playSound(.tap)
                            timerSettings.gameDuration = .fiveMinutes
                        }
                    )
                    
                    // Start button
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        if gameMode == .playerVsPlayer {
                            onPlayVsPlayer()
                        } else {
                            onPlayVsAI()
                        }
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "play.fill")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                            Text("Start Game")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                        }
                        .foregroundColor(Theme.Colors.primaryBronze)
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .glowingBorder(color: Theme.Colors.primaryBronze)
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                    .padding(.top, isIPad ? 20 : 15)
                }
            }
            .padding(isIPad ? 40 : 30)
            .background(
                ZStack {
                    // Основна позадина
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Theme.Colors.darkGradient)
                    
                    // Акцентна светла
                    ZStack {
                        // Главни сноп светлости
                        Circle()
                            .fill(Theme.Colors.primaryGold)
                            .frame(width: 400)
                            .offset(y: -200)
                            .blur(radius: 100)
                            .opacity(0.3)
                        
                        // Плаво светло
                        Circle()
                            .fill(Theme.Colors.primaryBlue)
                            .frame(width: 300)
                            .offset(x: -150, y: 100)
                            .blur(radius: 100)
                            .opacity(0.2)
                        
                        // Наранџасто светло
                        Circle()
                            .fill(Theme.Colors.primaryOrange)
                            .frame(width: 300)
                            .offset(x: 150, y: 100)
                            .blur(radius: 100)
                            .opacity(0.2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    // Ивица
                RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.primaryGold.opacity(0.6),
                                    Theme.Colors.primaryGold.opacity(0.2),
                                    Theme.Colors.primaryGold.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: Theme.Colors.primaryGold.opacity(0.3), radius: 20)
            )
            .frame(maxWidth: isIPad ? 600 : 450)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private func timeButton(duration: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: isIPad ? 20 : 15) {
                Image(systemName: "timer")
                    .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                Text(duration)
                    .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
            }
            .foregroundColor(timerSettings.gameDuration == getDuration(from: duration) ? color : Theme.Colors.metalGray)
            .frame(maxWidth: isIPad ? 500 : 400)
            .padding(.vertical, isIPad ? 20 : 15)
            .glowingBorder(color: timerSettings.gameDuration == getDuration(from: duration) ? color : Theme.Colors.metalGray.opacity(0.3))
        }
        .buttonStyle(Theme.MetallicButtonStyle())
    }
    
    private func getDuration(from text: String) -> GameDuration {
        switch text {
        case "1 Minute":
            return .oneMinute
        case "3 Minutes":
            return .threeMinutes
        case "5 Minutes":
            return .fiveMinutes
        default:
            return .oneMinute
        }
    }
}

#Preview {
    GameModeModalView(
        gameMode: .aiOpponent,
        onPlayVsAI: {},
        onPlayVsPlayer: {},
        onClose: {},
        onGameModeChange: { _ in }
    )
} 
