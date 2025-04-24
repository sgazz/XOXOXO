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
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let description: String
        let subtitleColor: Color
    }
    
    private let tutorialScreens: [TutorialScreen] = [
        TutorialScreen(
            icon: "gamecontroller.fill",
            color: .blue,
            title: "🎯 Welcome to the XO Arena",
            subtitle: "🧠 Classic Rules, Epic Twist",
            description: "🎮 It's Tic-Tac-Toe like you've never seen before.\nPlay across 8 boards at once.\nPlan smart. Play fast.\nWin the Arena.",
            subtitleColor: Color(red: 0.3, green: 0.7, blue: 1.0)
        ),
        TutorialScreen(
            icon: "list.bullet",
            color: .purple,
            title: "🧩 The Rules Just Got Smarter",
            subtitle: "🔁 One Move Changes Everything",
            description: "🧠 Line up 3 symbols to win a board.\nBut each move sends your rival to a new board.\nIt's strategy on top of strategy!",
            subtitleColor: Color(red: 0.8, green: 0.4, blue: 1.0)
        ),
        TutorialScreen(
            icon: "brain.head.profile",
            color: .orange,
            title: "🤖 Choose Your Opponent",
            subtitle: "🧠 Play AI or Face a Friend",
            description: "⚔️ PvAI: Battle a smart, adaptive opponent.\n👥 PvP: Challenge a friend in local multiplayer.\nPick your path to victory.",
            subtitleColor: Color(red: 1.0, green: 0.6, blue: 0.2)
        ),
        TutorialScreen(
            icon: "flag.checkered",
            color: .green,
            title: "🏁 Ready to Compete?",
            subtitle: "🔥 5 Minutes. 8 Boards in loop. 1 Champion.",
            description: "⚡ Think fast.\n🎯 Play bold.\n👑 Master the multi-board arena and become the XO legend.",
            subtitleColor: Color(red: 0.3, green: 0.9, blue: 0.4)
        )
    ]
    
    // MARK: - Computed Properties
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var iconSize: CGFloat { isLandscape ? 60 : 85 }
    private var circleSize: CGFloat { isLandscape ? 120 : 180 }
    private var outerCircleSize: CGFloat { isLandscape ? 140 : 200 }
    private var verticalSpacing: CGFloat { isLandscape ? Constants.compactSpacing : Constants.defaultSpacing }
    
    private func iconSection(_ screen: TutorialScreen) -> some View {
        ZStack {
            // Основни златни новчић
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.4),  // Светлије злато
                            Color(red: 0.85, green: 0.6, blue: 0.2),  // Средње злато
                            Color(red: 0.7, green: 0.5, blue: 0.1)    // Тамније злато
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: circleSize, height: circleSize)
                
            // 3D ефекат ивице новчића
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.1).opacity(0.8),  // Тамна ивица
                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.8),  // Светла ивица
                            Color(red: 0.6, green: 0.4, blue: 0.1).opacity(0.8)   // Тамна ивица
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 8
                )
                .frame(width: circleSize, height: circleSize)
            
            // Текстура новчића
            Circle()
                .stroke(
                    Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.3),
                    lineWidth: 1
                )
                .frame(width: circleSize * 0.9, height: circleSize * 0.9)
            
            // Унутрашњи прстен
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.1),
                            Color(red: 1.0, green: 0.85, blue: 0.4),
                            Color(red: 0.6, green: 0.4, blue: 0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
                .frame(width: circleSize * 0.7, height: circleSize * 0.7)
            
            // Икона
            Image(systemName: screen.icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.1),  // Тамније злато
                            Color(red: 0.85, green: 0.6, blue: 0.2)   // Светлије злато
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.3), radius: 1, x: 1, y: 1)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
        // Суптилнија 3D ротација
        .rotation3DEffect(.degrees(15), axis: (x: 0, y: 0.5, z: 0))
    }
    
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
                    .fill(currentTab == index ? tutorialScreens[index].color : Color.gray.opacity(0.3))
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
            iconSection(screen)
                .frame(width: circleSize, height: circleSize)
            
            VStack(spacing: verticalSpacing) {
                Text(screen.title)
                    .font(.title.bold())
                    .foregroundColor(Theme.Colors.primaryGold)
                    .multilineTextAlignment(.center)
                
                Text(screen.subtitle)
                    .font(.title2)
                    .foregroundColor(screen.subtitleColor)
                    .multilineTextAlignment(.center)
                
                Text(screen.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    TutorialView(startGame: .constant(false))
} 
