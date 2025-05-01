import SwiftUI

struct StatisticsView: View {
    private struct StatBox: View {
        let title: String
        let value: String
        let color: Color
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
                    .accessibilityIdentifier("\(title.lowercased())Stat")
                Text(value)
                    .font(Theme.TextStyle.subtitle(size: isScore ? (isCompact ? 32 : 40) : (isCompact ? 24 : 30)))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.5), radius: 5)
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

    var body: some View {
        HStack(spacing: 8) {
            StatBox(title: "Time", value: "00:00", color: Theme.Colors.blue)
            StatBox(title: "Moves", value: "0", color: Theme.Colors.purple)
            StatBox(title: "Score", value: "0", color: Theme.Colors.green, isScore: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
} 