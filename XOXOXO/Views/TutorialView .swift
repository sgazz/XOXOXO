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
            title: "Welcome to XO Tournament!",
            subtitle: "Classic Game, Revolutionary Experience!",
            description: "Discover an exciting strategic game that\n takes Tic-Tac-Toe to a whole new level!\n\nPlay on multiple boards simultaneously!\n\nOutsmart your opponent and become the tournament champion.",
            subtitleColor: Color(red: 0.3, green: 0.7, blue: 1.0)
        ),
        TutorialScreen(
            icon: "list.bullet",
            color: .purple,
            title: "Game-Changing Rules",
            subtitle: "More Boards, More Strategy!",
            description: "Win by connecting three identical symbols in a line - horizontally, vertically, or diagonally.\n\nBeware! Your move on one board determines where your opponent must play next.\n\nA masterful move can lead to victory or defeat!",
            subtitleColor: Color(red: 0.8, green: 0.4, blue: 1.0)
        ),
        TutorialScreen(
            icon: "brain.head.profile",
            color: .orange,
            title: "Dual Challenge",
            subtitle: "Choose Your Path to Victory!",
            description: "🤖 PvAI Mode:\nTest your skills against our advanced AI opponent that learns and adapts to your playing style.\n\n👥 PvP Mode:\nChallenge a friend to a duel and prove who's the better strategist in local multiplayer.",
            subtitleColor: Color(red: 1.0, green: 0.6, blue: 0.2)
        ),
        TutorialScreen(
            icon: "flag.checkered",
            color: .green,
            title: "Ready for the Challenge?",
            subtitle: "Time to Become a Champion!",
            description: "Explore new strategies!\n\nPerfect your skills!\n\nBecome a master of multi-board tactics.\n\nAre you ready to experience the most exciting version \nof Tic-Tac-Toe ever?",
            subtitleColor: Color(red: 0.3, green: 0.9, blue: 0.4)
        )
    ]
    
    // MARK: - Computed Properties
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var iconSize: CGFloat { isLandscape ? 45 : 70 }
    private var titleSize: CGFloat { isLandscape ? 24 : 28 }
    private var subtitleSize: CGFloat { isLandscape ? 18 : 20 }
    private var bodySize: CGFloat { isLandscape ? 15 : 17 }
    private var circleSize: CGFloat { isLandscape ? 100 : 160 }
    private var outerCircleSize: CGFloat { isLandscape ? 120 : 180 }
    private var verticalSpacing: CGFloat { isLandscape ? Constants.compactSpacing : Constants.defaultSpacing }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                tutorialScreens[currentTab].color
                    .opacity(Constants.backgroundOpacity)
                    .background(.ultraThinMaterial.opacity(Constants.materialOpacity))
                    .ignoresSafeArea()
                
                VStack(spacing: verticalSpacing) {
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
                    pageIndicator
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Views
    private var pageIndicator: some View {
        return HStack(spacing: Constants.dotSpacing) {
            ForEach(0..<tutorialScreens.count, id: \.self) { index in
                Circle()
                    .fill(index == currentTab ? 
                          tutorialScreens[index].color : 
                          Color.gray.opacity(Constants.inactiveDotOpacity))
                    .frame(width: Constants.dotSize, height: Constants.dotSize)
                    .overlay(
                        Circle()
                            .stroke(
                                tutorialScreens[index].color.opacity(Constants.dotBorderOpacity),
                                lineWidth: index == currentTab ? Constants.dotBorderWidth : 0
                            )
                            .frame(width: Constants.dotBorderSize, height: Constants.dotBorderSize)
                    )
                    .scaleEffect(index == currentTab ? Constants.activeDotScale : 1.0)
                    .animation(.spring(), value: currentTab)
                    .onTapGesture {
                        withAnimation {
                            currentTab = index
                        }
                    }
            }
        }
        .padding(.bottom, isLandscape ? Constants.compactSpacing : Constants.defaultSpacing)
        .padding(.top, isLandscape ? -50 : 0)
    }
    
    private func tutorialCard(for index: Int, in geometry: GeometryProxy) -> some View {
        let screen = tutorialScreens[index]
        
        return AnyView(
            Group {
                if isLandscape {
                    HStack(spacing: Constants.cardHorizontalSpacing) {
                        iconSection(screen)
                            .frame(width: geometry.size.width * Constants.landscapeIconWidth)
                        
                        contentSection(screen)
                            .frame(width: geometry.size.width * Constants.landscapeContentWidth)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: Constants.defaultSpacing) {
                        iconSection(screen)
                        contentSection(screen)
                    }
                    .padding(.horizontal)
                }
            }
        )
    }
    
    private func iconSection(_ screen: TutorialScreen) -> some View {
        Image(systemName: screen.icon)
            .font(.system(size: iconSize))
            .foregroundColor(screen.color)
            .padding(isLandscape ? Constants.defaultSpacing : Constants.defaultSpacing * 2)
            .background(
                ZStack {
                    Circle()
                        .fill(screen.color.opacity(Constants.backgroundOpacity))
                        .frame(width: circleSize, height: circleSize)
                    
                    Circle()
                        .stroke(screen.color.opacity(Constants.backgroundOpacity), lineWidth: 2)
                        .frame(width: outerCircleSize, height: outerCircleSize)
                }
            )
    }
    
    private func contentSection(_ screen: TutorialScreen) -> some View {
        VStack(spacing: verticalSpacing) {
            Text(screen.title)
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(screen.color)
                .multilineTextAlignment(.center)
            
            Text(screen.subtitle)
                .font(.system(size: subtitleSize, weight: .semibold))
                .foregroundColor(screen.subtitleColor)
                .multilineTextAlignment(.center)
            
            Text(screen.description)
                .font(.system(size: bodySize))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    TutorialView(startGame: .constant(false))
} 
