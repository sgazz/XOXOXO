import SwiftUI
struct GameView: View {
    @StateObject private var gameLogic: GameLogic
    @State private var showPurchaseView = false
    @State private var isPvPUnlocked: Bool = false
    @State private var playerXTime: TimeInterval = 300 // 5 minutes in seconds
    @State private var playerOTime: TimeInterval = 300 // 5 minutes in seconds
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var showGameOver = false
    @State private var timeoutPlayer: String? = nil
    
    private let defaultTime: TimeInterval = 300 // 5 minutes in seconds
    
    // Dynamic layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme

    // Initializer that accepts a game mode
    init(gameMode: GameMode = .aiOpponent, isPvPUnlocked: Bool = false) {
        _gameLogic = StateObject(wrappedValue: GameLogic(gameMode: gameMode))
        self.isPvPUnlocked = isPvPUnlocked
    }

    // Helper computed properties to simplify expressions
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    // Enhanced dynamic layout properties
    private var deviceLayout: DeviceLayout {
        switch (horizontalSizeClass, verticalSizeClass) {
            case (.compact, .regular): return .iphone
            case (.compact, .compact): return .iphoneLandscape
            case (.regular, .regular): return .ipad
            case (.regular, .compact): return .ipadLandscape
            default: return .iphone
        }
    }
    
    private var gridSpacing: CGFloat {
        switch deviceLayout {
            case .iphone: return 12
            case .iphoneLandscape: return 10
            case .ipad: return 30
            case .ipadLandscape: return 35
        }
    }
    
    private var scoreFont: Font {
        switch deviceLayout {
            case .iphone: return .system(size: 32, weight: .bold)
            case .iphoneLandscape: return .system(size: 24, weight: .bold)
            case .ipad: return .system(size: 48, weight: .bold)
            case .ipadLandscape: return .system(size: 42, weight: .bold)
        }
    }
    
