import SwiftUI

public struct FloatingSymbol: View {
    public let symbol: String
    public let size: CGFloat
    public let animationDuration: Double
    @State private var offset: CGSize
    @State private var rotation: Double
    
    public init(symbol: String, size: CGFloat, startX: CGFloat, startY: CGFloat, slowMotion: Bool = false) {
        self.symbol = symbol
        self.size = size
        let randomOffset = CGSize(
            width: startX + CGFloat.random(in: -30...30),
            height: startY + CGFloat.random(in: -30...30)
        )
        _offset = State(initialValue: randomOffset)
        _rotation = State(initialValue: Double.random(in: -15...15))
        // Спорија анимација за GameView ако је slowMotion = true
        self.animationDuration = slowMotion ? Double.random(in: 15...25) : Double.random(in: 8...12)
    }
    
    public var body: some View {
        Text(symbol)
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .foregroundColor(.white.opacity(0.3))
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .blur(radius: 10)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(
                        width: -offset.width * 0.5,
                        height: -offset.height * 0.5
                    )
                    rotation = -rotation * 0.5
                }
            }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        FloatingSymbol(symbol: "X", size: 100, startX: 100, startY: 100)
    }
} 