import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Binding var startGame: Bool
    @State private var currentTab = 0
    
    // Дефинисање складних боја за сваки екран
    private let backgroundColors: [Color] = [
        Color(red: 0.0, green: 0.40, blue: 0.85).opacity(0.1),  // Плава за први екран
        Color(red: 0.55, green: 0.20, blue: 0.85).opacity(0.1), // Љубичаста за други екран
        Color(red: 0.95, green: 0.50, blue: 0.10).opacity(0.1), // Наранџаста за трећи екран
        Color(red: 0.20, green: 0.75, blue: 0.30).opacity(0.1)  // Зелена за четврти екран
    ]
    
    // Боје за индикаторе страница
    private let dotColors: [Color] = [
        Color(red: 0.0, green: 0.40, blue: 0.85),  // Плава за први екран
        Color(red: 0.55, green: 0.20, blue: 0.85), // Љубичаста за други екран
        Color(red: 0.95, green: 0.50, blue: 0.10), // Наранџаста за трећи екран
        Color(red: 0.20, green: 0.75, blue: 0.30)  // Зелена за четврти екран
    ]
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var iconSize: CGFloat {
        isLandscape ? 45 : 70
    }
    
    private var titleSize: CGFloat {
        isLandscape ? 24 : 28
    }
    
    private var subtitleSize: CGFloat {
        isLandscape ? 18 : 20
    }
    
    private var bodySize: CGFloat {
        isLandscape ? 15 : 17
    }
    
    private var circleSize: CGFloat {
        isLandscape ? 100 : 160
    }
    
    private var outerCircleSize: CGFloat {
        isLandscape ? 120 : 180
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background blur effect and gradient color
                backgroundColors[currentTab]
                    .background(
                        .ultraThinMaterial.opacity(0.8)
                    )
                    .ignoresSafeArea()
                
                VStack(spacing: isLandscape ? 5 : 20) {
                    // Tutorial content
                    TabView(selection: $currentTab) {
                        ForEach(0..<4) { index in
                            tutorialCard(for: index, in: geometry)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentTab)
                    
                    // Прилагођени индикатор страница
                    HStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(index == currentTab ? dotColors[index] : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(dotColors[index].opacity(0.5), lineWidth: index == currentTab ? 2 : 0)
                                        .frame(width: 12, height: 12)
                                )
                                .scaleEffect(index == currentTab ? 1.2 : 1.0)
                                .animation(.spring(), value: currentTab)
                                .onTapGesture {
                                    withAnimation {
                                        currentTab = index
                                    }
                                }
                        }
                    }
                    .padding(.bottom, isLandscape ? 5 : 20)
                    .padding(.top, isLandscape ? -50 : 0)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func tutorialCard(for index: Int, in geometry: GeometryProxy) -> some View {
        Group {
            if isLandscape {
                // Landscape layout
                HStack(spacing: 20) {
                    // Icon section
                    iconSection(for: index)
                        .frame(width: geometry.size.width * 0.3)
                    
                    // Content section
                    contentSection(for: index)
                        .frame(width: geometry.size.width * 0.7)
                }
                .tag(index)
            } else {
                // Portrait layout
                VStack(spacing: 20) {
                    iconSection(for: index)
                    contentSection(for: index)
                }
                .tag(index)
            }
        }
        .padding(.horizontal)
    }
    
    private func iconSection(for index: Int) -> some View {
        // Icon with glow effect
        Group {
            switch index {
            case 0:
                tutorialIcon(systemName: "gamecontroller.fill", color: .blue)
            case 1:
                tutorialIcon(systemName: "list.bullet", color: .purple)
            case 2:
                tutorialIcon(systemName: "brain.head.profile", color: .orange)
            case 3:
                tutorialIcon(systemName: "flag.checkered", color: .green)
            default:
                EmptyView()
            }
        }
    }
    
    private func contentSection(for index: Int) -> some View {
        VStack(spacing: isLandscape ? 10 : 20) {
            // Title and content based on index
            Group {
                switch index {
                case 0:
                    tutorialContent(
                        title: "Welcome to XO Tournament!",
                        subtitle: "Where classic meets challenge!",
                        description: "Play the classic Tic-Tac-Toe game in a completely new way. Compete against AI on multiple boards simultaneously!"
                    )
                case 1:
                    tutorialContent(
                        title: "Game Rules",
                        description: "Win by connecting three identical symbols in a line - horizontally, vertically, or diagonally. But watch out, the AI will try to stop you!"
                    )
                case 2:
                    tutorialContent(
                        title: "Strategy",
                        description: "Think ahead! Each move on one board can affect your strategy on other boards."
                    )
                case 3:
                    tutorialContent(
                        title: "Ready to Play?",
                        subtitle: "Think you're a champion? Prove it in this Tournament!",
                        description: "Challenge yourself against our AI and see if you can master the multi-board strategy!",
                        showButton: true
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private func tutorialIcon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: iconSize))
            .foregroundColor(color)
            .padding(isLandscape ? 20 : 40)
            .background(
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: circleSize, height: circleSize)
                    
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: outerCircleSize, height: outerCircleSize)
                        .blur(radius: 10)
                }
            )
            .padding(.top, isLandscape ? 10 : 40)
    }
    
    private func tutorialContent(title: String, subtitle: String? = nil, description: String, showButton: Bool = false) -> some View {
        VStack(spacing: isLandscape ? 8 : 15) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
            }
            
            Text(description)
                .font(.system(size: bodySize))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, isLandscape ? 20 : 30)
                .padding(.top, isLandscape ? 5 : 20)
            
            if showButton {
                Button(action: {
                    startGame = true
                    dismiss()
                }) {
                    Text("Accept the Challenge!")
                        .font(.system(size: isLandscape ? 18 : 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, isLandscape ? 12 : 16)
                        .padding(.horizontal, isLandscape ? 25 : 30)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.top, isLandscape ? 10 : 20)
            }
        }
    }
}

#Preview {
    TutorialView(startGame: .constant(false))
} 