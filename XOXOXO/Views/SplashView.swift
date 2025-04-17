import SwiftUI

// Уклоњена дупла дефиниција FloatingSymbol структуре која је сада у засебном фајлу

struct SplashView: View {
    @State private var isActive = false
    @State private var titleOffset = CGSize(width: -600, height: 0)
    @State private var titleRotation: Double = -30
    @State private var backgroundOpacity = 0.0
    @State private var showTapPrompt = false
    @State private var showTutorial = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Анимација прелаза
    @State private var startGameTransition = false
    
    // Режим игре и статус откључавања
    @State private var selectedGameMode: GameMode = .aiOpponent
    @State private var isPvPUnlocked: Bool = false
    @State private var showPurchaseView = false
    
    var body: some View {
        ZStack {
            if startGameTransition {
                GameView(gameMode: selectedGameMode, isPvPUnlocked: isPvPUnlocked)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale),
                        removal: .opacity
                    ))
            } else {
                GeometryReader { geometry in
                    let isLandscape = geometry.size.width > geometry.size.height
                    
                    ZStack {
                        // Modern gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.2, blue: 0.45), // Deep blue
                                Color(red: 0.2, green: 0.3, blue: 0.7),  // Medium blue
                                Color(red: 0.3, green: 0.4, blue: 0.9)   // Light blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        
                        // Floating symbols with specific starting positions
                        Group {
                            // Adjust symbol positions based on orientation
                            FloatingSymbol(symbol: "X", size: isLandscape ? 80 : 120, 
                                         startX: -geometry.size.width * (isLandscape ? 0.3 : 0.4), 
                                         startY: -geometry.size.height * (isLandscape ? 0.2 : 0.3))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 100 : 140, 
                                         startX: -geometry.size.width * (isLandscape ? 0.25 : 0.35), 
                                         startY: geometry.size.height * (isLandscape ? 0.2 : 0.3))
                            
                            FloatingSymbol(symbol: "X", size: isLandscape ? 70 : 100, 
                                         startX: geometry.size.width * (isLandscape ? 0.3 : 0.4), 
                                         startY: -geometry.size.height * (isLandscape ? 0.15 : 0.25))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 80 : 110, 
                                         startX: geometry.size.width * (isLandscape ? 0.25 : 0.35), 
                                         startY: geometry.size.height * (isLandscape ? 0.15 : 0.25))
                            
                            FloatingSymbol(symbol: "X", size: isLandscape ? 60 : 90, 
                                         startX: geometry.size.width * (isLandscape ? 0.1 : 0.15), 
                                         startY: -geometry.size.height * (isLandscape ? 0.05 : 0.1))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 90 : 130, 
                                         startX: -geometry.size.width * (isLandscape ? 0.1 : 0.15), 
                                         startY: geometry.size.height * (isLandscape ? 0.05 : 0.1))
                        }
                        .opacity(backgroundOpacity * 1.5)
                        
                        if isLandscape {
                            HStack(spacing: 20) {
                                Spacer()
                                
                                // Title and buttons on the left
                                VStack {
                                    Text("XO Tournament")
                                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                        .offset(titleOffset)
                                        .rotationEffect(.degrees(titleRotation))
                                        .padding(.bottom, 20)
                                    
                                    if showTapPrompt {
                                        gameModeSelector
                                            .padding(.bottom, 20)
                                            .transition(.opacity)
                                        
                                        startGameButton
                                            .scaleEffect(1.0)
                                            .transition(.scale.combined(with: .opacity))
                                        
                                        tutorialButton
                                            .padding(.top, 10)
                                            .transition(.opacity)
                                    }
                                }
                                .frame(width: geometry.size.width * 0.4)
                                
                                Spacer()
                            }
                        } else {
                            // Portrait layout remains unchanged
                            VStack {
                                Spacer()
                                
                                Text("XO Tournament")
                                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                    .offset(titleOffset)
                                    .rotationEffect(.degrees(titleRotation))
                                    .padding(.bottom, 50)
                                
                                if showTapPrompt {
                                    gameModeSelector
                                        .padding(.bottom, 30)
                                        .transition(.opacity)
                                    
                                    startGameButton
                                        .scaleEffect(1.0)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    Spacer()
                                    
                                    tutorialButton
                                        .padding(.bottom, 30)
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    .onAppear {
                        // Провера да ли је PvP мод откључан
                        self.isPvPUnlocked = UserDefaults.standard.bool(forKey: "isPvPUnlocked")
                        
                        // Background animation
                        withAnimation(.easeOut(duration: 0.8)) {
                            backgroundOpacity = 1.0
                        }
                        
                        // Title animation
                        withAnimation(
                            .spring(
                                response: 0.8,
                                dampingFraction: 0.6,
                                blendDuration: 0
                            )
                        ) {
                            titleOffset = .zero
                            titleRotation = 0
                        }
                        
                        // Show tap prompt after title animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showTapPrompt = true
                            }
                        }
                    }
                    .sheet(isPresented: $showTutorial) {
                        TutorialView(startGame: $startGameTransition)
                    }
                    .sheet(isPresented: $showPurchaseView) {
                        PurchaseView(isPvPUnlocked: $isPvPUnlocked)
                    }
                }
            }
        }
    }
    
    // Селектор режима игре
    private var gameModeSelector: some View {
        HStack(spacing: 15) {
            // AI mode button
            Button(action: {
                if selectedGameMode != .aiOpponent {
                    SoundManager.shared.playSound(.tap)
                    SoundManager.shared.playHaptic()
                    selectedGameMode = .aiOpponent
                }
            }) {
                aiButtonContent
            }
            
            // PvP mode button
            Button(action: {
                SoundManager.shared.playSound(.tap)
                SoundManager.shared.playHaptic()
                
                if isPvPUnlocked {
                    if selectedGameMode != .playerVsPlayer {
                        selectedGameMode = .playerVsPlayer
                    }
                } else {
                    showPurchaseView = true
                }
            }) {
                pvpButtonContent
            }
        }
        .padding(.vertical, 6)
    }
    
    private var aiButtonContent: some View {
        let isSelected = selectedGameMode == .aiOpponent
        let foregroundColor = isSelected ? Color.white : Color.white.opacity(0.8)
        let backgroundColor = isSelected ? Color.blue.opacity(0.7) : Color.white.opacity(0.15)
        let shadowColor = isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        
        return HStack {
            Image(systemName: "cpu")
                .font(.system(size: 16))
            Text("AI")
                .font(.system(size: 16, weight: .medium))
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 5)
        )
    }
    
    private var pvpButtonContent: some View {
        let isSelected = selectedGameMode == .playerVsPlayer
        let isUnlocked = isPvPUnlocked
        let foregroundColor = isSelected ? Color.white : Color.white.opacity(0.8)
        let backgroundColor = isSelected ? Color.purple.opacity(0.7) : Color.white.opacity(0.15)
        let shadowColor = isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        
        return HStack {
            Image(systemName: "person.2")
                .font(.system(size: 16))
            Text("PvP")
                .font(.system(size: 16, weight: .medium))
            
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            }
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 5)
        )
    }
    
    // MARK: - UI Components
    
    private var startGameButton: some View {
        Button(action: {
            SoundManager.shared.playSound(.tap)
            SoundManager.shared.playHaptic()
            
            withAnimation(.easeInOut(duration: 0.6)) {
                startGameTransition = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isActive = true
            }
        }) {
            Text("Start Game")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 50)
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
                        .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.5), radius: 10, x: 0, y: 5)
                )
        }
    }
    
    private var tutorialButton: some View {
        Button(action: {
            SoundManager.shared.playSound(.tap)
            SoundManager.shared.playLightHaptic()
            self.showTutorial = true
        }) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 18))
                Text("How to Play?")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    SplashView()
} 
