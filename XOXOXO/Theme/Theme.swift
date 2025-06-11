import SwiftUI

enum Theme {
    enum Colors {
        // Primary colors
        static let primaryGold = Color(red: 1.0, green: 0.84, blue: 0.0)
        static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
        static let primaryOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let primaryBronze = Color(red: 0.8, green: 0.5, blue: 0.2)
        static let primaryGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
        
        // Background colors
        static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.1)    // #1A1A1A
        static let darkGradient = LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.15, green: 0.15, blue: 0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Metal colors
        static let metalGray = Color(red: 0.7, green: 0.7, blue: 0.7)
        
        // Gradient combinations
        static let goldGradient = LinearGradient(
            colors: [primaryGold, primaryGold.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let blueGradient = LinearGradient(
            colors: [primaryBlue, primaryBlue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let orangeGradient = LinearGradient(
            colors: [primaryOrange, primaryOrange.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Glow effects
        static let goldGlow = primaryGold.opacity(0.3)
        static let blueGlow = primaryBlue.opacity(0.3)
        static let orangeGlow = primaryOrange.opacity(0.3)
    }
    
    enum TextStyle {
        static func title(size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func subtitle(size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        static func body(size: CGFloat) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
    }
    
    struct MetallicButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    struct GlowingBorder: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.6),
                                    color.opacity(0.2),
                                    color.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: color.opacity(0.3), radius: 10)
        }
    }
}

extension View {
    func glowingBorder(color: Color) -> some View {
        modifier(Theme.GlowingBorder(color: color))
    }
} 