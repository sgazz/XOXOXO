import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Colors {
        // Primary Colors
        static let primaryGold = Color(red: 1.0, green: 0.85, blue: 0.0)      // #FFD700
        static let primaryBlue = Color(red: 0.0, green: 0.75, blue: 1.0)      // #00BFFF
        static let primaryOrange = Color(red: 1.0, green: 0.27, blue: 0.0)    // #FF4500
        static let primaryBronze = Color(red: 0.45, green: 0.65, blue: 0.35)  // #73A559 - метална зелено-бронзана
        
        // Background Colors
        static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.1)    // #1A1A1A
        static let metalGray = Color(red: 0.5, green: 0.5, blue: 0.5)         // #808080
        
        // Gradient Combinations
        static let blueOrangeGradient = LinearGradient(
            gradient: Gradient(colors: [primaryBlue, primaryOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let darkGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.12, green: 0.12, blue: 0.12),
                Color(red: 0.18, green: 0.18, blue: 0.18)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Glow Effects
        static func glowEffect(color: Color, radius: CGFloat = 10) -> some View {
            EmptyView()
                .shadow(color: color.opacity(0.5), radius: radius)
        }
    }
    
    // MARK: - Text Styles
    enum TextStyle {
        static func title(size: CGFloat = 40) -> Font {
            .system(size: size, weight: .heavy, design: .rounded)
        }
        
        static func subtitle(size: CGFloat = 24) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func body(size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
    }
    
    // MARK: - Button Styles
    struct MetallicButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Colors.darkGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Colors.primaryGold.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Colors.primaryGold.opacity(0.3), radius: 5)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    // MARK: - Common Modifiers
    struct GlowingBorder: ViewModifier {
        var color: Color
        var lineWidth: CGFloat = 2
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color, lineWidth: lineWidth)
                )
                .shadow(color: color.opacity(0.5), radius: 10)
        }
    }
}

// MARK: - View Extensions
extension View {
    func glowingBorder(color: Color, lineWidth: CGFloat = 2) -> some View {
        modifier(Theme.GlowingBorder(color: color, lineWidth: lineWidth))
    }
} 