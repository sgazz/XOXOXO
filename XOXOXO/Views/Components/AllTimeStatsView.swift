import SwiftUI

enum StatsCategory: String, CaseIterable {
    case human = "Human"
    case ai = "AI"
    case multiplayer = "Multiplayer"
}

struct AllTimeStatsView: View {
    let stats: GameLogic.PlayerStats
    let onClose: () -> Void
    let onReset: () -> Void
    
    @State private var selectedCategory: StatsCategory = .human
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var spacing: CGFloat {
        isCompact ? 15 : 20
    }
    
    private var padding: CGFloat {
        isCompact ? 15 : 25
    }
    
    private var titleFontSize: CGFloat {
        isCompact ? 32 : 38
    }
    
    private var subtitleFontSize: CGFloat {
        isCompact ? 16 : 18
    }
    
    private var bodyFontSize: CGFloat {
        isCompact ? 14 : 16
    }
    
    private var buttonWidth: CGFloat {
        isCompact ? 250 : 300
    }
    
    private var buttonVerticalPadding: CGFloat {
        isCompact ? 12 : 15
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadina koja prekriva ceo ekran
                Theme.Colors.darkGradient
                    .overlay(
                        ZStack {
                            // Горње светло
                            Circle()
                                .fill(Theme.Colors.primaryGold)
                                .frame(width: geometry.size.width * 1.5)
                                .offset(y: -geometry.size.height * 0.8)
                                .blur(radius: 100)
                                .opacity(0.3)
                            
                            // Лево светло
                            Circle()
                                .fill(Theme.Colors.primaryBlue)
                                .frame(width: geometry.size.width)
                                .offset(x: -geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                                .blur(radius: 100)
                                .opacity(0.2)
                            
                            // Десно светло
                            Circle()
                                .fill(Theme.Colors.primaryOrange)
                                .frame(width: geometry.size.width)
                                .offset(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                                .blur(radius: 100)
                                .opacity(0.2)
                        }
                    )
                    .ignoresSafeArea()
                
                // Glavni sadržaj
                ScrollView {
                    VStack(spacing: spacing) {
                        // Naslov
                        Text("All Time Stats")
                            .font(Theme.TextStyle.title(size: titleFontSize))
                            .foregroundColor(Theme.Colors.primaryGold)
                            .padding(.top, isLandscape ? 10 : 20)
                        
                        // Segmented Control sa poboljšanim stilom
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(StatsCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, padding)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Theme.Colors.primaryGold.opacity(0.3),
                                            Theme.Colors.primaryGold.opacity(0.1),
                                            Theme.Colors.primaryGold.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        
                        // Kategorizovani prikaz statistike
                        VStack(spacing: spacing) {
                            switch selectedCategory {
                            case .human:
                                HumanStatsView(stats: stats)
                            case .ai:
                                AIStatsView(stats: stats)
                            case .multiplayer:
                                MultiplayerStatsView(stats: stats)
                            }
                        }
                        .padding(.horizontal, padding)
                        
                        // Dugmad
                        if isLandscape {
                            HStack(spacing: spacing) {
                                statsButtons
                            }
                        } else {
                            VStack(spacing: spacing) {
                                statsButtons
                            }
                        }
                    }
                    .padding(.vertical, padding)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
                .shadow(color: Theme.Colors.primaryGold.opacity(0.15), radius: 15)
                .padding(padding)
            }
        }
    }
    
    private var statsButtons: some View {
        Group {
            Button(action: onReset) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset Stats")
                }
                .font(Theme.TextStyle.subtitle(size: subtitleFontSize))
                .foregroundColor(Theme.Colors.primaryGold)
                .frame(width: buttonWidth)
                .padding(.vertical, buttonVerticalPadding)
                .glowingBorder(color: Theme.Colors.primaryGold)
            }
            .buttonStyle(Theme.MetallicButtonStyle())
            
            Button(action: onClose) {
                HStack {
                    Image(systemName: "xmark")
                    Text("Close")
                }
                .font(Theme.TextStyle.subtitle(size: subtitleFontSize))
                .foregroundColor(Theme.Colors.primaryGold)
                .frame(width: buttonWidth)
                .padding(.vertical, buttonVerticalPadding)
                .glowingBorder(color: Theme.Colors.primaryGold)
            }
            .buttonStyle(Theme.MetallicButtonStyle())
        }
    }
}

struct HumanStatsView: View {
    let stats: GameLogic.PlayerStats
    
