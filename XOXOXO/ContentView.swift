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
    
    // Нове променљиве за бонус време
    @State private var showXBonus = false
    @State private var showOBonus = false
    @State private var xBonusScale: CGFloat = 1.0
    @State private var oBonusScale: CGFloat = 1.0
    
    // Нове променљиве за одузимање времена
    @State private var showXPenalty = false
    @State private var showOPenalty = false
    @State private var xPenaltyScale: CGFloat = 1.0
    @State private var oPenaltyScale: CGFloat = 1.0
    
    // Нове променљиве за нерешену партију
    @State private var showXDrawPenalty = false
    @State private var showODrawPenalty = false
    @State private var xDrawPenaltyScale: CGFloat = 1.0
    @State private var oDrawPenaltyScale: CGFloat = 1.0
    
    private let defaultTime: TimeInterval = 300 // 5 minutes in seconds
    private let bonusTime: TimeInterval = 15 // 15 seconds bonus
    private let penaltyTime: TimeInterval = 10 // 10 seconds penalty
    private let drawPenaltyTime: TimeInterval = 5 // 5 seconds penalty for draw
    
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
                    ZStack {
                        // Замагљена позадина са градијентом
                        backgroundGradient
                            .blur(radius: 20)
                            .opacity(0.98)
                            .ignoresSafeArea()
                        
                        // Садржај Game Over прозора
                        VStack(spacing: 25) {
                            // Анимирана икона
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
                                    .frame(width: 120, height: 120)
                                    .shadow(color: (timeoutPlayer == nil ? Color.green : Color.red).opacity(0.5), radius: 15)
                                
                                Image(systemName: timeoutPlayer == nil ? "trophy.fill" : "timer")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                            }
                            .scaleEffect(1.2)
                            .rotation3DEffect(.degrees(showGameOver ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showGameOver)
                            
                            // Наслов и поднаслов
                            VStack(spacing: 10) {
                                Text("Game Over")
                                    .font(.system(size: 46, weight: .heavy))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                                
                                if let player = timeoutPlayer {
                                    Text("\(player == "X" ? "Blue" : "Red") player ran out of time!")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            // Статистика игре
                            HStack(spacing: 30) {
                                // Време плавог играча
                                VStack {
                                    Text("Blue Time")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                                        .font(.title2.bold())
                                        .foregroundColor(.blue)
                                }
                                
                                // Резултат
                                VStack {
                                    Text("Score")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                                        .font(.title.bold())
                                        .foregroundColor(.white)
                                }
                                
                                // Време црвеног играча
                                VStack {
                                    Text("Red Time")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                                        .font(.title2.bold())
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                            )
                            
                            // Дугме за поновну игру
                            Button(action: resetGame) {
                                Text("Play Again")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
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
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showGameOver)
                        }
                        .offset(y: -20)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
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
                    // Време плавог играча (X)
                    VStack(spacing: 4) {
                        Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                            .foregroundColor(gameLogic.currentPlayer == "X" ? .blue : .white.opacity(0.7))
                            .font(.system(size: 20, weight: .bold))
                            .minimumScaleFactor(0.5)
                        
                        // Бонус/казна време за X
                        Text(showXBonus ? "+15sec" : (showXPenalty ? "-10sec" : (showXDrawPenalty ? "-5sec" : "00sec")))
                            .foregroundColor(showXBonus ? .green : (showXPenalty ? .red : (showXDrawPenalty ? .orange : .gray)))
                            .font(.system(size: 14, weight: .medium))
                            .scaleEffect(showXBonus ? xBonusScale : (showXPenalty ? xPenaltyScale : (showXDrawPenalty ? xDrawPenaltyScale : 1.0)))
                    }
                    
                    Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .heavy))
                        .minimumScaleFactor(0.5)
                    
                    // Време црвеног играча (O)
                    VStack(spacing: 4) {
                        Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                            .foregroundColor(gameLogic.currentPlayer == "O" ? .red : .white.opacity(0.7))
                            .font(.system(size: 20, weight: .bold))
                            .minimumScaleFactor(0.5)
                        
                        // Бонус/казна време за O
                        Text(showOBonus ? "+15sec" : (showOPenalty ? "-10sec" : (showODrawPenalty ? "-5sec" : "00sec")))
                            .foregroundColor(showOBonus ? .green : (showOPenalty ? .red : (showODrawPenalty ? .orange : .gray)))
                            .font(.system(size: 14, weight: .medium))
                            .scaleEffect(showOBonus ? oBonusScale : (showOPenalty ? oPenaltyScale : (showODrawPenalty ? oDrawPenaltyScale : 1.0)))
                    }
                }
            } else {
                // Portrait score view
                VStack(spacing: 8) {
                    // Резултат и тајмери
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
                    
                    // Време потеза
                    HStack(spacing: deviceLayout.scoreSpacing * 1.5) {
                        Text(showXBonus ? "+15sec" : (showXPenalty ? "-10sec" : (showXDrawPenalty ? "-5sec" : "00sec")))
                            .foregroundColor(showXBonus ? .green : (showXPenalty ? .red : (showXDrawPenalty ? .orange : .gray)))
                            .font(.system(size: deviceLayout.isIphone ? 16 : 20, weight: .medium))
                            .scaleEffect(showXBonus ? xBonusScale : (showXPenalty ? xPenaltyScale : (showXDrawPenalty ? xDrawPenaltyScale : 1.0)))
                        
                        Text(showOBonus ? "+15sec" : (showOPenalty ? "-10sec" : (showODrawPenalty ? "-5sec" : "00sec")))
                            .foregroundColor(showOBonus ? .green : (showOPenalty ? .red : (showODrawPenalty ? .orange : .gray)))
                            .font(.system(size: deviceLayout.isIphone ? 16 : 20, weight: .medium))
                            .scaleEffect(showOBonus ? oBonusScale : (showOPenalty ? oPenaltyScale : (showODrawPenalty ? oDrawPenaltyScale : 1.0)))
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, deviceLayout.isIphone ? 5 : 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal, deviceLayout.isIphone ? 10 : 20)
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
            // Одузми време тренутном играчу
            if gameLogic.currentPlayer == "X" {
                if playerXTime > 0 {
                    playerXTime -= 1
                }
            } else {
                if playerOTime > 0 {
                    playerOTime -= 1
                }
            }
            
            // Провери да ли је неком истекло време
            if playerXTime == 0 && !showGameOver {
                handleTimeout(player: "X")
            } else if playerOTime == 0 && !showGameOver {
                handleTimeout(player: "O")
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
           (!gameLogic.gameOver) &&
           playerXTime > 0 && playerOTime > 0 {

            // Stop timer for current player
            stopTimer()

            // Sound and haptics for player move
            SoundManager.shared.playSound(.move)
            SoundManager.shared.playHaptic()

            // Направи потез
            gameLogic.makeMove(at: position, in: boardIndex)
            
            // Провери резултат
            if let winner = gameLogic.getLastWinner(for: boardIndex) {
                awardBonusTime(to: winner)
            } else if gameLogic.wasLastMoveDraw(in: boardIndex) {
                handleDrawPenalty()
            }

            // Start timer for next player
            startTimer()

            // For AI mode, make AI move with random thinking time
            if gameLogic.gameMode == .aiOpponent && !gameLogic.gameOver {
                let thinkingTime = Double.random(in: 0.5...1.5)
                let currentBoardIndex = gameLogic.currentBoard
                
                gameLogic.makeAIMove(in: currentBoardIndex, thinkingTime: thinkingTime) {
                    // Sound for AI move
                    SoundManager.shared.playSound(.move)
                    
                    // Провери резултат након AI потеза
                    if let winner = self.gameLogic.getLastWinner(for: currentBoardIndex) {
                        self.awardBonusTime(to: winner)
                    } else if self.gameLogic.wasLastMoveDraw(in: currentBoardIndex) {
                        self.handleDrawPenalty()
                    }
                    
                    // Stop timer after AI move
                    self.stopTimer()
                    // Start timer for player
                    self.startTimer()
                }
            }
        }
    }
    
    private func awardBonusTime(to winner: String) {
        if winner == "X" {
            playerXTime += bonusTime
            showXBonus = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                xBonusScale = 1.3
            }
            // Одузми време губитнику
            playerOTime = max(0, playerOTime - penaltyTime)
            showOPenalty = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                oPenaltyScale = 1.3
            }
        } else {
            playerOTime += bonusTime
            showOBonus = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                oBonusScale = 1.3
            }
            // Одузми време губитнику
            playerXTime = max(0, playerXTime - penaltyTime)
            showXPenalty = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                xPenaltyScale = 1.3
            }
        }
        
        // Пусти звук за бонус
        SoundManager.shared.playSound(.win)
        
        // Ресетуј приказ бонуса и казне након 1.5 секунде
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                if winner == "X" {
                    showXBonus = false
                    showOPenalty = false
                    xBonusScale = 1.0
                    oPenaltyScale = 1.0
                } else {
                    showOBonus = false
                    showXPenalty = false
                    oBonusScale = 1.0
                    xPenaltyScale = 1.0
                }
            }
        }
    }
    
    private func handleTimeout(player: String) {
        stopTimer()
        timeoutPlayer = player
        gameLogic.gameOver = true
        
        // Пусти звук за крај игре
        SoundManager.shared.playSound(.win)
        
        // Одмах прикажи Game Over екран
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
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
    
    private func handleDrawPenalty() {
        // Одузми време обојици играча
        playerXTime = max(0, playerXTime - drawPenaltyTime)
        playerOTime = max(0, playerOTime - drawPenaltyTime)
        
        // Прикажи анимације
        showXDrawPenalty = true
        showODrawPenalty = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            xDrawPenaltyScale = 1.3
            oDrawPenaltyScale = 1.3
        }
        
        // Пусти звук за нерешено
        SoundManager.shared.playSound(.move)
        
        // Ресетуј приказ након 1.5 секунде
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showXDrawPenalty = false
                showODrawPenalty = false
                xDrawPenaltyScale = 1.0
                oDrawPenaltyScale = 1.0
            }
        }
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
