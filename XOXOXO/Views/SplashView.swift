import SwiftUI


struct SplashView: View {
    @State private var isActive = false
    @State private var backgroundOpacity = 0.0
    @State private var showTapPrompt = false
    @State private var showTutorial = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // Анимација прелаза
    @State private var startGameTransition = false
    
    // Режим игре и статус откључавања
    @State private var showGameModeModal = false
    @State private var selectedGameMode: GameMode = .aiOpponent
    @State private var showGameView = false
    @State private var showResults = false
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    var body: some View {
        ZStack {
            if startGameTransition {
                GameView(gameMode: selectedGameMode)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale),
                        removal: .opacity
                    ))
            } else {
                GeometryReader { geometry in
                    let isIPad = horizontalSizeClass == .regular
                    let deviceLayout = DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
                    
                    // Прилагођене величине за iPad и iPhone
                    let titleSize = min(geometry.size.width * deviceLayout.titleScale, deviceLayout.titleSize)
                    let subtitleSize = min(geometry.size.width * deviceLayout.subtitleScale, deviceLayout.subtitleSize)
                    let descriptionSize = min(geometry.size.width * deviceLayout.descriptionScale, deviceLayout.descriptionSize)
                    
                    let buttonWidth = isIPad ? 
                        min(geometry.size.width * 0.6, 500) : 
                        min(geometry.size.width * 0.8, 400)
                    
                    let containerWidth = isIPad ? 
                        geometry.size.width * 0.8 : 
                        geometry.size.width
                    
                    ZStack {
                        // Modern metallic background
                        Theme.Colors.darkGradient
                            .opacity(backgroundOpacity)
                            .overlay(
                                ZStack {
                                    // Accent lights
                                    Circle()
                                        .fill(Theme.Colors.primaryBlue)
                                        .frame(width: geometry.size.width * 0.8)
                                        .offset(x: -geometry.size.width * 0.5, y: -geometry.size.height * 0.3)
                                        .blur(radius: 100)
                                        .opacity(0.3)
                                    
                                    Circle()
                                        .fill(Theme.Colors.primaryOrange)
                                        .frame(width: geometry.size.width * 0.8)
                                        .offset(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                                        .blur(radius: 100)
                                        .opacity(0.3)
                                }
                            )
                        .ignoresSafeArea()
                        
                        // Main content
                        VStack {
                            Spacer()
                            
                            Text("XO Arena")
                                .font(Theme.TextStyle.title(size: titleSize))
                                .foregroundColor(Theme.Colors.primaryGold)
                                .shadow(color: Theme.Colors.primaryGold.opacity(0.5), radius: 10)
                                .padding(.top, geometry.size.height * (isIPad ? 0.05 : 0.03))
                            
                            Text("8 Boards. 1 Minute. 1 Champion.")
                                .font(Theme.TextStyle.subtitle(size: subtitleSize))
                                .foregroundColor(.white)
                                .shadow(color: Theme.Colors.primaryBlue.opacity(0.8), radius: 8)
                                .padding(.top, isIPad ? 6 : 3)
                            
                            Text("Multi-board Tic Tac Toe\nLightning-fast rounds\nTactical gameplay")
                                .font(Theme.TextStyle.body(size: descriptionSize))
                                .foregroundColor(Theme.Colors.metalGray)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                                .shadow(color: .black.opacity(0.3), radius: 3)
                                .padding(.top, isIPad ? 3 : 2)
                                .padding(.bottom, geometry.size.height * (isIPad ? 0.04 : 0.02))
                            
                            if showTapPrompt {
                                VStack(spacing: isIPad ? 15 : 10) {
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.3)
                                        
                                    Button(action: {
                                        SoundManager.shared.playSound(.tap)
                                        SoundManager.shared.playHaptic()
                                        showGameModeModal = true
                                    }) {
                                        HStack {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: isIPad ? 30 : 24))
                                            Text("Start Game")
                                                .font(Theme.TextStyle.subtitle(size: isIPad ? 30 : 24))
                                        }
                                        .foregroundColor(Theme.Colors.primaryGold)
                                        .frame(width: buttonWidth)
                                            .frame(height: CGFloat(isIPad ? 100 : 80))
                                        .glowingBorder(color: Theme.Colors.primaryGold)
                                    }
                                    .buttonStyle(Theme.MetallicButtonStyle())
                                }
                                .padding(.bottom, isIPad ? 15 : 8)
                                .transition(.opacity)
                                
                                Spacer()
                                    .frame(maxHeight: geometry.size.height * 0.1)
                                
                                Button(action: {
                                    SoundManager.shared.playSound(.tap)
                                    showTutorial = true
                                }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle")
                                            .font(.system(size: isIPad ? 24 : 20))
                                        Text("How to Play")
                                            .font(Theme.TextStyle.body(size: isIPad ? 24 : 20))
                                    }
                                    .foregroundColor(Theme.Colors.metalGray)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .glowingBorder(color: Theme.Colors.metalGray.opacity(0.5))
                                }
                                .buttonStyle(Theme.MetallicButtonStyle())
                                    .padding(.bottom, isIPad ? 40 : 30)
                                    .transition(.opacity)
                            }
                        }
                        .frame(width: containerWidth)
                    }
                    .onAppear {
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
                    
                    if showGameModeModal {
                        GameModeModalView(
                            gameMode: selectedGameMode,
                            onPlayVsAI: {
                                showGameModeModal = false
                                selectedGameMode = .aiOpponent
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    startGameTransition = true
                                }
                            },
                            onPlayVsPlayer: {
                                showGameModeModal = false
                                selectedGameMode = .playerVsPlayer
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    startGameTransition = true
                                }
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
            }
            
            if showGameView {
                GameView(gameMode: selectedGameMode)
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
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            selectedGameMode = .aiOpponent
                            withAnimation(.easeInOut(duration: 0.5)) {
                                startGameTransition = true
                            }
                        }) {
                            aiButtonContent(geometry: geometry, isIPad: false, buttonWidth: 200)
                                .frame(width: 200) // Иста ширина као Start Game дугме
                        }
                        
                        // Multiplayer mode button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            
                                selectedGameMode = .playerVsPlayer
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    startGameTransition = true
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
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            selectedGameMode = .aiOpponent
                            withAnimation(.easeInOut(duration: 0.5)) {
                                startGameTransition = true
                            }
                        }) {
                            aiButtonContent(geometry: geometry, isIPad: false, buttonWidth: 400)
                        }
                        
                        // Multiplayer mode button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            SoundManager.shared.playHaptic()
                            
                                selectedGameMode = .playerVsPlayer
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    startGameTransition = true
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
            min(geometry.size.width * 0.036, 32) : 
            min(geometry.size.width * 0.054, 22)
        
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
            min(geometry.size.width * 0.036, 32) : 
            min(geometry.size.width * 0.054, 22)
        
        let isSelected = selectedGameMode == .playerVsPlayer
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
    
    private func tutorialButton(geometry: GeometryProxy, isIPad: Bool) -> some View {
        Button(action: {
            SoundManager.shared.playSound(.tap)
            showTutorial = true
        }) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: isIPad ? 56 : 36))
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.4), radius: isIPad ? 12 : 8, x: 0, y: 0)
        }
    }
    
    private func startButtonContent(geometry: GeometryProxy, isIPad: Bool, buttonWidth: CGFloat) -> some View {
        let fontSize = isIPad ? 
            min(geometry.size.width * 0.036, 32) : 
            min(geometry.size.width * 0.054, 22)
        
        return HStack(spacing: isIPad ? 20 : 15) {
            Image(systemName: "play.fill")
                .font(.system(size: fontSize))
                .layoutPriority(1)
            Text("Start")
                .font(.system(size: fontSize, weight: .bold))
                .layoutPriority(2)
                .minimumScaleFactor(0.5)
        }
        .foregroundColor(.white)
        .frame(width: buttonWidth)
        .padding(.horizontal, geometry.size.width * (isIPad ? 0.04 : 0.06))
        .padding(.vertical, geometry.size.height * (isIPad ? 0.02 : 0.03))
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.7))
                .shadow(color: Color.black.opacity(0.3), radius: isIPad ? 8 : 5)
        )
    }
}

#Preview {
    SplashView()
} 
