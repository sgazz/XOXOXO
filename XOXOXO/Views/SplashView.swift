import SwiftUI

struct FloatingSymbol: View {
    let symbol: String
    let size: CGFloat
    @State private var offset: CGSize
    @State private var rotation: Double
    let animationDuration: Double
    
    init(symbol: String, size: CGFloat, startX: CGFloat, startY: CGFloat) {
        self.symbol = symbol
        self.size = size
        let randomOffset = CGSize(
            width: startX + CGFloat.random(in: -30...30),
            height: startY + CGFloat.random(in: -30...30)
        )
        _offset = State(initialValue: randomOffset)
        _rotation = State(initialValue: Double.random(in: -15...15))
        self.animationDuration = Double.random(in: 8...12)
    }
    
    var body: some View {
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

struct SplashView: View {
    @State private var isActive = false
    @State private var titleOffset = CGSize(width: -600, height: 0)
    @State private var titleRotation: Double = -30
    @State private var backgroundOpacity = 0.0
    @State private var showTapPrompt = false
    @State private var showTutorial = false
    
    // Анимација прелаза
    @State private var startGameTransition = false
    
    var body: some View {
        ZStack {
            if startGameTransition {
                GameView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale),
                        removal: .opacity
                    ))
            } else {
                GeometryReader { geometry in
                    ZStack {
                        // Modern gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.2, blue: 0.45), // Deep blue
                                Color(red: 0.2, green: 0.3, blue: 0.7),  // Medium blue
                                Color(red: 0.3, green: 0.4, blue: 0.9)   // Light blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(backgroundOpacity)
                        .ignoresSafeArea()
                        
                        // Floating symbols with specific starting positions
                        Group {
                            // Left side symbols
                            FloatingSymbol(symbol: "X", size: 120, startX: -geometry.size.width * 0.4, startY: -geometry.size.height * 0.3)
                            FloatingSymbol(symbol: "O", size: 140, startX: -geometry.size.width * 0.35, startY: geometry.size.height * 0.3)
                            
                            // Right side symbols
                            FloatingSymbol(symbol: "X", size: 100, startX: geometry.size.width * 0.4, startY: -geometry.size.height * 0.25)
                            FloatingSymbol(symbol: "O", size: 110, startX: geometry.size.width * 0.35, startY: geometry.size.height * 0.25)
                            
                            // Center area symbols (further apart)
                            FloatingSymbol(symbol: "X", size: 90, startX: geometry.size.width * 0.15, startY: -geometry.size.height * 0.1)
                            FloatingSymbol(symbol: "O", size: 130, startX: -geometry.size.width * 0.15, startY: geometry.size.height * 0.1)
                        }
                        .opacity(backgroundOpacity)
                        
                        VStack {
                            Spacer()
                            
                            // Title
                            Text("XO Tournament")
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                .offset(titleOffset)
                                .rotationEffect(.degrees(titleRotation))
                                .padding(.bottom, 50)
                            
                            if showTapPrompt {
                                // Start Game button
                                Button(action: {
                                    SoundManager.shared.playSound(.tap)
                                    SoundManager.shared.playHaptic()
                                    
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        startGameTransition = true
                                    }
                                    
                                    // Мала одгода пре стварне промене стања
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.isActive = true
                                    }
                                }) {
                                    Text("Start Game")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 50)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 0.3, green: 0.4, blue: 0.9),
                                                            Color(red: 0.2, green: 0.3, blue: 0.7)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.5), radius: 10, x: 0, y: 5)
                                        )
                                }
                                .scaleEffect(1.0)
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            Spacer()
                            
                            // "How to Play" button
                            if showTapPrompt {
                                Button(action: {
                                    SoundManager.shared.playSound(.tap)
                                    SoundManager.shared.playLightHaptic()
                                    self.showTutorial = true
                                }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 18))
                                        Text("How to Play?")
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                }
                                .padding(.bottom, 30)
                                .transition(.opacity)
                            }
                        }
                    }
                    .onAppear {
                        // Background animation
                        withAnimation(.easeOut(duration: 0.8)) {
                            backgroundOpacity = 1.0
                        }
                        
                        // Title animation
                        withAnimation(
                            .spring(
                                response: 0.8,
                                dampingFraction: 0.6,
                                blendDuration: 0
                            )
                        ) {
                            titleOffset = .zero
                            titleRotation = 0
                        }
                        
                        // Show tap prompt after title animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showTapPrompt = true
                            }
                        }
                    }
                    .sheet(isPresented: $showTutorial) {
                        TutorialView()
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 