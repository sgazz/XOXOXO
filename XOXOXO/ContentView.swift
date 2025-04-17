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
    
    // Simplify grid layout with fixed values
    private var gridLayout: [GridItem] {
        let gridItems: [GridItem]
        if isLandscape {
            // Landscape: 4 columns (2 rows of 4)
            gridItems = [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        } else {
            // Portrait: 2 columns (4 rows of 2)
            gridItems = [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        }
        return gridItems
    }
    
    // Helper properties for text styles
    private var largeScoreFont: Font {
        isIPad ? .system(size: 48, weight: .bold) : .system(size: 36, weight: .bold)
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
                
                // Game content in scrollview
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        // Score display with timers
                        HStack(spacing: 25) {
                            // Player X timer
                            Text(String(format: "%02d:%02d", Int(playerXTime) / 60, Int(playerXTime) % 60))
                                .foregroundColor(gameLogic.currentPlayer == "X" ? .blue : .white)
                                .font(largeScoreFont)
                            
                            // Main score
                            Text("\(gameLogic.totalScore.x):\(gameLogic.totalScore.o)")
                                .foregroundColor(.white)
                                .font(largeScoreFont)
                            
                            // Player O timer
                            Text(String(format: "%02d:%02d", Int(playerOTime) / 60, Int(playerOTime) % 60))
                                .foregroundColor(gameLogic.currentPlayer == "O" ? .red : .white)
                                .font(largeScoreFont)
                        }
                        .padding(.top, isIPad ? 20 : 10)

                        // Game boards grid
                        gameBoardsGrid(geometry: geometry)
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
    
    // Game boards grid
    private func gameBoardsGrid(geometry: GeometryProxy) -> some View {
        LazyVGrid(
            columns: gridLayout,
            spacing: isIPad ? 30 : 25
        ) {
            ForEach(0..<8) { index in
                boardView(for: index)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
    }
    
    private func boardView(for index: Int) -> some View {
        BoardView(
            board: .init(
                get: { gameLogic.boards[index] },
                set: { gameLogic.boards[index] = $0 }
            ),
            isActive: gameLogic.currentBoard == index && !gameLogic.gameOver,
            onTap: { position in
                handleBoardTap(boardIndex: index, position: position)
            }
        )
        .frame(maxWidth: isIPad ? 180 : 120)
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
        let darkMode = colorScheme == .dark
        
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