    private var gridLayout: [GridItem] {
        switch deviceLayout {
            case .iphone:
                return [
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing)
                ]
            case .iphoneLandscape:
                return [
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing)
                ]
            case .ipad, .ipadLandscape:
                return [
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing),
                    GridItem(.flexible(), spacing: gridSpacing)
                ]
        }
    }
    
    // Helper computed properties for background colors
    private var scoreBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.3)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with floating symbols that extends to edges
                backgroundGradient
                    .ignoresSafeArea()
                
                // Floating symbols
                floatingSymbols(in: geometry)
                    .ignoresSafeArea()
                
                // Game content
                if deviceLayout.isLandscape {
                    // Landscape layout - користимо цео екран
                    HStack(spacing: 0) {
                        // Score display with timers for landscape
                        scoreView
                            .frame(width: geometry.size.width * 0.12)
                        
                        // Game boards grid
                        gameBoardsGrid(geometry: geometry)
                    }
                    .ignoresSafeArea(.container, edges: [.leading, .trailing, .bottom])
                } else {
                    // Portrait layout - задржавамо постојећи
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            scoreView
                            gameBoardsGrid(geometry: geometry)
                                .padding(.bottom, deviceLayout.isIphone ? geometry.safeAreaInsets.bottom + 20 : 0)
                        }
                        .frame(
                            minHeight: geometry.size.height - (deviceLayout.isIphone ? 120 : 0)
                        )
                    }
                }
                
                // Game Over overlay
                if showGameOver {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .blur(radius: 3)
                    
                    VStack(spacing: 30) {
                        Text("Game Over")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let player = timeoutPlayer {
                            Text("\(player == "X" ? "Blue" : "Red") player ran out of time!")
                                .font(.title2)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: resetGame) {
                            Text("Play Again")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showPurchaseView) {
                PurchaseView(isPvPUnlocked: $isPvPUnlocked)
            }
        }
        .onAppear {
            resetTimers()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: isPvPUnlocked) { oldValue, newValue in
            if newValue && !oldValue {
                gameLogic.changeGameMode(to: .playerVsPlayer)
                SoundManager.shared.playSound(.win)
            }
        }
    }
    
    // MARK: - UI Components
    
    private var scoreView: some View {
        Group {
            if deviceLayout.isLandscape {
                // Landscape score view
                VStack(spacing: 10) {
                    Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "X" ? .blue : .white.opacity(0.7))
                        .font(.system(size: 20, weight: .bold))
                        .minimumScaleFactor(0.5)
                    
                    Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .heavy))
                        .minimumScaleFactor(0.5)
                    
                    Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "O" ? .red : .white.opacity(0.7))
                        .font(.system(size: 20, weight: .bold))
                        .minimumScaleFactor(0.5)
                }
            } else {
                // Portrait score view
                HStack(spacing: deviceLayout.scoreSpacing) {
                    Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "X" ? .blue : .white.opacity(0.7))
                        .font(scoreFont)
                        .minimumScaleFactor(0.5)
                    
                    Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                        .foregroundColor(.white)
                        .font(scoreFont.weight(.heavy))
                        .minimumScaleFactor(0.5)
                    
                    Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "O" ? .red : .white.opacity(0.7))
                        .font(scoreFont)
                        .minimumScaleFactor(0.5)
                }
                .padding(.vertical, deviceLayout.isIphone ? 5 : 10)
            }
        }
    }
    
    private func gameBoardsGrid(geometry: GeometryProxy) -> some View {
        let isLandscape = deviceLayout.isLandscape
        let availableWidth = isLandscape ? geometry.size.width * 0.88 : geometry.size.width // 88% за табле у landscape
        let spacing: CGFloat = isLandscape ? 8 : gridSpacing
        
        let gridItems = isLandscape ? [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ] : gridLayout
        
        return LazyVGrid(
            columns: gridItems,
            spacing: spacing
        ) {
            ForEach(0..<8) { index in
                boardView(for: index, geometry: geometry)
            }
        }
        .frame(maxWidth: availableWidth)
    }
    
    private func boardView(for index: Int, geometry: GeometryProxy) -> some View {
        let maxWidth = calculateBoardWidth(for: geometry)
        return BoardView(
            board: .init(
                get: { gameLogic.boards[index] },
                set: { gameLogic.boards[index] = $0 }
            ),
            isActive: gameLogic.currentBoard == index && !gameLogic.gameOver,
            onTap: { position in
                handleBoardTap(boardIndex: index, position: position)
            }
        )
        .frame(maxWidth: maxWidth, maxHeight: maxWidth)
    }
    
    private func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        if deviceLayout.isLandscape {
            let availableWidth = geometry.size.width * 0.88 // 88% екрана за табле
            let horizontalSpacing: CGFloat = 8 * 3 // 3 размака између 4 колоне
            let boardWidth = (availableWidth - horizontalSpacing) / 4 // 4 табле у реду
            return min(boardWidth, geometry.size.height * 0.45) // Ограничавамо висином
        } else {
            return deviceLayout.maxBoardWidth(for: geometry.size)
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if gameLogic.currentPlayer == "X" {
                if playerXTime > 0 {
                    playerXTime -= 1
                    if playerXTime == 0 {
                        handleTimeout(player: "X")
                    }
                }
            } else {
                if playerOTime > 0 {
                    playerOTime -= 1
                    if playerOTime == 0 {
                        handleTimeout(player: "O")
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func resetTimers() {
        playerXTime = defaultTime
        playerOTime = defaultTime
        stopTimer()
    }

    private func handleBoardTap(boardIndex: Int, position: Int) {
        // Check if valid move
        if gameLogic.boards[boardIndex][position].isEmpty &&
           !gameLogic.isThinking &&
           gameLogic.currentBoard == boardIndex &&
           (!gameLogic.gameOver) {

            // Stop timer for current player
            stopTimer()

            // Sound and haptics for player move
            SoundManager.shared.playSound(.move)
            SoundManager.shared.playHaptic()

            gameLogic.makeMove(at: position, in: boardIndex)

            // Start timer for next player
            startTimer()

            // For AI mode, make AI move with random thinking time
            if gameLogic.gameMode == .aiOpponent && !gameLogic.gameOver {
                let thinkingTime = Double.random(in: 0.5...1.5)
                gameLogic.makeAIMove(in: boardIndex, thinkingTime: thinkingTime) {
                    // Sound for AI move
                    SoundManager.shared.playSound(.move)
                    // Stop timer after AI move
                    stopTimer()
                    // Start timer for player
                    startTimer()
                }
            }
        }
    }
    
    private func handleTimeout(player: String) {
        stopTimer()
        timeoutPlayer = player
        // Сачекај 3 секунде пре приказа Game Over екрана
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showGameOver = true
        }
    }
    
    private func resetGame() {
        showGameOver = false
        timeoutPlayer = nil
        resetTimers()
        gameLogic.resetGame()
        startTimer()
    }
    
    // Background gradient
    private var backgroundGradient: some View {
        // Користимо исте боје као у SplashView
        let colors: [Color] = [
            Color(red: 0.1, green: 0.2, blue: 0.45), // Deep blue
            Color(red: 0.2, green: 0.3, blue: 0.7),  // Medium blue
            Color(red: 0.3, green: 0.4, blue: 0.9)   // Light blue
        ]
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Floating symbols for background
    private func floatingSymbols(in geometry: GeometryProxy) -> some View {
        Group {
            // Left side symbols (larger and slower)
            FloatingSymbol(symbol: "X", size: 150, startX: -geometry.size.width * 0.4, startY: -geometry.size.height * 0.3, slowMotion: true)
            FloatingSymbol(symbol: "O", size: 160, startX: -geometry.size.width * 0.35, startY: geometry.size.height * 0.3, slowMotion: true)
            
            // Right side symbols
            FloatingSymbol(symbol: "X", size: 120, startX: geometry.size.width * 0.4, startY: -geometry.size.height * 0.25, slowMotion: true)
            FloatingSymbol(symbol: "O", size: 140, startX: geometry.size.width * 0.35, startY: geometry.size.height * 0.25, slowMotion: true)
            
            // Additional symbols scattered around
            FloatingSymbol(symbol: "X", size: 100, startX: geometry.size.width * 0.15, startY: -geometry.size.height * 0.6, slowMotion: true)
            FloatingSymbol(symbol: "O", size: 130, startX: -geometry.size.width * 0.15, startY: geometry.size.height * 0.5, slowMotion: true)
        }
        .opacity(0.3) // Повећана непрозирност са 0.2 на 0.3
    }
}

struct ContentView: View {
    var body: some View {
        SplashView()
    }
}

#Preview {
    ContentView()
}

private enum DeviceLayout {
    case iphone
    case iphoneLandscape
    case ipad
    case ipadLandscape
    
    var isLandscape: Bool {
        self == .iphoneLandscape || self == .ipadLandscape
    }
    
    var isIphone: Bool {
        self == .iphone || self == .iphoneLandscape
    }
    
    var topPadding: CGFloat {
        switch self {
            case .iphone: return 10
            case .iphoneLandscape: return 5
            case .ipad: return 30
            case .ipadLandscape: return 20
        }
    }
    
    var bottomSafeArea: CGFloat {
        switch self {
            case .iphone: return 30
            case .iphoneLandscape: return 20
            case .ipad: return 40
            case .ipadLandscape: return 30
        }
    }
    
    var scoreSpacing: CGFloat {
        switch self {
            case .iphone: return 20
            case .iphoneLandscape: return 15
            case .ipad: return 40
            case .ipadLandscape: return 30
        }
    }
    
    var gridPadding: CGFloat {
        switch self {
            case .iphone: return 16
            case .iphoneLandscape: return 12
            case .ipad: return 24
            case .ipadLandscape: return 20
        }
    }
    
    func maxBoardWidth(for size: CGSize) -> CGFloat {
        switch self {
            case .iphone:
                return min(140, (size.width - 40) / 2)
            case .iphoneLandscape:
                let availableWidth = size.width * 0.85 // 85% екрана за табле
                return min(size.height * 0.45, (availableWidth - 60) / 4) // Веће табле у landscape режиму
            case .ipad:
                return min(200, (size.width - 80) / 3)
            case .ipadLandscape:
                return min(180, (size.width - 100) / 3)
        }
    }
}
