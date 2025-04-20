import SwiftUI

struct ResultView: View {
    let playerXScore: Int
    let playerOScore: Int
    let draws: Int
    let onNewGame: () -> Void
    let onClose: () -> Void
    let isPvPUnlocked: Bool
    let onShowPurchase: () -> Void
    let onPlayVsPlayer: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let useVerticalLayout = deviceLayout.optimalStackOrientation(for: geometry)
            
            VStack(spacing: deviceLayout.adaptiveSpacing) {
                // Title
                Text("Results")
                    .font(.system(size: deviceLayout.titleSize * 0.8, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, Color(red: 0.4, green: 0.8, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Main content
                if useVerticalLayout {
                    VStack(spacing: deviceLayout.adaptiveSpacing) {
                        scoreContent
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack(spacing: deviceLayout.adaptiveSpacing * 2) {
                        scoreContent
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Buttons
                VStack(spacing: deviceLayout.adaptiveSpacing) {
                    Button(action: onNewGame) {
                        Text("Single Player")
                            .font(.system(size: deviceLayout.subtitleSize * 0.8, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, Color(red: 0.4, green: 0.8, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        if isPvPUnlocked {
                            onPlayVsPlayer()
                        } else {
                            onShowPurchase()
                        }
                    }) {
                        Text("Multiplayer")
                            .font(.system(size: deviceLayout.subtitleSize * 0.8, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: isPvPUnlocked ? 
                                        [Color(red: 0.3, green: 0.7, blue: 0.3), Color(red: 0.4, green: 0.8, blue: 0.4)] :
                                        [Color(red: 0.7, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.4, blue: 0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: onClose) {
                        Text("Close")
                            .font(.system(size: deviceLayout.subtitleSize * 0.8, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.5), Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    }
                }
                .padding(.top, deviceLayout.adaptiveSpacing)
            }
            .padding(deviceLayout.gridPadding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .frame(
                width: min(geometry.size.width * 0.8, 400),
                height: min(geometry.size.height * 0.7, 500)
            )
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
    }
    
    private var scoreContent: some View {
        Group {
            scoreCard(title: "Player X", score: playerXScore, color: .blue)
            scoreCard(title: "Player O", score: playerOScore, color: .red)
            scoreCard(title: "Draws", score: draws, color: .gray)
        }
    }
    
    private func scoreCard(title: String, score: Int, color: Color) -> some View {
        VStack(spacing: deviceLayout.adaptiveSpacing / 2) {
            Text(title)
                .font(.system(size: deviceLayout.subtitleSize * 0.8, weight: .medium))
                .foregroundColor(.primary)
            
            Text("\(score)")
                .font(.system(size: deviceLayout.titleSize * 0.8, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(deviceLayout.gridPadding)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(
            color: color.opacity(0.1),
            radius: 10,
            x: 0,
            y: 5
        )
    }
} 