import SwiftUI

struct StatisticsView: View {
    // Osnovna statistika
    let playerXTime: TimeInterval
    let playerOTime: TimeInterval
    let score: (x: Int, o: Int)
    let totalMoves: Int
    
    // Detaljna statistika po igraču
    let playerStats: (x: GameLogic.PlayerStats, o: GameLogic.PlayerStats)
    
    // Akcija za resetovanje statistike
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
    
    var body: some View {
        Group {
            if isPortrait {
                VStack(spacing: isCompact ? 20 : 30) {
                    // Osnovna statistika
                    HStack(spacing: isCompact ? 20 : 30) {
                        // Plavi igrač (X)
                        PlayerStatsColumn(
                            symbol: "X",
                            stats: playerStats.x,
                            time: playerXTime,
                            score: score.x,
                            totalScore: score.x + score.o,
                            color: Theme.Colors.primaryBlue,
                            currentMoves: totalMoves
                        )
                        
                        // Vertikalna linija
                        Rectangle()
                            .fill(Theme.Colors.metalGray.opacity(0.3))
                            .frame(width: 1)
                            .padding(.vertical, 10)
                        
                        // Crveni igrač (O)
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
                        Text("Reset Statistics")
                            .font(Theme.TextStyle.body(size: 16))
                            .foregroundColor(Theme.Colors.metalGray)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.Colors.metalGray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .alert("Reset Statistics", isPresented: $showResetConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            onResetStatistics()
                        }
                    } message: {
                        Text("Are you sure you want to reset all statistics? This cannot be undone.")
                    }
                }
            } else {
                HStack(spacing: isCompact ? 20 : 30) {
                    // Plavi igrač (X)
                    PlayerStatsColumn(
                        symbol: "X",
                        stats: playerStats.x,
                        time: playerXTime,
                        score: score.x,
                        totalScore: score.x + score.o,
                        color: Theme.Colors.primaryBlue,
                        currentMoves: totalMoves
                    )
                    
                    // Vertikalna linija
                    Rectangle()
                        .fill(Theme.Colors.metalGray.opacity(0.3))
                        .frame(width: 1)
                        .padding(.vertical, 10)
                    
                    // Crveni igrač (O)
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
    }
}

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
            // Simbol i rezultat
            Text(symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text("\(score)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            // Vreme
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
            
            // Prosečno vreme po potezu
            StatBox(
                title: "Avg Move",
                value: formatMoveTime(stats.averageMoveTime),
                color: color
            )
            
            // Strategijska statistika
            StatBox(
                title: "Strategy",
                value: "C:\(stats.centerMoves) E:\(stats.edgeMoves)",
                color: color,
                subtitle: "Corners: \(stats.cornerMoves)"
            )
            
            // Nizovi
            StatBox(
                title: "Best Streak",
                value: "\(stats.longestWinStreak)",
                color: color
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1),
                            color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview("Statistics View - Portrait") {
    StatisticsView(
        playerXTime: 120,
        playerOTime: 180,
        score: (x: 3, o: 5),
        totalMoves: 8,
        playerStats: (
            x: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 6,
                totalMoves: 42,
                averageMoveTime: 1.2,
                centerMoves: 5,
                cornerMoves: 8,
                edgeMoves: 3,
                longestWinStreak: 4
            ),
            o: GameLogic.PlayerStats(
                totalGames: 10,
                gamesWon: 4,
                totalMoves: 38,
                averageMoveTime: 1.5,
                centerMoves: 4,
                cornerMoves: 7,
                edgeMoves: 4,
                longestWinStreak: 3
            )
        ),
        onResetStatistics: {}
    )
} 
