import SwiftUI

struct GameView: View {
    @StateObject private var gameLogic: GameLogic
    @StateObject private var timerSettings = GameTimerSettings.shared
    @State private var playerXTime: TimeInterval
    @State private var playerOTime: TimeInterval
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var showGameOver = false
    @State private var timeoutPlayer: String? = nil
    @State private var selectedGameMode: GameMode = .aiOpponent
    @State private var startGameTransition = false
    @State private var showPauseMenu = false
    @State private var showGameModeModal = false
    
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
    
    private let bonusTime: TimeInterval = 15 // 15 seconds bonus
    private let penaltyTime: TimeInterval = 10 // 10 seconds penalty
    private let drawPenaltyTime: TimeInterval = 5 // 5 seconds penalty for draw
    
    // Dynamic layout properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme

    // Initializer that accepts a game mode
    init(gameMode: GameMode = .aiOpponent) {
        _gameLogic = StateObject(wrappedValue: GameLogic(gameMode: gameMode))
        
        // Иницијализација времена на основу изабраног режима
        let initialTime = TimeInterval(GameTimerSettings.shared.gameDuration.rawValue)
        _playerXTime = State(initialValue: initialTime)
        _playerOTime = State(initialValue: initialTime)
    }

    // Helper computed properties to simplify expressions
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
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
                
