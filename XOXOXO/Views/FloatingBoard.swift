import SwiftUI

struct FloatingBoard: View {
    let size: CGFloat
    let animationDuration: Double
    let slowMotion: Bool
    @State private var offset: CGSize
    @State private var rotation: Double
    
    init(size: CGFloat, startX: CGFloat, startY: CGFloat, slowMotion: Bool = false) {
        self.size = size
        self.slowMotion = slowMotion
        let randomOffset = CGSize(
            width: startX + CGFloat.random(in: -20...20),
            height: startY + CGFloat.random(in: -20...20)
        )
        _offset = State(initialValue: randomOffset)
        _rotation = State(initialValue: Double.random(in: -10...10))
        self.animationDuration = slowMotion ? Double.random(in: 35...45) : Double.random(in: 20...30)
    }
    
    var body: some View {
        boardView
            .frame(width: size, height: size)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .blur(radius: 4)
            .opacity(0.6)
            .shadow(color: .white.opacity(0.2), radius: 8)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .speed(slowMotion ? 0.7 : 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(
                        width: -offset.width * (slowMotion ? 0.3 : 0.5),
                        height: -offset.height * (slowMotion ? 0.3 : 0.5)
                    )
                    rotation = -rotation * (slowMotion ? 0.3 : 0.5)
                }
            }
    }
    
    private var boardView: some View {
        VStack(spacing: 2) {
            ForEach(0..<3) { row in
                HStack(spacing: 2) {
                    ForEach(0..<3) { column in
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    }
                }
            }
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.5), lineWidth: 2.5)
        )
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        FloatingBoard(size: 100, startX: 100, startY: 100)
    }
} 