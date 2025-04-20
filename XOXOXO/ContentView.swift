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
    @Environment(\.colorScheme) private var colorScheme

    // Initializer that accepts a game mode
    init(gameMode: GameMode = .aiOpponent, isPvPUnlocked: Bool = false) {
        _gameLogic = StateObject(wrappedValue: GameLogic(gameMode: gameMode))
        self.isPvPUnlocked = isPvPUnlocked
    }

    // Helper computed properties to simplify expressions
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: nil)
    }
    
    private var gridLayout: [GridItem] {
        [
            GridItem(.flexible(), spacing: deviceLayout.boardSpacing),
            GridItem(.flexible(), spacing: deviceLayout.boardSpacing)
        ]
    }
    
    private var scoreFont: Font {
        isIPad ? .system(size: 48, weight: .bold) : .system(size: 32, weight: .bold)
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
                
                // Portrait layout
                VStack(spacing: 0) {
                    scoreView
                        .padding(.horizontal, deviceLayout.boardSpacing * 2)
                        .padding(.top, deviceLayout.isIphone ? 10 : 20)
                    
                    Spacer()
                        .frame(height: deviceLayout.boardSpacing * 2)
                    
                    gameBoardsGrid(geometry: geometry)
                    
                    Spacer(minLength: deviceLayout.boardSpacing * 2)
                }
                .frame(
                    maxHeight: geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)
                )
                
                // Game Over overlay
                if showGameOver {
                    GameOverView(
                        timeoutPlayer: timeoutPlayer,
                        playerXTime: playerXTime,
                        playerOTime: playerOTime,
                        score: gameLogic.totalScore,
                        isPvPUnlocked: isPvPUnlocked,
                        onPlayVsAI: {
                            gameLogic.changeGameMode(to: .aiOpponent)
                            resetGame()
                        },
                        onPlayVsPlayer: {
                            gameLogic.changeGameMode(to: .playerVsPlayer)
                            resetGame()
                        },
                        onShowPurchase: { showPurchaseView = true }
                    )
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
        VStack(spacing: isIPad ? 12 : 8) {
            // Резултат и тајмери
            HStack(spacing: isIPad ? 40 : 20) {
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
            .padding(.vertical, isIPad ? 8 : 4)
            
            // Време потеза
            HStack(spacing: isIPad ? 60 : 30) {
                Text(showXBonus ? "+15sec" : (showXPenalty ? "-10sec" : (showXDrawPenalty ? "-5sec" : "00sec")))
                    .foregroundColor(showXBonus ? .green : (showXPenalty ? .red : (showXDrawPenalty ? .orange : .gray)))
                    .font(.system(size: isIPad ? 20 : 16, weight: .medium))
                    .scaleEffect(showXBonus ? xBonusScale : (showXPenalty ? xPenaltyScale : (showXDrawPenalty ? xDrawPenaltyScale : 1.0)))
                
                Text(showOBonus ? "+15sec" : (showOPenalty ? "-10sec" : (showODrawPenalty ? "-5sec" : "00sec")))
                    .foregroundColor(showOBonus ? .green : (showOPenalty ? .red : (showODrawPenalty ? .orange : .gray)))
                    .font(.system(size: isIPad ? 20 : 16, weight: .medium))
                    .scaleEffect(showOBonus ? oBonusScale : (showOPenalty ? oPenaltyScale : (showODrawPenalty ? oDrawPenaltyScale : 1.0)))
            }
            .padding(.bottom, isIPad ? 8 : 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
    
    private func gameBoardsGrid(geometry: GeometryProxy) -> some View {
        let maxWidth = geometry.size.width - (deviceLayout.boardSpacing * 2)
        
        return LazyVGrid(
            columns: gridLayout,
            spacing: deviceLayout.boardSpacing
        ) {
            ForEach(0..<8) { index in
                boardView(for: index, geometry: geometry)
            }
        }
        .frame(width: maxWidth)
        .padding(.horizontal, deviceLayout.boardSpacing)
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
        .frame(width: maxWidth, height: maxWidth)
    }
    
    private func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        return deviceLayout.calculateBoardWidth(for: geometry)
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
        .opacity(0.3)
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
