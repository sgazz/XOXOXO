import SwiftUI

struct AIDifficultyView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ObservedObject var gameLogic: GameLogic
    let onStart: () -> Void
    let onBack: () -> Void
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    init(gameLogic: GameLogic, onStart: @escaping () -> Void, onBack: @escaping () -> Void) {
        self.gameLogic = gameLogic
        self.onStart = onStart
        self.onBack = onBack
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Замућена позадина
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onBack()
                    }
                
                // Модални прозор
                VStack(spacing: geometry.size.height * 0.025) {
                    // Title
                    Text("Choose AI Difficulty")
                        .font(Theme.TextStyle.title(size: min(geometry.size.width * 0.08, 36)))
                        .foregroundColor(Theme.Colors.primaryGold)
                        .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
                    
                    // Description
                    Text("Select how challenging you want the AI to be")
                        .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.05, 20)))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, geometry.size.height * 0.02)
                    
                    // Difficulty buttons
                    VStack(spacing: geometry.size.height * 0.02) {
                        // Easy button
                        difficultyButton(
                            title: "Easy",
                            description: "Perfect for beginners",
                            icon: "shield",
                            color: Theme.Colors.primaryGreen,
                            isSelected: gameLogic.aiDifficulty == .easy,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                gameLogic.aiDifficulty = .easy
                            },
                            geometry: geometry
                        )
                        
                        // Medium button
                        difficultyButton(
                            title: "Medium",
                            description: "Balanced challenge",
                            icon: "sword",
                            color: Theme.Colors.primaryGold,
                            isSelected: gameLogic.aiDifficulty == .medium,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                gameLogic.aiDifficulty = .medium
                            },
                            geometry: geometry
                        )
                        
                        // Hard button
                        difficultyButton(
                            title: "Hard",
                            description: "For experienced players",
                            icon: "crown",
                            color: Theme.Colors.primaryOrange,
                            isSelected: gameLogic.aiDifficulty == .hard,
                            action: {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                gameLogic.aiDifficulty = .hard
                            },
                            geometry: geometry
                        )
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack(spacing: geometry.size.width * 0.04) {
                        // Back button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            onBack()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.06, 24)))
                            .foregroundColor(Theme.Colors.metalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, geometry.size.height * 0.02)
                            .glowingBorder(color: Theme.Colors.metalGray.opacity(0.3))
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                        
                        // Start button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            onStart()
                        }) {
                            Text("Start Game")
                                .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.06, 24)))
                                .foregroundColor(Theme.Colors.primaryBronze)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, geometry.size.height * 0.02)
                                .glowingBorder(color: Theme.Colors.primaryBronze)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
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
            .onAppear {
                SoundManager.shared.playSound(.modalOpen)
                SoundManager.shared.playHaptic(style: .medium)
            }
            .onDisappear {
                SoundManager.shared.playSound(.modalClose)
                SoundManager.shared.playHaptic(style: .light)
            }
        }
    }
    
    private func difficultyButton(
        title: String,
        description: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void,
        geometry: GeometryProxy
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text(title)
                        .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.06, 24)))
                        .foregroundColor(isSelected ? color : Theme.Colors.metalGray)
                    
                    Text(description)
                        .font(Theme.TextStyle.body(size: min(geometry.size.width * 0.04, 16)))
                        .foregroundColor(Theme.Colors.metalGray)
                }
                .frame(maxWidth: .infinity)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: min(geometry.size.width * 0.06, 24)))
                        .foregroundColor(color)
                }
            }
            .padding(.horizontal, geometry.size.width * 0.04)
            .padding(.vertical, geometry.size.height * 0.02)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Theme.Colors.darkGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(
                                isSelected ? color : Theme.Colors.metalGray.opacity(0.3),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 10)
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                switch title {
                case "Easy":
                    SoundManager.shared.playSound(.easySelected)
                    SoundManager.shared.playHaptic(style: .light)
                case "Medium":
                    SoundManager.shared.playSound(.mediumSelected)
                    SoundManager.shared.playHaptic(style: .medium)
                case "Hard":
                    SoundManager.shared.playSound(.hardSelected)
                    SoundManager.shared.playHaptic(style: .heavy)
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    AIDifficultyView(
        gameLogic: GameLogic(),
        onStart: {},
        onBack: {}
    )
} 