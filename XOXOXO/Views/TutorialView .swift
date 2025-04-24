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
    private struct TutorialScreen: Codable {
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let description: String
        let subtitleColor: Color
        
        enum CodingKeys: String, CodingKey {
            case icon
            case color
            case title
            case subtitle
            case description
            case subtitleColor
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            icon = try container.decode(String.self, forKey: .icon)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decode(String.self, forKey: .subtitle)
            description = try container.decode(String.self, forKey: .description)
            
            // Dekodiranje Color vrednosti iz hex stringa
            let colorHex = try container.decode(String.self, forKey: .color)
            let subtitleColorHex = try container.decode(String.self, forKey: .subtitleColor)
            
            color = Color(hex: colorHex) ?? .blue
            subtitleColor = Color(hex: subtitleColorHex) ?? .blue
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(icon, forKey: .icon)
            try container.encode(title, forKey: .title)
            try container.encode(subtitle, forKey: .subtitle)
            try container.encode(description, forKey: .description)
            
            // Kodiranje Color vrednosti u hex string
            try container.encode(color.toHex() ?? "#0000FF", forKey: .color)
            try container.encode(subtitleColor.toHex() ?? "#0000FF", forKey: .subtitleColor)
        }
        
        // Standardni inicijalizator za trenutnu upotrebu
        init(icon: String, color: Color, title: String, subtitle: String, description: String, subtitleColor: Color) {
            self.icon = icon
            self.color = color
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.subtitleColor = subtitleColor
        }
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
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Металик позадина
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.2, blue: 0.22),
                        Color(red: 0.15, green: 0.15, blue: 0.17),
                        Color(red: 0.1, green: 0.1, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    // Металик текстура
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Додатни сјај на врху
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
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
                    .onChange(of: currentTab) { oldValue, newValue in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Tutorial content")
                    .accessibilityValue("Page \(currentTab + 1) of \(tutorialScreens.count)")
                    
                    // Page indicator
                    pageIndicator
                }
            }
            .accessibilityAction(named: "Next page") {
                if currentTab < tutorialScreens.count - 1 {
                    withAnimation {
                        currentTab += 1
                    }
                }
            }
            .accessibilityAction(named: "Previous page") {
                if currentTab > 0 {
                    withAnimation {
                        currentTab -= 1
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Views
    private struct PageDot: View {
        let index: Int
        let isSelected: Bool
        let color: Color
        let onTap: () -> Void
        
        var body: some View {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            isSelected ? color : Color.gray.opacity(0.6),
                            isSelected ? color.opacity(0.8) : Color.gray.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Constants.dotSize, height: Constants.dotSize)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? Constants.dotBorderWidth : 0
                        )
                        .frame(width: Constants.dotBorderSize, height: Constants.dotBorderSize)
                )
                .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4)
                .shadow(color: .white.opacity(0.2), radius: 1, x: 0, y: -1)
                .scaleEffect(isSelected ? Constants.activeDotScale : 1.0)
                .animation(.spring(), value: isSelected)
                .onTapGesture {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    onTap()
                }
                .accessibilityLabel("Page \(index + 1)")
                .accessibilityValue(isSelected ? "Selected" : "")
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                .accessibilityHint("Double tap to go to page \(index + 1)")
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: Constants.dotSpacing) {
            ForEach(0..<tutorialScreens.count, id: \.self) { index in
                PageDot(
                    index: index,
                    isSelected: index == currentTab,
                    color: tutorialScreens[index].color,
                    onTap: {
                        withAnimation {
                            currentTab = index
                        }
                    }
                )
            }
        }
        .padding(.bottom, isLandscape ? Constants.compactSpacing : Constants.defaultSpacing)
        .padding(.top, isLandscape ? -50 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Page indicator")
    }
    
    private func tutorialCard(for index: Int, in geometry: GeometryProxy) -> some View {
        let screen = tutorialScreens[index]
        
        return Group {
            if isLandscape {
                HStack(spacing: Constants.cardHorizontalSpacing) {
                    iconSection(screen)
                        .frame(width: geometry.size.width * Constants.landscapeIconWidth)
                    contentSection(screen)
                        .frame(width: geometry.size.width * Constants.landscapeContentWidth)
                }
                .frame(height: Constants.cardHeight * 0.6)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.25, blue: 0.27),
                                    Color(red: 0.2, green: 0.2, blue: 0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Constants.goldGradient, lineWidth: Constants.goldBorderWidth)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                        .shadow(color: .white.opacity(0.2), radius: 1, x: 0, y: -1)
                )
            } else {
                VStack(spacing: Constants.defaultSpacing) {
                    iconSection(screen)
                    contentSection(screen)
                }
                .frame(height: Constants.cardHeight)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.25, blue: 0.27),
                                    Color(red: 0.2, green: 0.2, blue: 0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Constants.goldGradient, lineWidth: Constants.goldBorderWidth)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                        .shadow(color: .white.opacity(0.2), radius: 1, x: 0, y: -1)
                )
            }
        }
    }
    
    private func iconSection(_ screen: TutorialScreen) -> some View {
        ZStack {
            // Позадински круг са металик ефектом
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            screen.color.opacity(0.8),
                            screen.color.opacity(1.0),
                            screen.color.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    // Унутрашњи сјај
                    Circle()
                        .stroke(
                            Constants.goldGradient,
                            lineWidth: Constants.goldBorderWidth
                        )
                )
                .overlay(
                    // Додатни металик ефекат
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: screen.color.opacity(0.5), radius: 15)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: -2)
            
            // Спољашњи прстен
            Circle()
                .stroke(Constants.goldGradient, lineWidth: 3)
                .frame(width: outerCircleSize, height: outerCircleSize)
                .blur(radius: 0.5)
            
            // Икона
            Image(systemName: screen.icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.white.opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: screen.color.opacity(0.5), radius: 8)
                .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: -1)
        }
    }
    
    private func contentSection(_ screen: TutorialScreen) -> some View {
        VStack(spacing: verticalSpacing) {
            Text(screen.title)
                .font(.title.bold())
                .foregroundStyle(Constants.goldGradient)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 2)
            
            Text(screen.subtitle)
                .font(.title2)
                .foregroundColor(screen.subtitleColor)
                .multilineTextAlignment(.center)
                .shadow(color: screen.subtitleColor.opacity(0.3), radius: 2)
            
            Text(screen.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 1)
                .padding(.top)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(screen.title), \(screen.subtitle)")
        .accessibilityValue(screen.description)
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

#Preview {
    TutorialView(startGame: .constant(false))
} 
