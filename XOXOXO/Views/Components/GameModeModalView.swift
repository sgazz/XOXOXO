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
        GeometryReader { geometry in
            ZStack {
                // Замућена позадина са металик градијентом
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onClose()
                    }
                
                // Модални прозор
                VStack(spacing: geometry.size.height * 0.025) {
                    // Title
                    Text("Choose Game Mode")
                        .font(Theme.TextStyle.title(size: min(geometry.size.width * 0.08, 36)))
                        .foregroundColor(Theme.Colors.primaryGold)
                        .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
                    
                    // Game mode buttons
                    HStack(spacing: geometry.size.width * 0.04) {
                        // Single Player button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            onGameModeChange(.aiOpponent)
                        }) {
                            HStack {
                                Image(systemName: "cpu")
                                Text("Single Player")
                            }
                            .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.06, isIPad ? 24 : 18)))
                            .foregroundColor(gameMode == .aiOpponent ? Theme.Colors.primaryBlue : Theme.Colors.metalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, geometry.size.height * 0.018)
                            .glowingBorder(color: gameMode == .aiOpponent ? Theme.Colors.primaryBlue : Theme.Colors.metalGray.opacity(0.3))
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                        
                        // Multiplayer button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            onGameModeChange(.playerVsPlayer)
                        }) {
                            HStack {
                                Image(systemName: "person.2")
                                Text("Multiplayer")
                            }
                            .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.06, isIPad ? 24 : 18)))
                            .foregroundColor(gameMode == .playerVsPlayer ? Theme.Colors.primaryOrange : Theme.Colors.metalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, geometry.size.height * 0.018)
                            .glowingBorder(color: gameMode == .playerVsPlayer ? Theme.Colors.primaryOrange : Theme.Colors.metalGray.opacity(0.3))
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                    }
                    .padding(.bottom, geometry.size.height * 0.015)
                    
                    // Symbol selection
                    VStack(spacing: geometry.size.height * 0.012) {
                        HStack(spacing: geometry.size.width * 0.04) {
                            // X button
                            Button(action: { 
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                playerSettings.playerSymbol = "X" 
                            }) {
                                Text("X")
                                    .font(Theme.TextStyle.title(size: min(geometry.size.width * 0.08, isIPad ? 48 : 32)))
                                    .foregroundColor(playerSettings.isPlayerX ? Theme.Colors.primaryBlue : Theme.Colors.metalGray)
                                    .frame(width: geometry.size.width * 0.16, height: geometry.size.width * 0.16)
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
                                SoundManager.shared.playHaptic()
                                playerSettings.playerSymbol = "O" 
                            }) {
                                Text("O")
                                    .font(Theme.TextStyle.title(size: min(geometry.size.width * 0.08, isIPad ? 48 : 32)))
                                    .foregroundColor(playerSettings.isPlayerO ? Theme.Colors.primaryOrange : Theme.Colors.metalGray)
                                    .frame(width: geometry.size.width * 0.16, height: geometry.size.width * 0.16)
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
                        
                        Text(gameMode == .aiOpponent ? 
                            (playerSettings.isPlayerX ? "You play first as X" : "AI plays first as X") :
                            "Choose X or O")
                            .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.05, 20)))
                            .foregroundColor(gameMode == .aiOpponent ? 
                                (playerSettings.isPlayerX ? Theme.Colors.primaryBlue : Theme.Colors.primaryOrange) :
                                Theme.Colors.primaryGold)
                            .padding(.top, geometry.size.height * 0.008)
                            .shadow(color: gameMode == .aiOpponent ? 
                                (playerSettings.isPlayerX ? Theme.Colors.primaryBlue.opacity(0.5) : Theme.Colors.primaryOrange.opacity(0.5)) :
                                Theme.Colors.primaryGold.opacity(0.5), radius: 5)
                    }
                    .padding(.vertical, geometry.size.height * 0.018)
                    
                    // Time selection buttons
                    VStack(spacing: geometry.size.height * 0.018) {
                        // 1 minute button
                        timeButton(
                            duration: "1 Minute",
                            color: Theme.Colors.primaryGold,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                timerSettings.gameDuration = .oneMinute
                            },
                            geometry: geometry
                        )
                        
                        // 3 minutes button
                        timeButton(
                            duration: "3 Minutes",
                            color: Theme.Colors.primaryGold,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                timerSettings.gameDuration = .threeMinutes
                            },
                            geometry: geometry
                        )
                        
                        // 5 minutes button
                        timeButton(
                            duration: "5 Minutes",
                            color: Theme.Colors.primaryGold,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                timerSettings.gameDuration = .fiveMinutes
                            },
                            geometry: geometry
                        )
                        
                        // Start button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            if gameMode == .playerVsPlayer {
                                onPlayVsPlayer()
                            } else {
                                onPlayVsAI()
                            }
                        }) {
                            HStack(spacing: geometry.size.width * 0.04) {
                                Image(systemName: "play.fill")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.07, 28)))
                                Text("Start Game")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.07, 28)))
                            }
                            .foregroundColor(Theme.Colors.primaryBronze)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .padding(.vertical, geometry.size.height * 0.025)
                            .glowingBorder(color: Theme.Colors.primaryBronze)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                        .padding(.top, geometry.size.height * 0.025)
                    }
                }
                .padding(geometry.size.width * 0.07)
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
                                .frame(width: geometry.size.width * 0.7)
                                .offset(y: -geometry.size.height * 0.25)
                                .blur(radius: 100)
                                .opacity(0.3)
                            
                            // Плаво светло
                            Circle()
                                .fill(Theme.Colors.primaryBlue)
                                .frame(width: geometry.size.width * 0.5)
                                .offset(x: -geometry.size.width * 0.25, y: geometry.size.height * 0.13)
                                .blur(radius: 100)
                                .opacity(0.2)
                            
                            // Наранџасто светло
                            Circle()
                                .fill(Theme.Colors.primaryOrange)
                                .frame(width: geometry.size.width * 0.5)
                                .offset(x: geometry.size.width * 0.25, y: geometry.size.height * 0.13)
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
                .frame(maxWidth: min(geometry.size.width * 0.95, 600))
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
    
    private func timeButton(duration: String, color: Color, action: @escaping () -> Void, geometry: GeometryProxy) -> some View {
        Button(action: action) {
            HStack(spacing: geometry.size.width * 0.04) {
                Image(systemName: "timer")
                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.07, 28)))
                Text(duration)
                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.07, 28)))
            }
            .foregroundColor(timerSettings.gameDuration == getDuration(from: duration) ? color : Theme.Colors.metalGray)
            .frame(maxWidth: geometry.size.width * 0.8)
            .padding(.vertical, geometry.size.height * 0.025)
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
