import SwiftUI

struct AllTimeStatsView: View {
    let playerStats: [(x: GameLogic.PlayerStats, o: GameLogic.PlayerStats)]
    let onReset: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        onClose()
                    }
                
                // Main content
                VStack(spacing: 20) {
                    // Title section
                    VStack(spacing: 10) {
                        Text("All Time Statistics")
                            .font(Theme.TextStyle.title(size: 32))
                            .foregroundColor(Theme.Colors.primaryGold)
                            .padding(.top, 20)
                        
                        Text("Detailed player performance metrics")
                            .font(Theme.TextStyle.body(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 10)
                    
                    // Scrollable content
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 25) {
                            // Headers
                            HStack(spacing: 0) {
                                Text("Player X")
                                    .font(Theme.TextStyle.subtitle(size: 24))
                                    .foregroundColor(Theme.Colors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                
                                Text("Statistics")
                                    .font(Theme.TextStyle.subtitle(size: 24))
                                    .foregroundColor(Theme.Colors.primaryGold)
                                    .frame(maxWidth: .infinity)
                                
                                Text("Player O")
                                    .font(Theme.TextStyle.subtitle(size: 24))
                                    .foregroundColor(Theme.Colors.primaryOrange)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.bottom, 10)
                            
                            // Game Statistics
                            statsRow(
                                title: "Total Games",
                                xValue: "\(playerStats[0].x.totalGames)",
                                oValue: "\(playerStats[0].o.totalGames)"
                            )
                            
                            statsRow(
                                title: "Games Won",
                                xValue: "\(playerStats[0].x.gamesWon)",
                                oValue: "\(playerStats[0].o.gamesWon)"
                            )
                            
                            statsRow(
                                title: "Win Rate",
                                xValue: String(format: "%.1f%%", playerStats[0].x.winRate),
                                oValue: String(format: "%.1f%%", playerStats[0].o.winRate)
                            )
                            
                            statsRow(
                                title: "Games Lost",
                                xValue: "\(playerStats[0].x.gamesLost)",
                                oValue: "\(playerStats[0].o.gamesLost)"
                            )
                            
                            statsRow(
                                title: "Games Drawn",
                                xValue: "\(playerStats[0].x.gamesDrawn)",
                                oValue: "\(playerStats[0].o.gamesDrawn)"
                            )
                            
                            Divider()
                                .background(Theme.Colors.primaryGold.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            // Versus Statistics
                            statsRow(
                                title: "vs AI",
                                xValue: "\(playerStats[0].x.vsAIGames)",
                                oValue: "\(playerStats[0].o.vsAIGames)"
                            )
                            
                            statsRow(
                                title: "vs Player",
                                xValue: "\(playerStats[0].x.vsPlayerGames)",
                                oValue: "\(playerStats[0].o.vsPlayerGames)"
                            )
                            
                            Divider()
                                .background(Theme.Colors.primaryGold.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            // Time Statistics
                            statsRow(
                                title: "Total Game Time",
                                xValue: String(format: "%.1f min", playerStats[0].x.totalGameTime / 60),
                                oValue: String(format: "%.1f min", playerStats[0].o.totalGameTime / 60)
                            )
                            
                            statsRow(
                                title: "Average Game Time",
                                xValue: String(format: "%.1f min", playerStats[0].x.averageGameTime / 60),
                                oValue: String(format: "%.1f min", playerStats[0].o.averageGameTime / 60)
                            )
                            
                            statsRow(
                                title: "Fastest Win",
                                xValue: String(format: "%.1f sec", playerStats[0].x.fastestWin),
                                oValue: String(format: "%.1f sec", playerStats[0].o.fastestWin)
                            )
                            
                            Divider()
                                .background(Theme.Colors.primaryGold.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            // Move Statistics
                            statsRow(
                                title: "Total Moves",
                                xValue: "\(playerStats[0].x.totalMoves)",
                                oValue: "\(playerStats[0].o.totalMoves)"
                            )
                            
                            statsRow(
                                title: "Center Moves",
                                xValue: "\(playerStats[0].x.centerMoves)",
                                oValue: "\(playerStats[0].o.centerMoves)"
                            )
                            
                            statsRow(
                                title: "Corner Moves",
                                xValue: "\(playerStats[0].x.cornerMoves)",
                                oValue: "\(playerStats[0].o.cornerMoves)"
                            )
                            
                            statsRow(
                                title: "Center Move %",
                                xValue: String(format: "%.1f%%", playerStats[0].x.centerMovePercentage),
                                oValue: String(format: "%.1f%%", playerStats[0].o.centerMovePercentage)
                            )
                            
                            statsRow(
                                title: "Corner Move %",
                                xValue: String(format: "%.1f%%", playerStats[0].x.cornerMovePercentage),
                                oValue: String(format: "%.1f%%", playerStats[0].o.cornerMovePercentage)
                            )
                            
                            Divider()
                                .background(Theme.Colors.primaryGold.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            // Board Statistics
                            statsRow(
                                title: "Boards Won",
                                xValue: "\(playerStats[0].x.boardsWon)",
                                oValue: "\(playerStats[0].o.boardsWon)"
                            )
                            
                            statsRow(
                                title: "Total Boards",
                                xValue: "\(playerStats[0].x.totalBoards)",
                                oValue: "\(playerStats[0].o.totalBoards)"
                            )
                            
                            Divider()
                                .background(Theme.Colors.primaryGold.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            // Streaks and Bonuses
                            statsRow(
                                title: "Current Win Streak",
                                xValue: "\(playerStats[0].x.currentWinStreak)",
                                oValue: "\(playerStats[0].o.currentWinStreak)"
                            )
                            
                            statsRow(
                                title: "Best Win Streak",
                                xValue: "\(playerStats[0].x.longestWinStreak)",
                                oValue: "\(playerStats[0].o.longestWinStreak)"
                            )
                            
                            statsRow(
                                title: "Comeback Wins",
                                xValue: "\(playerStats[0].x.comebackWins)",
                                oValue: "\(playerStats[0].o.comebackWins)"
                            )
                            
                            statsRow(
                                title: "Bonus Points",
                                xValue: "\(playerStats[0].x.bonusCount)",
                                oValue: "\(playerStats[0].o.bonusCount)"
                            )
                            
                            statsRow(
                                title: "Penalty Points",
                                xValue: "\(playerStats[0].x.penaltyCount)",
                                oValue: "\(playerStats[0].o.penaltyCount)"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Buttons
                    HStack(spacing: 20) {
                        Button(action: onReset) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset All Time Stats")
                            }
                            .font(Theme.TextStyle.body(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                        
                        Button(action: onClose) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Back")
                            }
                            .font(Theme.TextStyle.body(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: min(geometry.size.width * 0.9, 800))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.Colors.darkGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.Colors.primaryGold.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Theme.Colors.primaryGold.opacity(0.3), radius: 10)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func statsRow(title: String, xValue: String, oValue: String) -> some View {
        HStack(spacing: 0) {
            Text(xValue)
                .font(Theme.TextStyle.body(size: 16))
                .foregroundColor(Theme.Colors.primaryBlue)
                .frame(maxWidth: .infinity)
            
            Text(title)
                .font(Theme.TextStyle.body(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
            
            Text(oValue)
                .font(Theme.TextStyle.body(size: 16))
                .foregroundColor(Theme.Colors.primaryOrange)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    AllTimeStatsView(
        playerStats: [(
            x: GameLogic.PlayerStats(),
            o: GameLogic.PlayerStats()
        )],
        onReset: {},
        onClose: {}
    )
    .preferredColorScheme(.dark)
} 