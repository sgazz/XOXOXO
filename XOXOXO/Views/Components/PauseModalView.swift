import SwiftUI

struct PauseModalView: View {
    let onGo: () -> Void
    let onRestart: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Замућена позадина са градијентом и светлима
                ZStack {
                    // Основни тамни градијент
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.05, blue: 0.1),  // Скоро црна
                            Color(red: 0.1, green: 0.1, blue: 0.2)     // Тамно плава
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Лево плаво светло
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.primaryBlue.opacity(0.3),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: 100,
                        endRadius: 400
                    )
                    
                    // Десно наранџасто светло
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.primaryOrange.opacity(0.3),
                            Color.clear
                        ]),
                        center: .topTrailing,
                        startRadius: 100,
                        endRadius: 400
                    )
                    
                    // Централнално златно светло (суптилно)
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.primaryGold.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                }
                .opacity(0.7)
                .ignoresSafeArea()
                
                // Модални прозор
                VStack(spacing: geometry.size.height * 0.025) {
                    // Title
                    Text("PAUSE")
                        .font(Theme.TextStyle.title(size: min(geometry.size.width * 0.12, 48)))
                        .foregroundColor(Theme.Colors.primaryOrange)
                        .shadow(color: Theme.Colors.primaryOrange.opacity(0.5), radius: 10)
                        .shadow(color: Theme.Colors.primaryOrange.opacity(0.3), radius: 20)
                        .scaleEffect(1.1)
                    
                    // Buttons
                    VStack(spacing: geometry.size.height * 0.018) {
                        // Go! button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            onGo()
                        }) {
                            HStack(spacing: geometry.size.width * 0.04) {
                                Image(systemName: "play.fill")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.08, 32)))
                                Text("Go!")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.08, 32)))
                            }
                            .foregroundColor(Theme.Colors.primaryGold)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .padding(.vertical, geometry.size.height * 0.025)
                            .glowingBorder(color: Theme.Colors.primaryGold)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                        
                        // Restart button
                        Button(action: {
                            SoundManager.shared.playSound(.tap)
                            onRestart()
                        }) {
                            HStack(spacing: geometry.size.width * 0.04) {
                                Image(systemName: "arrow.clockwise")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.08, 32)))
                                Text("Choose Game Mode")
                                    .font(Theme.TextStyle.subtitle(size: min(geometry.size.width * 0.08, 32)))
                            }
                            .foregroundColor(Theme.Colors.primaryBronze)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .padding(.vertical, geometry.size.height * 0.025)
                            .glowingBorder(color: Theme.Colors.primaryBronze)
                        }
                        .buttonStyle(Theme.MetallicButtonStyle())
                    }
                    .padding(.top, geometry.size.height * 0.03)
                }
                .padding(geometry.size.width * 0.07)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Theme.Colors.darkGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Theme.Colors.primaryGold.opacity(0.6),
                                            Theme.Colors.primaryGold.opacity(0.2),
                                            Theme.Colors.primaryGold.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Theme.Colors.primaryGold.opacity(0.3), radius: 20)
                )
                .frame(maxWidth: min(geometry.size.width * 0.95, 600))
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

#Preview {
    PauseModalView(
        onGo: {},
        onRestart: {}
    )
} 
