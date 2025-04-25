import SwiftUI

struct TutorialView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Binding var startGame: Bool
    @State private var currentTab = 0
    
    // MARK: - Constants
    private enum Constants {
        // Spacing
        static let defaultSpacing: CGFloat = 20
        static let compactSpacing: CGFloat = 5
        static let dotSpacing: CGFloat = 12
        static let cardHorizontalSpacing: CGFloat = 20
        
        // Sizes
        static let dotSize: CGFloat = 8
        static let dotBorderSize: CGFloat = 12
        static let dotBorderWidth: CGFloat = 2
        
        // Scale factors
        static let activeDotScale: CGFloat = 1.2
        static let backgroundOpacity: CGFloat = 0.1
        static let materialOpacity: CGFloat = 0.8
        static let inactiveDotOpacity: CGFloat = 0.3
        static let dotBorderOpacity: CGFloat = 0.5
        
        // Layout ratios
        static let landscapeIconWidth: CGFloat = 0.3
        static let landscapeContentWidth: CGFloat = 0.7
        
        // Металик боје
        static let goldGradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.84, blue: 0.4),
                Color(red: 0.8, green: 0.6, blue: 0.2),
                Color(red: 1.0, green: 0.84, blue: 0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let goldBorderWidth: CGFloat = 2
        static let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    }
    
    // MARK: - Tutorial Data
    private struct TutorialScreen {
        let title: String
        let subtitle: String
        let description: String
        let tutorialType: TutorialType
    }
    
    private enum TutorialType {
        case basicGame
        case boardConnection
        case aiGame
        case winning
    }
    
    private let tutorialScreens: [TutorialScreen] = [
        TutorialScreen(
            title: "Welcome to the\n XO Arena",
            subtitle: "One arena, eight boards, infinite strategies",
            description: " It's Tic-Tac-Toe like you've never seen before.\n\nPlay across 8 boards in a row.\n\nPlan smart. Play fast.\n\nWin the Arena.",
            tutorialType: .basicGame
        ),
        TutorialScreen(
            title: " The Rules Just Got Smarter",
            subtitle: " One Move Changes Everything",
            description: " Line up 3 symbols to win a board.\n\nBut each move sends you and your rival to a new board.\nIt's strategy on top of strategy!",
            tutorialType: .boardConnection
        ),
        TutorialScreen(
            title: " Choose Your Opponent",
            subtitle: " Play AI or Face a Friend",
            description: "Single Player: Battle a smart, adaptive opponent.\n\nMultiplayer: Challenge a friend in local multiplayer.\n\nPick your path to victory.",
            tutorialType: .aiGame
        ),
        TutorialScreen(
            title: " Ready to Complete?",
            subtitle: " 1 Minute. 8 Boards. 1 Champion.",
            description: "Think fast.\n\nPlay bold.\n\nMaster the multi-board arena and become the XO Arena legend.",
            tutorialType: .winning
        )
    ]
    
    // MARK: - Tutorial Animations
    private func tutorialAnimation(for type: TutorialType, size: CGFloat) -> some View {
        Group {
            switch type {
            case .basicGame:
                BasicGameAnimation(size: size)
            case .boardConnection:
                BoardConnectionAnimation(size: size)
            case .aiGame:
                AIGameAnimation(size: size)
            case .winning:
                WinningAnimation(size: size)
            }
        }
    }
    
    // MARK: - Animation Components
    private struct BasicGameAnimation: View {
        let size: CGFloat
        @State private var currentSymbol = "X"
        @State private var opacity = 0.0
        
        var body: some View {
            ZStack {
                // Табла
                Grid {
                    ForEach(0..<3) { row in
                        GridRow {
                            ForEach(0..<3) { column in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: size/3.5, height: size/3.5)
                                    .border(Theme.Colors.primaryGold.opacity(0.3), width: 1)
                            }
                        }
                    }
                }
                .frame(width: size, height: size)
                
                // Симбол који се анимира
                Text(currentSymbol)
                    .font(.system(size: size/4, weight: .bold))
                    .foregroundColor(currentSymbol == "X" ? Theme.Colors.primaryBlue : Theme.Colors.primaryOrange)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 1.0
                }
                
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    withAnimation {
                        currentSymbol = currentSymbol == "X" ? "O" : "X"
                    }
                }
            }
        }
    }
    
    private struct BoardConnectionAnimation: View {
        let size: CGFloat
        @State private var positions: [CGFloat]
        @State private var animationID = UUID()
        
        init(size: CGFloat) {
            self.size = size
            let boardWidth = size + size/4
            _positions = State(initialValue: [0, boardWidth, boardWidth * 2])
        }
        
        // Дефинишемо три различите конфигурације табли
        private let boardConfigs: [[String?]] = [
            [nil, "X", nil, "O", nil, nil, nil, "O", "X"],  // Прва конфигурација
            ["O", nil, "X", nil, nil, "O", "X", nil, nil],  // Друга конфигурација
            ["X", "O", nil, nil, "X", "O", "X", nil, nil]   // Трећа конфигурација (3 X и 2 O)
        ]
        
        var body: some View {
            GeometryReader { geometry in
                let boardWidth = size + size/4
                
                ZStack {
                    ForEach(0..<3) { index in
                        HStack(spacing: size/4) {
                            boardView(for: index)
                            Image(systemName: "arrow.left")
                                .font(.system(size: size/4))
                                .foregroundColor(Theme.Colors.primaryGold)
                        }
                        .offset(x: positions[index])
                    }
                }
                .onAppear {
                    resetPositions(boardWidth: boardWidth)
                    startAnimation(boardWidth: boardWidth)
                }
                .onDisappear {
                    // Генеришемо нови ID за следећу анимацију
                    animationID = UUID()
                }
                .id(animationID) // Користимо ID да бисмо осигурали да се view потпуно обнови
            }
            .frame(width: size * 1.5, height: size)
            .clipped()
        }
        
        private func resetPositions(boardWidth: CGFloat) {
            positions = [0, boardWidth, boardWidth * 2]
        }
        
        private func startAnimation(boardWidth: CGFloat) {
            withAnimation(
                .linear(duration: 8)
                .repeatForever(autoreverses: false)
            ) {
                for i in 0..<3 {
                    positions[i] -= boardWidth * 3
                }
            }
        }
        
        private func boardView(for index: Int) -> some View {
            ZStack {
                Grid {
                    ForEach(0..<3) { row in
                        GridRow {
                            ForEach(0..<3) { column in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: size/4, height: size/4)
                                    .border(Theme.Colors.primaryGold.opacity(0.3), width: 1)
                                    .overlay {
                                        if let symbol = boardConfigs[index][row * 3 + column] {
                                            Text(symbol)
                                                .font(.system(size: size/5, weight: .bold))
                                                .foregroundColor(symbol == "X" ? Theme.Colors.primaryBlue : Theme.Colors.primaryOrange)
                                                .opacity(0.8)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private struct AIGameAnimation: View {
        let size: CGFloat
        @State private var thinking = false
        @State private var showSymbol = false
        @State private var animationID = UUID()
        
        var body: some View {
            ZStack {
                // Табла
                Grid {
                    ForEach(0..<3) { row in
                        GridRow {
                            ForEach(0..<3) { column in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: size/3.5, height: size/3.5)
                                    .border(Theme.Colors.primaryGold.opacity(0.3), width: 1)
                            }
                        }
                    }
                }
                
                // Иконице за режиме игре
                if thinking {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: size/2.5))
                        .foregroundColor(Theme.Colors.primaryGold)
                        .opacity(0.8)
                } else {
                    Image(systemName: "cpu")
                        .font(.system(size: size/2.5))
                        .foregroundColor(Theme.Colors.primaryOrange)
                        .opacity(showSymbol ? 1 : 0)
                }
            }
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                // Генеришемо нови ID за следећу анимацију
                animationID = UUID()
            }
            .id(animationID)
        }
        
        private func startAnimation() {
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever()) {
                thinking = true
            }
            
            func animate() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showSymbol = true
                        thinking = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            showSymbol = false
                            thinking = true
                            
                            // Настављамо анимацију
                            animate()
                        }
                    }
                }
            }
            
            animate()
        }
    }
    
    private struct WinningAnimation: View {
        let size: CGFloat
        @State private var showWinLine = false
        
        var body: some View {
            ZStack {
                // Табла са X-евима
                Grid {
                    ForEach(0..<3) { row in
                        GridRow {
                            ForEach(0..<3) { column in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: size/3.5, height: size/3.5)
                                    .border(Theme.Colors.primaryGold.opacity(0.3), width: 1)
                                    .overlay {
                                        if row == column {
                                            Text("X")
                                                .font(.system(size: size/4, weight: .bold))
                                                .foregroundColor(Theme.Colors.primaryBlue)
                                        }
                                    }
                            }
                        }
                    }
                }
                
                // Победничка линија
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size, y: size))
                }
                .stroke(Theme.Colors.primaryGold, lineWidth: 3)
                .opacity(showWinLine ? 1 : 0)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    showWinLine = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var animationSize: CGFloat { isLandscape ? 120 : 180 }
    private var verticalSpacing: CGFloat { isLandscape ? Constants.compactSpacing : Constants.defaultSpacing }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Металик позадина са акцентним светлима
                Theme.Colors.darkGradient
                    .overlay(
                        ZStack {
                            // Главни сноп светлости
                            Circle()
                                .fill(Theme.Colors.primaryGold)
                                .frame(width: UIScreen.main.bounds.width * 1.5)
                                .offset(y: -UIScreen.main.bounds.height * 0.8)
                                .blur(radius: 100)
                                .opacity(0.3)
                            
                            // Акцентна светла
                            Circle()
                                .fill(Theme.Colors.primaryBlue)
                                .frame(width: UIScreen.main.bounds.width)
                                .offset(x: -UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.3)
                                .blur(radius: 100)
                                .opacity(0.2)
                            
                            Circle()
                                .fill(Theme.Colors.primaryOrange)
                                .frame(width: UIScreen.main.bounds.width)
                                .offset(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.3)
                                .blur(radius: 100)
                                .opacity(0.2)
                        }
                    )
                    .ignoresSafeArea()
                
                // Tutorial content
                TabView(selection: $currentTab) {
                    ForEach(0..<tutorialScreens.count, id: \.self) { index in
                        tutorialCard(for: index, in: geometry)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentTab)
                .onChange(of: currentTab) { _ in
                    SoundManager.shared.playSound(.tap)
                }
                
                // Page indicator
                VStack {
                    Spacer()
                    pageIndicator
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Helper Views
    private var pageIndicator: some View {
        HStack(spacing: Constants.dotSpacing) {
            ForEach(0..<tutorialScreens.count, id: \.self) { index in
                Circle()
                    .fill(currentTab == index ? Theme.Colors.primaryGold : Color.gray.opacity(0.3))
                    .frame(width: Constants.dotSize, height: Constants.dotSize)
                    .scaleEffect(currentTab == index ? Constants.activeDotScale : 1.0)
                    .animation(.spring(), value: currentTab)
                    .onTapGesture {
                        withAnimation {
                            currentTab = index
                        }
                    }
            }
        }
    }
    
    private func tutorialCard(for index: Int, in geometry: GeometryProxy) -> some View {
        let screen = tutorialScreens[index]
        
        return VStack(spacing: verticalSpacing) {
            tutorialAnimation(for: screen.tutorialType, size: animationSize)
                .frame(width: animationSize, height: animationSize)
            
            VStack(spacing: verticalSpacing) {
                Text(screen.title)
                    .font(.title.bold())
                    .foregroundColor(Theme.Colors.primaryGold)
                    .multilineTextAlignment(.center)
                
                Text(screen.subtitle)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primaryGold)
                    .multilineTextAlignment(.center)
                
                Text(screen.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                if index == tutorialScreens.count - 1 {
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        startGame = false
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .frame(width: 200, height: 50)
                            .background(
                                Theme.Colors.primaryGold
                            )
                            .cornerRadius(25)
                    }
                    .padding(.top, 30)
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    TutorialView(startGame: .constant(false))
} 
 


