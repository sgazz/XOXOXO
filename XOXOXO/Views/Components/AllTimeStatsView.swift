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
                                Text(category.rawValue)
                                    .foregroundColor(Theme.Colors.primaryGold)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: min(geometry.size.width * 0.8, 400))
                        .padding(.horizontal)
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
                DualStatsRow(
                    title: "Total Games",
                    xValue: "\(stats.humanAsXGames)",
                    oValue: "\(stats.humanAsOGames)"
                )
                DualStatsRow(
                    title: "Games Won",
                    xValue: "\(stats.humanAsXWins)",
                    oValue: "\(stats.humanAsOWins)"
                )
                DualStatsRow(
                    title: "Win Rate",
                    xValue: String(format: "%.1f%%", stats.humanAsXGames > 0 ? Double(stats.humanAsXWins) / Double(stats.humanAsXGames) * 100 : 0),
                    oValue: String(format: "%.1f%%", stats.humanAsOGames > 0 ? Double(stats.humanAsOWins) / Double(stats.humanAsOGames) * 100 : 0)
                )
                DualStatsRow(
                    title: "Average Move Time",
                    xValue: String(format: "%.1fs", stats.humanAsXTotalMoves > 0 ? stats.totalMoveTime / Double(stats.humanAsXTotalMoves) : 0),
                    oValue: String(format: "%.1fs", stats.humanAsOTotalMoves > 0 ? stats.totalMoveTime / Double(stats.humanAsOTotalMoves) : 0)
                )
                DualStatsRow(
                    title: "Fastest Move",
                    xValue: String(format: "%.1fs", stats.humanAsXFastestMove),
                    oValue: String(format: "%.1fs", stats.humanAsOFastestMove)
                )
            }
            
            // Vremenska statistika
            StatsSection(title: "Time Stats") {
                DualStatsRow(
                    title: "Fastest Win vs AI",
                    xValue: String(format: "%.1fs", stats.humanAsXFastestWin),
                    oValue: String(format: "%.1fs", stats.humanAsOFastestWin)
                )
                DualStatsRow(
                    title: "Longest Win vs AI",
                    xValue: String(format: "%.1fs", stats.humanAsXLongestWin),
                    oValue: String(format: "%.1fs", stats.humanAsOLongestWin)
                )
            }
            
            // Statistika broja poteza
            StatsSection(title: "Move Stats") {
                DualStatsRow(
                    title: "Total Moves",
                    xValue: "\(stats.humanAsXTotalMoves)",
                    oValue: "\(stats.humanAsOTotalMoves)"
                )
                DualStatsRow(
                    title: "Fastest Win (Moves)",
                    xValue: "\(stats.humanAsXFastestWinMoves)",
                    oValue: "\(stats.humanAsOFastestWinMoves)"
                )
                DualStatsRow(
                    title: "Longest Win (Moves)",
                    xValue: "\(stats.humanAsXLongestWinMoves)",
                    oValue: "\(stats.humanAsOLongestWinMoves)"
                )
            }
            
            // Poziciona statistika
            StatsSection(title: "Position Stats") {
                DualStatsRow(
                    title: "Center Moves",
                    xValue: "\(stats.humanAsXCenterMoves)",
                    oValue: "\(stats.humanAsOCenterMoves)"
                )
                DualStatsRow(
                    title: "Corner Moves",
                    xValue: "\(stats.humanAsXCornerMoves)",
                    oValue: "\(stats.humanAsOCornerMoves)"
                )
                DualStatsRow(
                    title: "Edge Moves",
                    xValue: "\(stats.humanAsXEdgeMoves)",
                    oValue: "\(stats.humanAsOEdgeMoves)"
                )
            }
            
            // Statistika pobeda po pozicijama
            StatsSection(title: "Position Wins") {
                DualStatsRow(
                    title: "Center Wins",
                    xValue: "\(stats.humanAsXCenterWins)",
                    oValue: "\(stats.humanAsOCenterWins)"
                )
                DualStatsRow(
                    title: "Corner Wins",
                    xValue: "\(stats.humanAsXCornerWins)",
                    oValue: "\(stats.humanAsOCornerWins)"
                )
                DualStatsRow(
                    title: "Edge Wins",
                    xValue: "\(stats.humanAsXEdgeWins)",
                    oValue: "\(stats.humanAsOEdgeWins)"
                )
            }
            
            // Statistika nizova
            StatsSection(title: "Streak Stats") {
                DualStatsRow(
                    title: "Current Win Streak",
                    xValue: "\(stats.humanAsXCurrentStreak)",
                    oValue: "\(stats.humanAsOCurrentStreak)"
                )
                DualStatsRow(
                    title: "Longest Win Streak",
                    xValue: "\(stats.humanAsXLongestStreak)",
                    oValue: "\(stats.humanAsOLongestStreak)"
                )
                DualStatsRow(
                    title: "Comeback Wins",
                    xValue: "\(stats.humanAsXComebackWins)",
                    oValue: "\(stats.humanAsOComebackWins)"
                )
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
                DualStatsRow(
                    title: "Games vs Human",
                    xValue: "\(stats.aiAsXGames)",
                    oValue: "\(stats.aiAsOGames)"
                )
                DualStatsRow(
                    title: "AI Wins",
                    xValue: "\(stats.aiAsXWins)",
                    oValue: "\(stats.aiAsOWins)"
                )
                DualStatsRow(
                    title: "AI Losses",
                    xValue: "\(stats.aiAsXLosses)",
                    oValue: "\(stats.aiAsOLosses)"
                )
                DualStatsRow(
                    title: "AI Draws",
                    xValue: "\(stats.aiAsXDraws)",
                    oValue: "\(stats.aiAsODraws)"
                )
                DualStatsRow(
                    title: "Win Rate vs Human",
                    xValue: String(format: "%.1f%%", stats.aiAsXGames > 0 ? Double(stats.aiAsXWins) / Double(stats.aiAsXGames) * 100 : 0),
                    oValue: String(format: "%.1f%%", stats.aiAsOGames > 0 ? Double(stats.aiAsOWins) / Double(stats.aiAsOGames) * 100 : 0)
                )
            }
            
            // Vremenska statistika protiv Human
            StatsSection(title: "AI Time Stats") {
                DualStatsRow(
                    title: "Fastest Win vs Human",
                    xValue: String(format: "%.1fs", stats.aiAsXFastestWin),
                    oValue: String(format: "%.1fs", stats.aiAsOFastestWin)
                )
                DualStatsRow(
                    title: "Longest Win vs Human",
                    xValue: String(format: "%.1fs", stats.aiAsXLongestWin),
                    oValue: String(format: "%.1fs", stats.aiAsOLongestWin)
                )
            }
            
            // Statistika broja poteza
            StatsSection(title: "AI Move Stats") {
                DualStatsRow(
                    title: "Total Moves",
                    xValue: "\(stats.aiAsXTotalMoves)",
                    oValue: "\(stats.aiAsOTotalMoves)"
                )
                DualStatsRow(
                    title: "Fastest Win (Moves)",
                    xValue: "\(stats.aiAsXFastestWinMoves)",
                    oValue: "\(stats.aiAsOFastestWinMoves)"
                )
                DualStatsRow(
                    title: "Longest Win (Moves)",
                    xValue: "\(stats.aiAsXLongestWinMoves)",
                    oValue: "\(stats.aiAsOLongestWinMoves)"
                )
            }
            
            // Poziciona statistika
            StatsSection(title: "AI Position Stats") {
                DualStatsRow(
                    title: "Center Moves",
                    xValue: "\(stats.aiAsXCenterMoves)",
                    oValue: "\(stats.aiAsOCenterMoves)"
                )
                DualStatsRow(
                    title: "Corner Moves",
                    xValue: "\(stats.aiAsXCornerMoves)",
                    oValue: "\(stats.aiAsOCornerMoves)"
                )
                DualStatsRow(
                    title: "Edge Moves",
                    xValue: "\(stats.aiAsXEdgeMoves)",
                    oValue: "\(stats.aiAsOEdgeMoves)"
                )
            }
            
            // Statistika pobeda po pozicijama
            StatsSection(title: "AI Position Wins") {
                DualStatsRow(
                    title: "Center Wins",
                    xValue: "\(stats.aiAsXCenterWins)",
                    oValue: "\(stats.aiAsOCenterWins)"
                )
                DualStatsRow(
                    title: "Corner Wins",
                    xValue: "\(stats.aiAsXCornerWins)",
                    oValue: "\(stats.aiAsOCornerWins)"
                )
                DualStatsRow(
                    title: "Edge Wins",
                    xValue: "\(stats.aiAsXEdgeWins)",
                    oValue: "\(stats.aiAsOEdgeWins)"
                )
            }
            
            // AI специфична статистика
            StatsSection(title: "AI Strategy") {
                DualStatsRow(
                    title: "Blocked Wins",
                    xValue: "\(stats.aiAsXBlockedWins)",
                    oValue: "\(stats.aiAsOBlockedWins)"
                )
                DualStatsRow(
                    title: "Winning Moves",
                    xValue: "\(stats.aiAsXWinningMoves)",
                    oValue: "\(stats.aiAsOWinningMoves)"
                )
            }
            
            // Statistika nizova
            StatsSection(title: "AI Streak Stats") {
                DualStatsRow(
                    title: "Current Win Streak",
                    xValue: "\(stats.aiAsXCurrentStreak)",
                    oValue: "\(stats.aiAsOCurrentStreak)"
                )
                DualStatsRow(
                    title: "Longest Win Streak",
                    xValue: "\(stats.aiAsXLongestStreak)",
                    oValue: "\(stats.aiAsOLongestStreak)"
                )
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
            
            // Vremenska statistika u multiplayer-u
            StatsSection(title: "Multiplayer Time Stats") {
                StatsRow(title: "Fastest Win", value: String(format: "%.1fs", stats.fastestWin))
                StatsRow(title: "Longest Win", value: String(format: "%.1fs", stats.longestWin))
            }
            
            // Statistika broja poteza u multiplayer-u
            StatsSection(title: "Multiplayer Move Stats") {
                StatsRow(title: "Fastest Win (Moves)", value: "\(stats.fastestWinMoves)")
                StatsRow(title: "Longest Win (Moves)", value: "\(stats.longestWinMoves)")
            }
            
            // Statistika nerešenih partija u multiplayer-u
            StatsSection(title: "Multiplayer Draw Stats") {
                StatsRow(title: "Most Draws in Game", value: "\(stats.mostDrawsInGame)")
                StatsRow(title: "Least Draws in Game", value: "\(stats.leastDrawsInGame)")
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

// Nova DualStatsRow komponenta
struct DualStatsRow: View {
    let title: String
    let xValue: String
    let oValue: String
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var bodyFontSize: CGFloat {
        isCompact ? 14 : 16
    }
    
    private var valueFontSize: CGFloat {
        isCompact ? 16 : 18
    }
    
    var body: some View {
        HStack {
            // X vrednost
            Text(xValue)
                .font(Theme.TextStyle.subtitle(size: valueFontSize))
                .foregroundColor(Theme.Colors.primaryBlue)
                .frame(width: 60, alignment: .trailing)
            
            // Naziv
            Text(title)
                .font(Theme.TextStyle.body(size: bodyFontSize))
                .foregroundColor(Theme.Colors.metalGray)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            // O vrednost
            Text(oValue)
                .font(Theme.TextStyle.subtitle(size: valueFontSize))
                .foregroundColor(Theme.Colors.primaryOrange)
                .frame(width: 60, alignment: .leading)
        }
        .padding(.horizontal)
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