    var body: some View {
        VStack(spacing: 15) {
            // Osnovna statistika
            StatsSection(title: "Basic Stats") {
                StatsRow(title: "Total Games", value: "\(stats.totalGames)")
                StatsRow(title: "Win Rate", value: String(format: "%.1f%%", stats.winRate))
                StatsRow(title: "Average Move Time", value: String(format: "%.1fs", stats.averageMoveTime))
                StatsRow(title: "Fastest Move", value: String(format: "%.1fs", stats.fastestMove))
            }
            
            // Poziciona statistika
            StatsSection(title: "Position Stats") {
                StatsRow(title: "Center Moves", value: "\(stats.centerMoves)")
                StatsRow(title: "Corner Moves", value: "\(stats.cornerMoves)")
                StatsRow(title: "Edge Moves", value: "\(stats.edgeMoves)")
            }
            
            // Statistika pobeda po pozicijama
            StatsSection(title: "Position Wins") {
                StatsRow(title: "Center Wins", value: "\(stats.centerWins)")
                StatsRow(title: "Corner Wins", value: "\(stats.cornerWins)")
                StatsRow(title: "Edge Wins", value: "\(stats.edgeWins)")
            }
            
            // Statistika nizova
            StatsSection(title: "Streak Stats") {
                StatsRow(title: "Current Win Streak", value: "\(stats.currentWinStreak)")
                StatsRow(title: "Longest Win Streak", value: "\(stats.longestWinStreak)")
                StatsRow(title: "Comeback Wins", value: "\(stats.comebackWins)")
            }
        }
    }
}

struct AIStatsView: View {
    let stats: GameLogic.PlayerStats
    
    var body: some View {
        VStack(spacing: 15) {
            // Statistika protiv AI
            StatsSection(title: "AI Performance") {
                StatsRow(title: "Games vs AI", value: "\(stats.vsAIGames)")
                StatsRow(title: "AI Wins", value: "\(stats.aiWins)")
                StatsRow(title: "AI Losses", value: "\(stats.aiLosses)")
                StatsRow(title: "AI Draws", value: "\(stats.aiDraws)")
                StatsRow(title: "Win Rate vs AI", value: String(format: "%.1f%%", stats.aiWinRate))
            }
            
            // AI специфична статистика
            StatsSection(title: "AI Strategy") {
                StatsRow(title: "Blocked Wins", value: "\(stats.blockedWins)")
                StatsRow(title: "Winning Moves", value: "\(stats.winningMoves)")
            }
        }
    }
}

struct MultiplayerStatsView: View {
    let stats: GameLogic.PlayerStats
    
    var body: some View {
        VStack(spacing: 15) {
            // Statistika multiplayer igara
            StatsSection(title: "Multiplayer Performance") {
                StatsRow(title: "Multiplayer Games", value: "\(stats.vsPlayerGames)")
                StatsRow(title: "Multiplayer Wins", value: "\(stats.multiplayerWins)")
                StatsRow(title: "Multiplayer Losses", value: "\(stats.multiplayerLosses)")
                StatsRow(title: "Multiplayer Draws", value: "\(stats.multiplayerDraws)")
            }
            
            // Multiplayer специфична статистика
            StatsSection(title: "Multiplayer Streaks") {
                StatsRow(title: "Current Win Streak", value: "\(stats.multiplayerWinStreak)")
                StatsRow(title: "Longest Win Streak", value: "\(stats.multiplayerLongestStreak)")
            }
        }
    }
}

struct StatsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var subtitleFontSize: CGFloat {
        isCompact ? 16 : 18
    }
    
    private var padding: CGFloat {
        isCompact ? 15 : 25
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.TextStyle.subtitle(size: subtitleFontSize))
                .foregroundColor(Theme.Colors.primaryGold)
                .padding(.horizontal, padding)
            
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Theme.Colors.primaryGold.opacity(0.3),
                            Theme.Colors.primaryGold.opacity(0.1),
                            Theme.Colors.primaryGold.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct StatsRow: View {
    let title: String
    let value: String
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular || (horizontalSizeClass == .compact && verticalSizeClass == .compact)
    }
    
    private var bodyFontSize: CGFloat {
        isCompact ? 14 : 16
    }
    
    private var subtitleFontSize: CGFloat {
        isCompact ? 16 : 18
    }
    
    private var padding: CGFloat {
        isCompact ? 15 : 25
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.TextStyle.body(size: bodyFontSize))
                .foregroundColor(Theme.Colors.metalGray)
            
            Spacer()
            
            Text(value)
                .font(Theme.TextStyle.subtitle(size: subtitleFontSize))
                .foregroundColor(Theme.Colors.primaryGold)
        }
        .padding(.horizontal, padding)
        .padding(.vertical, 8)
    }
}

#Preview {
    AllTimeStatsView(
        stats: GameLogic.PlayerStats(),
        onClose: {},
        onReset: {}
    )
    .preferredColorScheme(.dark)
} 