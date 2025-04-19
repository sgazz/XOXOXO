import SwiftUI

// Уклоњена дупла дефиниција FloatingSymbol структуре која је сада у засебном фајлу

struct SplashView: View {
    @State private var isActive = false
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
                    let isIPad = horizontalSizeClass == .regular
                    
                    // Прилагођене величине за iPad
                    let titleSize = isIPad ? 
                        min(geometry.size.width * (isLandscape ? 0.1 : 0.15), 96) : 
                        min(geometry.size.width * (isLandscape ? 0.08 : 0.12), 56)
                    
                    let subtitleSize = isIPad ? 
                        min(geometry.size.width * (isLandscape ? 0.04 : 0.06), 36) : 
                        min(geometry.size.width * (isLandscape ? 0.03 : 0.045), 24)
                    
                    let descriptionSize = isIPad ? 
                        min(geometry.size.width * (isLandscape ? 0.03 : 0.045), 28) : 
                        min(geometry.size.width * (isLandscape ? 0.022 : 0.035), 18)
                    
                    let buttonWidth = isIPad ? 
                        min(geometry.size.width * (isLandscape ? 0.35 : 0.6), 500) : 
                        min(geometry.size.width * (isLandscape ? 0.3 : 0.8), 400)
                    
                    let containerWidth = isIPad ? 
                        (isLandscape ? geometry.size.width * 0.7 : geometry.size.width * 0.8) : 
                        (isLandscape ? geometry.size.width * 0.5 : geometry.size.width)
                    
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
                        
                        // Floating elements
                        Group {
                            // Floating boards
                            FloatingBoard(
                                size: isLandscape ? 120 : 160,
                                startX: -geometry.size.width * (isLandscape ? 0.35 : 0.45),
                                startY: -geometry.size.height * (isLandscape ? 0.25 : 0.35)
                            )
                            
                            FloatingBoard(
                                size: isLandscape ? 100 : 140,
                                startX: geometry.size.width * (isLandscape ? 0.35 : 0.45),
                                startY: geometry.size.height * (isLandscape ? 0.25 : 0.35)
                            )
                            
                            FloatingBoard(
                                size: isLandscape ? 90 : 120,
                                startX: -geometry.size.width * (isLandscape ? 0.15 : 0.25),
                                startY: geometry.size.height * (isLandscape ? 0.35 : 0.45)
                            )
                            
                            // Floating symbols - Left side
                            FloatingSymbol(symbol: "X", size: isLandscape ? 80 : 120, 
                                         startX: -geometry.size.width * (isLandscape ? 0.3 : 0.4), 
                                         startY: -geometry.size.height * (isLandscape ? 0.2 : 0.3))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 100 : 140, 
                                         startX: -geometry.size.width * (isLandscape ? 0.25 : 0.35), 
                                         startY: geometry.size.height * (isLandscape ? 0.2 : 0.3))
                            
