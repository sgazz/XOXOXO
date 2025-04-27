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
            VStack(spacing: isIPad ? 20 : 15) {
                // Title
                Text("Pause")
                    .font(Theme.TextStyle.title(size: isIPad ? 32 : 24))
                    .foregroundColor(Theme.Colors.primaryOrange)
                    .shadow(color: Theme.Colors.primaryOrange.opacity(0.5), radius: 10)
                
                // Buttons
                VStack(spacing: isIPad ? 15 : 10) {
                    // Go! button
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onGo()
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "play.fill")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                            Text("Go!")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                        }
                        .foregroundColor(Theme.Colors.primaryGold)
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .glowingBorder(color: Theme.Colors.primaryGold)
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                    
                    // Restart button
                    Button(action: {
                        SoundManager.shared.playSound(.tap)
                        onRestart()
                    }) {
                        HStack(spacing: isIPad ? 20 : 15) {
                            Image(systemName: "arrow.clockwise")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                            Text("Restart")
                                .font(Theme.TextStyle.subtitle(size: isIPad ? 32 : 24))
                        }
                        .foregroundColor(Theme.Colors.primaryBronze)
                        .frame(maxWidth: isIPad ? 500 : 400)
                        .padding(.vertical, isIPad ? 20 : 15)
                        .glowingBorder(color: Theme.Colors.primaryBronze)
                    }
                    .buttonStyle(Theme.MetallicButtonStyle())
                }
                .padding(.top, isIPad ? 20 : 15)
            }
            .padding(isIPad ? 40 : 30)
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
            .frame(maxWidth: isIPad ? 600 : 450)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    PauseModalView(
        onGo: {},
        onRestart: {}
    )
} 
