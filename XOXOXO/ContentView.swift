import SwiftUI
struct GameView: View {
    @StateObject private var gameLogic: GameLogic
    @State private var winningPlayer: String? = nil
    @State private var showPurchaseView = false
    @State private var isPvPUnlocked: Bool = false

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
                        // Header section
                        VStack(spacing: 10) {
                            // Score display
                            HStack(spacing: 15) {
                                Text("\(gameLogic.totalScore.x)")
                                    .foregroundColor(.blue)
                                    .font(largeScoreFont)

                                Text(":")
                                    .font(largeScoreFont)
                                    .foregroundColor(.white)

                                Text("\(gameLogic.totalScore.o)")
                                    .foregroundColor(.red)
                                    .font(largeScoreFont)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.15))
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
                            )
                            
                            // Game mode selector
                            gameModeSelector
                            
                            // Player indicator (for PvP mode)
                            if gameLogic.gameMode == .playerVsPlayer {
                                playerIndicator
                            }
                        }
                        .padding(.top, isIPad ? 20 : 10)

                        // Game boards grid
                        gameBoardsGrid(geometry: geometry)

                        // Game over modal
                        if gameLogic.gameOver {
                            gameOverModal
                        }
                    }
                }
            }
            .sheet(isPresented: $showPurchaseView) {
                PurchaseView(isPvPUnlocked: $isPvPUnlocked)
            }
        }
        .onChange(of: gameLogic.winner) { oldValue, newValue in
            handleWinnerChange(newValue)
        }
        .onChange(of: isPvPUnlocked) { oldValue, newValue in
            if newValue && !oldValue {
                // PvP мод је откључан, промени мод игре
                gameLogic.changeGameMode(to: .playerVsPlayer)
                SoundManager.shared.playSound(.win)
            }
        }
    }
    
    // MARK: - UI Components
    
    // Game Mode selector buttons
    private var gameModeSelector: some View {
        HStack(spacing: 15) {
            // AI mode button
            Button(action: {
                if gameLogic.gameMode != .aiOpponent {
                    SoundManager.shared.playSound(.tap)
                    SoundManager.shared.playHaptic()
                    gameLogic.changeGameMode(to: .aiOpponent)
                }
            }) {
                aiButtonContent
            }
            
            // PvP mode button
            Button(action: {
                SoundManager.shared.playSound(.tap)
                SoundManager.shared.playHaptic()
                
                if isPvPUnlocked {
                    if gameLogic.gameMode != .playerVsPlayer {
                        gameLogic.changeGameMode(to: .playerVsPlayer)
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
        let isSelected = gameLogic.gameMode == .aiOpponent
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
        let isSelected = gameLogic.gameMode == .playerVsPlayer
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
    
    private var playerIndicator: some View {
        let currentPlayer = gameLogic.currentPlayer
        let isPlayerX = currentPlayer == "X"
        let playerColor = isPlayerX ? Color.blue : Color.red
        let playerColorLight = isPlayerX ? Color.blue.opacity(0.2) : Color.red.opacity(0.2)
        
        return HStack {
            Text("Current Player:")
                .font(.headline)
                .foregroundColor(.white)

            Text(currentPlayer)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(playerColorLight)
                        .overlay(
                            Capsule()
                                .stroke(playerColor, lineWidth: 2)
                        )
                )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .transition(.opacity)
    }
    
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
    
    private func handleBoardTap(boardIndex: Int, position: Int) {
        // Check if valid move
        if gameLogic.boards[boardIndex][position].isEmpty &&
           !gameLogic.isThinking &&
           gameLogic.currentBoard == boardIndex &&
           (!gameLogic.gameOver) {

            // Sound and haptics for player move
            SoundManager.shared.playSound(.move)
            SoundManager.shared.playHaptic()

            gameLogic.makeMove(at: position, in: boardIndex)

            // Check if game ended
            checkGameEnd()

            // For AI mode, make AI move
            if gameLogic.gameMode == .aiOpponent && !gameLogic.gameOver {
                gameLogic.makeAIMove(in: boardIndex) {
                    // Sound for AI move
                    SoundManager.shared.playSound(.move)

                    // Check if game ended after AI move
                    checkGameEnd()
                }
            }
        }
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
        .opacity(0.2) // Мало транспарентније него на уводном екрану
    }
    
    // Game over modal
    private var gameOverModal: some View {
        let winner = gameLogic.winner
        let isWinnerX = winner == "X"
        let isWinnerO = winner == "O" 
        let isDraw = winner == "Draw"
        
        let winnerColor: Color = {
            if isWinnerX { return .blue }
            else if isWinnerO { return .red }
            else { return .primary }
        }()
        
        let winnerShadowColor: Color = {
            if isWinnerX { return .blue.opacity(0.5) }
            else if isWinnerO { return .red.opacity(0.5) }
            else { return .gray.opacity(0.5) }
        }()
        
        let winnerText = isDraw ? "Tournament Draw!" : "Winner: \(winner!)"
        let winnerFont = isIPad ? Font.system(size: 40, weight: .bold) : Font.system(size: 32, weight: .bold)
        
        return VStack(spacing: 15) {
            Text(winnerText)
                .font(winnerFont)
                .foregroundColor(winnerColor)
                .shadow(color: winnerShadowColor, radius: 2)
                .padding(.top, 10)

            // Display player names based on game mode
            if gameLogic.gameMode == .playerVsPlayer && !isDraw {
                let playerWinText = isWinnerX ? "Player 1 Wins!" : "Player 2 Wins!"
                Text(playerWinText)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
            }

            // Score display
            scoreDisplay
            
            // Play Again button
            playAgainButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 10)
        )
        .padding(.horizontal)
        .transition(.scale.combined(with: .opacity))
    }
    
    private var scoreDisplay: some View {
        let winner = gameLogic.winner
        let isWinnerX = winner == "X"
        let isWinnerO = winner == "O"
        let isPvP = gameLogic.gameMode == .playerVsPlayer
        
        return HStack(spacing: 20) {
            // X Score
            VStack {
                Text(isPvP ? "Player 1" : "X")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
                Text("\(gameLogic.totalScore.x)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isWinnerX ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .shadow(color: .gray.opacity(0.2), radius: 5)
            )
            .overlay(
                isWinnerX ?
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue, lineWidth: 3)
                        .shadow(color: .blue.opacity(0.5), radius: 5)
                : nil
            )

            // O Score
            VStack {
                Text(isPvP ? "Player 2" : "O")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                Text("\(gameLogic.totalScore.o)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isWinnerO ? Color.red.opacity(0.2) : Color(.systemGray6))
                    .shadow(color: .gray.opacity(0.2), radius: 5)
            )
            .overlay(
                isWinnerO ?
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.red, lineWidth: 3)
                        .shadow(color: .red.opacity(0.5), radius: 5)
                : nil
            )
        }
        .padding(.vertical, 10)
    }
    
    private var playAgainButton: some View {
        Button(action: {
            gameLogic.resetGame()
            SoundManager.shared.playSound(.tap)
            SoundManager.shared.playHaptic()
        }) {
            Text("Play Again")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 3)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Helper Methods
    
    private func handleWinnerChange(_ newWinner: String?) {
        if let winner = newWinner {
            winningPlayer = winner
            
            if gameLogic.gameMode == .playerVsPlayer {
                // In PvP mode always play win sound
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SoundManager.shared.playSound(.win)
                    SoundManager.shared.playHeavyHaptic()
                }
            } else {
                // In AI mode, differentiate between player and AI win
                if winner == "X" {
                    // Player win animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SoundManager.shared.playSound(.win)
                        SoundManager.shared.playHeavyHaptic()
                    }
                } else {
                    // AI win
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        SoundManager.shared.playSound(.lose)
                        SoundManager.shared.playHaptic(style: .heavy)
                    }
                }
            }
        } else if gameLogic.gameOver {
            // Draw
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SoundManager.shared.playSound(.draw)
                SoundManager.shared.playHaptic()
            }
        }
    }

    // Helper functions
    private func checkGameEnd() {
        if gameLogic.gameOver && winningPlayer == nil {
            if let winner = gameLogic.winner {
                winningPlayer = winner
            }
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
