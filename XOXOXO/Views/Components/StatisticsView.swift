import SwiftUI

struct StatisticsView: View {
    // Основна статистика
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    let totalMoves: Int
    
    // Детаљна статистика по играчу
    let playerStats: (x: GameLogic.PlayerStats, o: GameLogic.PlayerStats)
    
    // Акција за ресетовање статистике
    let onResetStatistics: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showResetConfirmation = false
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isPortrait: Bool {
        verticalSizeClass == .regular
    }
    
    // Нова функција за рачунање Win Rate-а тренутне игре
    private func calculateCurrentWinRate(score: Int, totalScore: Int) -> Double {
        guard totalScore > 0 else { return 0.0 }
        return Double(score) / Double(totalScore) * 100.0
    }
    
    var body: some View {
        Group {
            if isPortrait {
                VStack(spacing: isCompact ? 20 : 30) {
                    // Основна статистика
                    HStack(spacing: isCompact ? 20 : 30) {
                        // Плави играч (X)
                        PlayerStatsColumn(
                            symbol: "X",
                            stats: playerStats.x,
                            time: playerXTime,
                            score: score.x,
                            totalScore: score.x + score.o,
                            color: Theme.Colors.primaryBlue,
                            currentMoves: totalMoves
                        )
                        
                        // Вертикална линија
                        Rectangle()
                            .fill(Theme.Colors.metalGray.opacity(0.3))
                            .frame(width: 1)
                            .padding(.vertical, 10)
                        
                        // Црвени играч (O)
                        PlayerStatsColumn(
                            symbol: "O",
                            stats: playerStats.o,
                            time: playerOTime,
                            score: score.o,
                            totalScore: score.x + score.o,
                            color: Theme.Colors.primaryOrange,
                            currentMoves: totalMoves
                        )
                    }
                    
                    // Dugme za resetovanje statistike
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        SoundManager.shared.playHaptic()
                        showResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Statistics")
                        }
                        .font(Theme.TextStyle.subtitle(size: isCompact ? 16 : 18))
                        .foregroundColor(Theme.Colors.primaryGold)
                        .frame(width: isCompact ? 250 : 300)
                        .padding(.vertical, isCompact ? 12 : 15)
                        .glowingBorder(color: Theme.Colors.primaryGold)
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                    .alert("Reset Statistics", isPresented: $showResetConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Reset", role: .destructive) {
                            onResetStatistics()
                        }
                    } message: {
                        Text("Are you sure you want to reset all statistics? This action cannot be undone.")
                    }
                }
            } else {
                HStack(spacing: isCompact ? 20 : 30) {
                    // Плави играч (X)
                    PlayerStatsColumn(
                        symbol: "X",
                        stats: playerStats.x,
                        time: playerXTime,
                        score: score.x,
                        totalScore: score.x + score.o,
                        color: Theme.Colors.primaryBlue,
                        currentMoves: totalMoves
                    )
                    
                    // Вертикална линија
                    Rectangle()
                        .fill(Theme.Colors.metalGray.opacity(0.3))
                        .frame(width: 1)
                        .padding(.vertical, 10)
                    
                    // Црвени играч (O)
                    PlayerStatsColumn(
                        symbol: "O",
                        stats: playerStats.o,
                        time: playerOTime,
                        score: score.o,
                        totalScore: score.x + score.o,
                        color: Theme.Colors.primaryOrange,
                        currentMoves: totalMoves
                    )
                }
            }
        }
        .padding(.vertical, isCompact ? 10 : 15)
        .padding(.horizontal, isCompact ? 15 : 25)
        .background(
            ZStack {
                // Основни градијент
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.Colors.darkGradient)
                
                // Горње светло
                Circle()
                    .fill(Theme.Colors.primaryGold)
                    .frame(width: 100, height: 100)
                    .offset(y: -50)
                    .blur(radius: 70)
                    .opacity(0.1)
                
                // Лево светло
                Circle()
                    .fill(Theme.Colors.primaryBlue)
                    .frame(width: 80, height: 80)
                    .offset(x: -40)
                    .blur(radius: 60)
                    .opacity(0.08)
                
                // Десно светло
                Circle()
                    .fill(Theme.Colors.primaryOrange)
                    .frame(width: 80, height: 80)
                    .offset(x: 40)
                    .blur(radius: 60)
                    .opacity(0.08)
            }
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
    }
}

// Нова подкомпонента за приказ статистике играча
private struct PlayerStatsColumn: View {
    let symbol: String
    let stats: GameLogic.PlayerStats
    let time: TimeInterval
    let score: Int
    let totalScore: Int
    let color: Color
    let currentMoves: Int
    
    private func calculateCurrentWinRate() -> Double {
        guard totalScore > 0 else { return 0.0 }
        return Double(score) / Double(totalScore) * 100.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Симбол и резултат
            Text(symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text("\(score)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            // Време
            StatBox(
                title: "Time",
                value: formatGameTime(time),
                color: color
            )
            
            // Win Rate
            StatBox(
                title: "Win Rate",
                value: String(format: "%.1f%%", stats.winRate),
                color: color,
                subtitle: String(format: "Current: %.1f%%", calculateCurrentWinRate())
            )
            
            // Просечно време по потезу
            StatBox(
                title: "Avg Move",
                value: formatMoveTime(stats.averageMoveTime),
                color: color
            )
            
            // Укупно потеза
            StatBox(
                title: "Moves",
                value: "\(stats.totalMoves)",
                color: color,
                subtitle: "Current: \(stats.totalMoves - (stats.totalGames * 5))"
            )
        }
    }
    
    private func formatGameTime(_ time: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(time) / 60, Int(time) % 60)
    }
    
    private func formatMoveTime(_ time: TimeInterval) -> String {
        if time == .infinity || time == 0 {
            return "0.0s"
        }
        return String(format: "%.1fs", time)
    }
}

private struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    var subtitle: String? = nil
    var isScore: Bool = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(Theme.TextStyle.body(size: 12))
                .foregroundColor(Theme.Colors.metalGray)
            Text(value)
                .font(Theme.TextStyle.subtitle(size: isScore ? (isCompact ? 32 : 40) : (isCompact ? 24 : 30)))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 5)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Theme.TextStyle.body(size: 10))
                    .foregroundColor(Theme.Colors.metalGray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

#Preview("Statistics View - Portrait") {
    StatisticsView(
        playerXTime: 120,        // 2 минута
        playerOTime: 180,        // 3 минута
        score: (x: 3, o: 5),
        totalMoves: 8,
        playerStats: (
            x: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 6,
                totalMoves: 42,
                averageMoveTime: 1.2,
                totalMoveTime: 360
            ),
            o: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 4,
                totalMoves: 38,
                averageMoveTime: 1.5,
                totalMoveTime: 420
            )
        ),
        onResetStatistics: {}
    )
}

#Preview("Statistics View - Landscape") {
    StatisticsView(
        playerXTime: 120,        // 2 минута
        playerOTime: 180,        // 3 минута
        score: (x: 3, o: 5),
        totalMoves: 8,
        playerStats: (
            x: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 6,
                totalMoves: 42,
                averageMoveTime: 1.2,
                totalMoveTime: 360
            ),
            o: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 4,
                totalMoves: 38,
                averageMoveTime: 1.5,
                totalMoveTime: 420
            )
        ),
        onResetStatistics: {}
    )
    .background(Theme.Colors.darkGradient)
    .environment(\.horizontalSizeClass, .regular)
} 