                // Portrait layout
                VStack(spacing: 0) {
                    Spacer()
                    
                    scoreView
                    
                    // Дугме за паузу између скора и табли
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        SoundManager.shared.playHaptic()
                        stopTimer()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showPauseMenu = true
                        }
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: deviceLayout.isIphone ? 32 : 38))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Theme.Colors.primaryGold.opacity(0.8), Theme.Colors.primaryGold.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Theme.Colors.primaryGold.opacity(0.2), radius: 5)
                    }
                    .padding(.top, deviceLayout.isIphone ? 8 : 12)
                    .padding(.bottom, deviceLayout.isIphone ? 8 : 12)
                    
                    gameBoardsGrid(geometry: geometry)
                        .padding(.bottom, deviceLayout.isIphone ? 20 : 30)
                    
                    Spacer()
                }
                .frame(
                    maxHeight: geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)
                )
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: deviceLayout.bottomSafeArea)
                }
                
                // Pause Menu overlay
                if showPauseMenu {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    PauseModalView(
                        onGo: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPauseMenu = false
                                startTimer()
                            }
                        },
                        onRestart: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPauseMenu = false
                                showGameModeModal = true
                            }
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                
                // Game Mode Modal overlay
                if showGameModeModal {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    GameModeModalView(
                        gameMode: selectedGameMode,
                        onPlayVsAI: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showGameModeModal = false
                                handleGameModeChange(to: .aiOpponent)
                            }
                        },
                        onPlayVsPlayer: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showGameModeModal = false
                                handleGameModeChange(to: .playerVsPlayer)
                            }
                        },
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showGameModeModal = false
                                startTimer()
                            }
                        },
                        onGameModeChange: { newMode in
                            selectedGameMode = newMode
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                
                // Game Over overlay
                if showGameOver {
                    GameOverView(
                        timeoutPlayer: timeoutPlayer,
                        playerXTime: playerXTime,
                        playerOTime: playerOTime,
                        score: gameLogic.totalScore,
                        gameLogic: gameLogic,
                        onPlayVsAI: {
                            gameLogic.changeGameMode(to: .aiOpponent)
                            resetGame()
                        },
                        onPlayVsPlayer: {
                            gameLogic.changeGameMode(to: .playerVsPlayer)
                            resetGame()
                        },
                        onStart: {
                            resetGame()
                        },
                        onResetStatistics: {
                            gameLogic.resetStatistics()
                        }
                    )
                }
            }
        }
        .onAppear {
            resetTimers()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - UI Components
    
    private var scoreView: some View {
        GeometryReader { geometry in
            HStack(spacing: deviceLayout.adaptiveSpacing / 3) {
                // Контејнер за X индикатор и тајмер
                VStack(spacing: 4) {
                Text(showXBonus ? "+15sec" : (showXPenalty ? "-10sec" : (showXDrawPenalty ? "-5sec" : "+/-")))
                    .foregroundColor(showXBonus ? .green : (showXPenalty ? .red : (showXDrawPenalty ? .orange : .gray)))
                    .font(.system(size: deviceLayout.scoreIndicatorSize, weight: .medium))
                    .scaleEffect(showXBonus ? xBonusScale : (showXPenalty ? xPenaltyScale : (showXDrawPenalty ? xDrawPenaltyScale : 1.0)))
                
                Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "X" ? Theme.Colors.primaryBlue : .white.opacity(0.7))
                    .font(.system(size: deviceLayout.scoreTimerSize, weight: .bold))
                    .minimumScaleFactor(0.5)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.primaryBlue.opacity(0.3),
                                    Theme.Colors.primaryBlue.opacity(0.1),
                                    Theme.Colors.primaryBlue.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Theme.Colors.primaryBlue.opacity(0.3), radius: 10)
                
                // Резултат
                Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                    .foregroundColor(.white)
                    .font(.system(size: deviceLayout.scoreResultSize, weight: .heavy))
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                ZStack {
                                    // Горње светло
                                    Circle()
                                        .fill(Theme.Colors.primaryGold)
                                        .frame(width: 60, height: 60)
                                        .offset(y: -30)
                                        .blur(radius: 30)
                                        .opacity(0.1)
                                    
                                    // Лево светло
                                    Circle()
                                        .fill(Theme.Colors.primaryBlue)
                                        .frame(width: 40, height: 40)
                                        .offset(x: -20)
                                        .blur(radius: 20)
                                        .opacity(0.08)
                                    
                                    // Десно светло
                                    Circle()
                                        .fill(Theme.Colors.primaryOrange)
                                        .frame(width: 40, height: 40)
                                        .offset(x: 20)
                                        .blur(radius: 20)
                                        .opacity(0.08)
                                }
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Theme.Colors.primaryGold.opacity(0.5),
                                        Theme.Colors.primaryGold.opacity(0.2),
                                        Theme.Colors.primaryGold.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Theme.Colors.primaryGold.opacity(0.3), radius: 15)
                
                // Контејнер за O индикатор и тајмер
                VStack(spacing: 4) {
                Text(showOBonus ? "+15sec" : (showOPenalty ? "-10sec" : (showODrawPenalty ? "-5sec" : "+/-")))
                    .foregroundColor(showOBonus ? .green : (showOPenalty ? .red : (showODrawPenalty ? .orange : .gray)))
                    .font(.system(size: deviceLayout.scoreIndicatorSize, weight: .medium))
                    .scaleEffect(showOBonus ? oBonusScale : (showOPenalty ? oPenaltyScale : (showODrawPenalty ? oDrawPenaltyScale : 1.0)))
                        
                    Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                        .foregroundColor(gameLogic.currentPlayer == "O" ? Theme.Colors.primaryOrange : .white.opacity(0.7))
                        .font(.system(size: deviceLayout.scoreTimerSize, weight: .bold))
                        .minimumScaleFactor(0.5)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.primaryOrange.opacity(0.3),
                                    Theme.Colors.primaryOrange.opacity(0.1),
                                    Theme.Colors.primaryOrange.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Theme.Colors.primaryOrange.opacity(0.3), radius: 10)
            }
            .padding(.horizontal, deviceLayout.adaptiveSpacing)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + (deviceLayout.isIphone ? 20 : 30))
        }
        .frame(height: deviceLayout.scoreViewHeight)
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
        let boardWidth = calculateBoardWidth(for: geometry)

        return BoardView(
            board: $gameLogic.boards[index],
            isActive: gameLogic.currentBoard == index && !gameLogic.gameOver,
            onTap: { cellIndex in
                handleMove(boardIndex: index, cellIndex: cellIndex)
            }
        )
        .frame(width: boardWidth, height: boardWidth)
    }
    
    private func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        return deviceLayout.calculateBoardWidth(for: geometry)
    }
    
    private func startTimer() {
        // Ако је тајмер већ покренут, не покрећемо га поново
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Одузми време тренутном играчу
            if self.gameLogic.currentPlayer == "X" {
                if self.playerXTime > 0 {
                    self.playerXTime -= 1
                }
            } else {
                if self.playerOTime > 0 {
                    self.playerOTime -= 1
                }
            }
            
            // Провери да ли је неком истекло време
            if self.playerXTime == 0 && !self.showGameOver {
                self.handleTimeout(player: "X")
            } else if self.playerOTime == 0 && !self.showGameOver {
                self.handleTimeout(player: "O")
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func resetTimers() {
        let gameTime = TimeInterval(timerSettings.gameDuration.rawValue)
        playerXTime = gameTime
        playerOTime = gameTime
        stopTimer()
    }

    private func handleMove(boardIndex: Int, cellIndex: Int) {
        // Check if valid move
        if gameLogic.boards[boardIndex][cellIndex].isEmpty &&
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
            gameLogic.makeMove(at: cellIndex, in: boardIndex)
            
            // Провери резултат
            if let winner = gameLogic.getLastWinner(for: boardIndex) {
                awardBonusTime(to: winner)
            } else if gameLogic.wasLastMoveDraw(in: boardIndex) {
                handleDrawPenalty()
            }

            // For AI mode, make AI move with random thinking time
            if gameLogic.gameMode == .aiOpponent && !gameLogic.gameOver {
                let thinkingTime = Double.random(in: 0.5...1.5)
                let currentBoardIndex = gameLogic.currentBoard
                
                // Start timer for AI player
                startTimer()
                
                gameLogic.makeAIMove(in: currentBoardIndex, thinkingTime: thinkingTime) {
                    // Stop timer after AI move
                    self.stopTimer()
                    
                    // Sound for AI move
                    SoundManager.shared.playSound(.move)
                    
                    // Провери резултат након AI потеза
                    if let winner = self.gameLogic.getLastWinner(for: currentBoardIndex) {
                        self.awardBonusTime(to: winner)
                    } else if self.gameLogic.wasLastMoveDraw(in: currentBoardIndex) {
                        self.handleDrawPenalty()
                    }
                    
                    // Start timer for human player if game is not over
                    if !self.showGameOver {
                        self.startTimer()
                    }
                }
            } else {
                // Start timer for next player if not in AI mode and game is not over
                if !showGameOver {
                    startTimer()
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
        stopTimer()
        resetTimers()
        gameLogic.resetGame()
        startTimer()
    }
    
    private func handleGameModeChange(to newMode: GameMode) {
        stopTimer()
        gameLogic.resetGame()
        gameLogic.changeGameMode(to: newMode)
        resetTimers()
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
        SoundManager.shared.playSound(.draw)
        
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
        ZStack {
            // Основни тамни градијент
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),  // Скоро црна
                    Color(red: 0.1, green: 0.1, blue: 0.2)     // Тамно плава
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Лево плаво светло
            RadialGradient(
                gradient: Gradient(colors: [
                    Theme.Colors.primaryBlue.opacity(0.3),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 100,
                endRadius: 400
            )
            
            // Десно наранџасто светло
            RadialGradient(
                gradient: Gradient(colors: [
                    Theme.Colors.primaryOrange.opacity(0.3),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            
            // Централнално златно светло (суптилно)
            RadialGradient(
                gradient: Gradient(colors: [
                    Theme.Colors.primaryGold.opacity(0.15),
                    Color.clear
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 200
            )
        }
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
