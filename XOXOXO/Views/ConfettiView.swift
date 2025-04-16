import SwiftUI

struct ConfettiView: View {
    @State private var isVisible = false
    @Binding var isActive: Bool
    
    private let confettiColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]
    
    private let confettiCount = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<confettiCount, id: \.self) { index in
                ConfettiPiece(
                    color: confettiColors[index % confettiColors.count],
                    position: randomPosition(),
                    size: randomSize(),
                    rotation: randomRotation(),
                    isVisible: $isVisible
                )
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startConfetti()
            }
        }
    }
    
    private func startConfetti() {
        isVisible = true
        
        // Сакријемо конфети после неколико секунди
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                isVisible = false
            }
        }
    }
    
    private func randomPosition() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: -50...UIScreen.main.bounds.width + 50),
            y: -100
        )
    }
    
    private func randomSize() -> CGFloat {
        CGFloat.random(in: 5...15)
    }
    
    private func randomRotation() -> Double {
        Double.random(in: 0...360)
    }
}

struct ConfettiPiece: View {
    let color: Color
    let position: CGPoint
    let size: CGFloat
    let rotation: Double
    
    @Binding var isVisible: Bool
    @State private var finalPosition: CGPoint
    @State private var finalRotation: Double
    
    init(color: Color, position: CGPoint, size: CGFloat, rotation: Double, isVisible: Binding<Bool>) {
        self.color = color
        self.position = position
        self.size = size
        self.rotation = rotation
        self._isVisible = isVisible
        
        // Финална позиција
        self._finalPosition = State(initialValue: CGPoint(
            x: position.x + CGFloat.random(in: -100...100),
            y: UIScreen.main.bounds.height + 100 + CGFloat.random(in: 0...300)
        ))
        
        // Финална ротација
        self._finalRotation = State(initialValue: rotation + Double.random(in: 180...720) * (Bool.random() ? 1 : -1))
    }
    
    var body: some View {
        let confettiShape = [Rectangle(), Circle(), Capsule()][Int.random(in: 0...2)]
        
        return confettiShape
            .foregroundColor(color)
            .frame(width: size, height: size * 1.5)
            .position(isVisible ? finalPosition : position)
            .rotationEffect(.degrees(isVisible ? finalRotation : rotation))
            .opacity(isVisible ? 1 : 0)
            .animation(
                Animation.timingCurve(0.1, 0.8, 0.2, 1, duration: 3)
                    .delay(Double.random(in: 0...0.5)),
                value: isVisible
            )
    }
} 