                            // Floating symbols - Right side
                            FloatingSymbol(symbol: "X", size: isLandscape ? 70 : 100, 
                                         startX: geometry.size.width * (isLandscape ? 0.3 : 0.4), 
                                         startY: -geometry.size.height * (isLandscape ? 0.15 : 0.25))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 80 : 110, 
                                         startX: geometry.size.width * (isLandscape ? 0.25 : 0.35), 
                                         startY: geometry.size.height * (isLandscape ? 0.15 : 0.25))
                            
                            // Additional floating symbols
                            FloatingSymbol(symbol: "X", size: isLandscape ? 60 : 90, 
                                         startX: geometry.size.width * (isLandscape ? 0.1 : 0.15), 
                                         startY: -geometry.size.height * (isLandscape ? 0.05 : 0.1))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 90 : 130, 
                                         startX: -geometry.size.width * (isLandscape ? 0.1 : 0.15), 
                                         startY: geometry.size.height * (isLandscape ? 0.05 : 0.1))
                            
                            // New floating symbols
                            FloatingSymbol(symbol: "X", size: isLandscape ? 65 : 95,
                                         startX: geometry.size.width * (isLandscape ? 0.4 : 0.5),
                                         startY: geometry.size.height * (isLandscape ? 0.3 : 0.4))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 75 : 105,
                                         startX: -geometry.size.width * (isLandscape ? 0.4 : 0.5),
                                         startY: -geometry.size.height * (isLandscape ? 0.3 : 0.4))
                            
                            FloatingSymbol(symbol: "X", size: isLandscape ? 55 : 85,
                                         startX: -geometry.size.width * (isLandscape ? 0.2 : 0.3),
                                         startY: -geometry.size.height * (isLandscape ? 0.4 : 0.5))
                            FloatingSymbol(symbol: "O", size: isLandscape ? 85 : 115,
                                         startX: geometry.size.width * (isLandscape ? 0.2 : 0.3),
                                         startY: geometry.size.height * (isLandscape ? 0.4 : 0.5))
                        }
                        .opacity(backgroundOpacity * 1.5)
                        
                        if isLandscape {
                            HStack(spacing: isIPad ? 40 : 20) {
                                Spacer()
                                
                                VStack(spacing: isIPad ? 20 : 10) {
                                    Text("XO Tournament")
                                        .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                        .padding(.top, geometry.size.height * (isIPad ? 0.05 : 0.03))
                                    
                                    Text("8 Boards. 5 Minutes. 1 Champion.")
                                        .font(.system(size: subtitleSize, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        .padding(.top, isIPad ? 6 : 3)
                                    
                                    Text("Multi-board Tic Tac Toe with\nlightning-fast rounds and tactical gameplay.")
                                        .font(.system(size: descriptionSize, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                        .padding(.top, isIPad ? 3 : 2)
                                        .padding(.bottom, geometry.size.height * (isIPad ? 0.04 : 0.02))
                                    
                                    if showTapPrompt {
                                        VStack(spacing: isIPad ? 15 : 10) {
                                            Button(action: {
                                                if selectedGameMode != .aiOpponent {
                                                    SoundManager.shared.playSound(.tap)
                                                    SoundManager.shared.playHaptic()
                                                    selectedGameMode = .aiOpponent
                                                }
                                            }) {
                                                aiButtonContent(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                                    .frame(height: isIPad ? 100 : 80)
                                            }
                                            
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
                                                pvpButtonContent(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                                    .frame(height: isIPad ? 100 : 80)
                                            }
                                        }
                                        .padding(.bottom, isIPad ? 15 : 8)
                                        .transition(.opacity)
                                        
                                        startGameButton(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                            .frame(height: isIPad ? 100 : 80)
                                            .scaleEffect(1.0)
                                            .transition(.scale.combined(with: .opacity))
                                        
                                        tutorialButton(geometry: geometry, isIPad: isIPad)
                                            .padding(.top, isIPad ? 8 : 4)
                                            .transition(.opacity)
                                    }
                                }
                                .frame(width: containerWidth)
                                
                                Spacer()
                            }
                        } else {
                            // Portrait layout
                            VStack {
                                Spacer()
                                
                                Text("XO Tournament")
                                    .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                    .padding(.top, geometry.size.height * (isIPad ? 0.05 : 0.03))
                                
                                Text("8 Boards. 5 Minutes. 1 Champion.")
                                    .font(.system(size: subtitleSize, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    .padding(.top, isIPad ? 6 : 3)
                                
                                Text("Multi-board Tic Tac Toe with\nlightning-fast rounds and tactical gameplay.")
                                    .font(.system(size: descriptionSize, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                    .padding(.top, isIPad ? 3 : 2)
                                    .padding(.bottom, geometry.size.height * (isIPad ? 0.04 : 0.02))
                                
                                if showTapPrompt {
                                    VStack(spacing: isIPad ? 15 : 10) {
                                        Button(action: {
                                            if selectedGameMode != .aiOpponent {
                                                SoundManager.shared.playSound(.tap)
                                                SoundManager.shared.playHaptic()
                                                selectedGameMode = .aiOpponent
                                            }
                                        }) {
                                            aiButtonContent(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                                .frame(height: isIPad ? 100 : 80)
                                        }
                                        
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
                                            pvpButtonContent(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                                .frame(height: isIPad ? 100 : 80)
                                        }
                                    }
                                    .padding(.bottom, isIPad ? 15 : 8)
                                    .transition(.opacity)
                                    
                                    startGameButton(geometry: geometry, isIPad: isIPad, buttonWidth: buttonWidth)
                                        .frame(height: isIPad ? 100 : 80)
                                        .scaleEffect(1.0)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    Spacer()
                                    
                                    tutorialButton(geometry: geometry, isIPad: isIPad)
                                        .padding(.bottom, isIPad ? 40 : 30)
                                        .transition(.opacity)
                                }
                            }
                            .frame(width: containerWidth)
                        }
                    }
                    .onAppear {
                        // Провера да ли је PvP мод откључан
                        self.isPvPUnlocked = UserDefaults.standard.bool(forKey: "isPvPUnlocked")
                        
                        // Background animation
                        withAnimation(.easeOut(duration: 0.8)) {
                            backgroundOpacity = 1.0
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
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            Group {
                if isLandscape {
                    // Landscape layout
                    VStack(spacing: 15) {
                        // Single Player mode button
                        Button(action: {
                            if selectedGameMode != .aiOpponent {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                selectedGameMode = .aiOpponent
                            }
                        }) {
                            aiButtonContent(geometry: geometry, isIPad: false, buttonWidth: 200)
                                .frame(width: 200) // Иста ширина као Start Game дугме
                        }
                        
                        // Multiplayer mode button
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
                            pvpButtonContent(geometry: geometry, isIPad: false, buttonWidth: 200)
                                .frame(width: 200) // Иста ширина као Start Game дугме
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 6)
                } else {
                    // Portrait layout remains unchanged
                    HStack(spacing: 15) {
                        // Single Player mode button
                        Button(action: {
                            if selectedGameMode != .aiOpponent {
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playHaptic()
                                selectedGameMode = .aiOpponent
                            }
                        }) {
                            aiButtonContent(geometry: geometry, isIPad: false, buttonWidth: 400)
                        }
                        
                        // Multiplayer mode button
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
                            pvpButtonContent(geometry: geometry, isIPad: false, buttonWidth: 400)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
            }
        }
    }
    
    private func aiButtonContent(geometry: GeometryProxy, isIPad: Bool, buttonWidth: CGFloat) -> some View {
        let fontSize = isIPad ? 
            min(geometry.size.width * 0.04, 36) : 
            min(geometry.size.width * 0.06, 36)
        
        let isSelected = selectedGameMode == .aiOpponent
        let foregroundColor = isSelected ? Color.white : Color.white.opacity(0.8)
        let backgroundColor = isSelected ? Color.blue.opacity(0.7) : Color.white.opacity(0.15)
        let shadowColor = isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        
        return HStack(spacing: isIPad ? 20 : 15) {
            Image(systemName: "cpu")
                .font(.system(size: fontSize))
                .layoutPriority(1)
            Text("Single Player")
                .font(.system(size: fontSize, weight: .bold))
                .layoutPriority(2)
                .minimumScaleFactor(0.5)
        }
        .foregroundColor(foregroundColor)
        .frame(width: buttonWidth)
        .padding(.horizontal, geometry.size.width * (isIPad ? 0.04 : 0.06))
        .padding(.vertical, geometry.size.height * (isIPad ? 0.02 : 0.03))
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: isIPad ? 8 : 5)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func pvpButtonContent(geometry: GeometryProxy, isIPad: Bool, buttonWidth: CGFloat) -> some View {
        let fontSize = isIPad ? 
            min(geometry.size.width * 0.04, 36) : 
            min(geometry.size.width * 0.06, 36)
        
        let isSelected = selectedGameMode == .playerVsPlayer
        let isUnlocked = isPvPUnlocked
        let foregroundColor = isSelected ? Color.white : Color.white.opacity(0.8)
        let backgroundColor = isSelected ? Color.purple.opacity(0.7) : Color.white.opacity(0.15)
        let shadowColor = isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        
        return HStack(spacing: isIPad ? 20 : 15) {
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
        .foregroundColor(foregroundColor)
        .frame(width: buttonWidth)
        .padding(.horizontal, geometry.size.width * (isIPad ? 0.04 : 0.06))
        .padding(.vertical, geometry.size.height * (isIPad ? 0.02 : 0.03))
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: isIPad ? 8 : 5)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - UI Components
    
    private func startGameButton(geometry: GeometryProxy, isIPad: Bool, buttonWidth: CGFloat) -> some View {
        let fontSize = isIPad ? 
            min(geometry.size.width * 0.04, 42) : 
            min(geometry.size.width * 0.06, 36)
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                startGameTransition = true
            }
        }) {
            Text("Start Game")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: buttonWidth)
                .padding(.horizontal, geometry.size.width * (isIPad ? 0.04 : 0.06))
                .padding(.vertical, geometry.size.height * (isIPad ? 0.02 : 0.03))
                .background(
                    ZStack {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.9),
                                        .white.opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isIPad ? 3 : 2
                            )
                    }
                )
                .shadow(color: .white.opacity(0.3), radius: isIPad ? 15 : 10, x: 0, y: 0)
        }
    }
    
    private func tutorialButton(geometry: GeometryProxy, isIPad: Bool) -> some View {
        let buttonSize = isIPad ? 
            min(geometry.size.width * 0.05, 48) : 
            min(geometry.size.width * 0.07, 32)
        
        return Button(action: {
            showTutorial = true
        }) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: buttonSize))
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.4), radius: isIPad ? 10 : 6, x: 0, y: 0)
        }
    }
}

#Preview {
    SplashView()
} 
