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
            description: "🎮 It's Tic-Tac-Toe like you've never seen before.\nPlay across 8 boards at once.\nPlan smart. Play fast.\nWin the tournament.",
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
            subtitle: "🔥 5 Minutes. 8 Boards. 1 Champion.",
            description: "⚡ Think fast.\n🎯 Play bold.\n👑 Master the multi-board arena and become the XO legend.",
            subtitleColor: Color(red: 0.3, green: 0.9, blue: 0.4)
        )
    ]
    
    // MARK: - Computed Properties
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var iconSize: CGFloat { isLandscape ? 45 : 70 }
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
                .fill(isSelected ? color : Color.gray.opacity(Constants.inactiveDotOpacity))
                .frame(width: Constants.dotSize, height: Constants.dotSize)
                .overlay(
                    Circle()
                        .stroke(
                            color.opacity(Constants.dotBorderOpacity),
                            lineWidth: isSelected ? Constants.dotBorderWidth : 0
                        )
                        .frame(width: Constants.dotBorderSize, height: Constants.dotBorderSize)
                )
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
                .padding(.horizontal)
            } else {
                VStack(spacing: Constants.defaultSpacing) {
                    iconSection(screen)
                    contentSection(screen)
                }
                .padding(.horizontal)
            }
        }
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
            titleView(screen)
            subtitleView(screen)
            descriptionView(screen)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(screen.title), \(screen.subtitle)")
        .accessibilityValue(screen.description)
    }
    
    private func titleView(_ screen: TutorialScreen) -> some View {
        Text(screen.title)
            .font(.title)
            .dynamicTypeSize(isLandscape ? .large : .xxxLarge)
            .foregroundColor(screen.color)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }
    
    private func subtitleView(_ screen: TutorialScreen) -> some View {
        Text(screen.subtitle)
            .font(.title2)
            .dynamicTypeSize(isLandscape ? .medium : .large)
            .foregroundColor(screen.subtitleColor)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }
    
    private func descriptionView(_ screen: TutorialScreen) -> some View {
        Text(screen.description)
            .font(.body)
            .dynamicTypeSize(isLandscape ? .small : .medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
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
