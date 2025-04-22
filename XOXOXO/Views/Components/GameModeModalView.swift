import SwiftUI

struct GameModeModalView: View {
    let isPvPUnlocked: Bool
    let onPlayVsAI: () -> Void
    let onPlayVsPlayer: () -> Void
    let onShowPurchase: () -> Void
    let onClose: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var playerSettings = PlayerSettings.shared
    @StateObject private var timerSettings = GameTimerSettings.shared
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack {
            // Замагљена позадина
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Модални прозор
            VStack(spacing: isIPad ? 20 : 15) {
                // Наслов
                Text("Choose Game Mode")
                    .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                    .foregroundColor(.white)
                
                // Избор првог играча
                VStack(spacing: isIPad ? 10 : 8) {
                    Text("Choose Your Symbol")
                        .font(.system(size: isIPad ? 24 : 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: isIPad ? 20 : 15) {
                        // X дугме
                        Button(action: { playerSettings.playerSymbol = "X" }) {
                            Text("X")
                                .font(.system(size: isIPad ? 32 : 28, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                                .background(
                                    Circle()
                                        .fill(playerSettings.isPlayerX ? Color.blue : Color.gray.opacity(0.3))
                                        .shadow(color: .black.opacity(0.3), radius: isIPad ? 8 : 5)
                                )
                        }
                        
                        // O дугме
                        Button(action: { playerSettings.playerSymbol = "O" }) {
                            Text("O")
                                .font(.system(size: isIPad ? 32 : 28, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                                .background(
                                    Circle()
                                        .fill(playerSettings.isPlayerO ? Color.red : Color.gray.opacity(0.3))
                                        .shadow(color: .black.opacity(0.3), radius: isIPad ? 8 : 5)
                                )
                        }
                    }
                    
                    Text(playerSettings.isPlayerX ? "You play first (X)" : "AI plays first (X)")
                        .font(.system(size: isIPad ? 18 : 16))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 5)
                }
                .padding(.vertical, isIPad ? 15 : 10)
                
                // Дугмад
                VStack(spacing: isIPad ? 15 : 10) {
                    // 1 минут дугме
                    Button(action: {
                        timerSettings.gameDuration = .oneMinute
                        onPlayVsAI()
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "timer")
                                .font(.system(size: isIPad ? 32 : 24))
                            Text("1 Minute")
                                .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.7))
                                .shadow(color: .black.opacity(0.3), radius: isIPad ? 8 : 5)
                        )
                    }
                    
                    // 3 минута дугме
                    Button(action: {
                        timerSettings.gameDuration = .threeMinutes
                        onPlayVsAI()
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "timer")
                                .font(.system(size: isIPad ? 32 : 24))
                            Text("3 Minutes")
                                .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.7))
                                .shadow(color: .black.opacity(0.3), radius: isIPad ? 8 : 5)
                        )
                    }
                    
                    // 5 минута дугме
                    Button(action: {
                        timerSettings.gameDuration = .fiveMinutes
                        if isPvPUnlocked {
                            onPlayVsPlayer()
                        } else {
                            onShowPurchase()
                        }
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "timer")
                                .font(.system(size: isIPad ? 32 : 24))
                            Text("5 Minutes")
                                .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                            
                            if !isPvPUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: isIPad ? 24 : 18))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .background(
                            Capsule()
                                .fill(isPvPUnlocked ? Color.purple.opacity(0.7) : Color.white.opacity(0.15))
                                .shadow(color: isPvPUnlocked ? Color.purple.opacity(0.3) : Color.black.opacity(0.1), radius: isIPad ? 8 : 5)
                        )
                    }
                }
                .padding(.top, isIPad ? 20 : 15)
            }
            .padding(isIPad ? 40 : 30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.1, green: 0.2, blue: 0.45))
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
            .frame(maxWidth: isIPad ? 600 : 450)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    GameModeModalView(
        isPvPUnlocked: false,
        onPlayVsAI: {},
        onPlayVsPlayer: {},
        onShowPurchase: {},
        onClose: {}
    )
} 