import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var startGame: Bool
    @State private var currentTab = 0
    
    // Дефинисање складних боја за сваки екран
    private let backgroundColors: [Color] = [
        Color(red: 0.0, green: 0.40, blue: 0.85).opacity(0.1),  // Плава за први екран
        Color(red: 0.55, green: 0.20, blue: 0.85).opacity(0.1), // Љубичаста за други екран
        Color(red: 0.95, green: 0.50, blue: 0.10).opacity(0.1), // Наранџаста за трећи екран
        Color(red: 0.20, green: 0.75, blue: 0.30).opacity(0.1)  // Зелена за четврти екран
    ]
    
    // Боје за индикаторе страница
    private let dotColors: [Color] = [
        Color(red: 0.0, green: 0.40, blue: 0.85),  // Плава за први екран
        Color(red: 0.55, green: 0.20, blue: 0.85), // Љубичаста за други екран
        Color(red: 0.95, green: 0.50, blue: 0.10), // Наранџаста за трећи екран
        Color(red: 0.20, green: 0.75, blue: 0.30)  // Зелена за четврти екран
    ]
    
    var body: some View {
        ZStack {
            // Background blur effect and gradient color
            backgroundColors[currentTab]
                .background(
                    .ultraThinMaterial.opacity(0.8)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue.opacity(0.3)).frame(width: 36, height: 36))
                    }
                    .padding()
                }
                
                // Tutorial content
                TabView(selection: $currentTab) {
                    // First card - Welcome
                    VStack(spacing: 20) {
                        // Game controller icon with glow effect
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                            .padding(40)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 160, height: 160)
                                    
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 180, height: 180)
                                        .blur(radius: 10)
                                }
                            )
                            .padding(.top, 40)
                        
                        // Title
                        Text("Welcome to XO Tournament!")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        // Subtitle
                        Text("Where classic meets challenge!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 1)
                        
                        // Description
                        Text("Play the classic Tic-Tac-Toe game in a completely new way. Compete against AI on multiple boards simultaneously!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                            .padding(.top, 30)
                        
                        Spacer()
                    }
                    .tag(0)
                    .transition(.opacity)
                    
                    // Second card - Game Rules
                    VStack(spacing: 20) {
                        // List icon with glow effect
                        Image(systemName: "list.bullet")
                            .font(.system(size: 70))
                            .foregroundColor(.purple)
                            .padding(40)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.2))
                                        .frame(width: 160, height: 160)
                                    
                                    Circle()
                                        .fill(Color.purple.opacity(0.1))
                                        .frame(width: 180, height: 180)
                                        .blur(radius: 10)
                                }
                            )
                            .padding(.top, 40)
                        
                        // Title
                        Text("Game Rules")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        // Description
                        Text("Win by connecting three identical symbols in a line - horizontally, vertically, or diagonally. But watch out, the AI will try to stop you!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                            .padding(.top, 30)
                        
                        Spacer()
                    }
                    .tag(1)
                    .transition(.opacity)
                    
                    // Third card - Strategy
                    VStack(spacing: 20) {
                        // Brain icon with glow effect
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                            .padding(40)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 160, height: 160)
                                    
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 180, height: 180)
                                        .blur(radius: 10)
                                }
                            )
                            .padding(.top, 40)
                        
                        // Title
                        Text("Strategy")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        // Description
                        Text("Think ahead! Each move on one board can affect your strategy on other boards.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                            .padding(.top, 30)
                        
                        Spacer()
                    }
                    .tag(2)
                    .transition(.opacity)
                    
                    // Fourth card - Ready to Play
                    VStack(spacing: 20) {
                        // Flag icon with glow effect
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                            .padding(40)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 160, height: 160)
                                    
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 180, height: 180)
                                        .blur(radius: 10)
                                }
                            )
                            .padding(.top, 40)
                        
                        // Title
                        Text("Ready to Play?")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        // Subtitle
                        Text("Think you're a champion? Prove it in this Tournament!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 1)
                            .padding(.horizontal, 30)
                        
                        // Description
                        Text("Challenge yourself against our AI and see if you can master the multi-board strategy!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        // Accept the Challenge button
                        Button(action: {
                            startGame = true
                            dismiss()
                        }) {
                            Text("Accept the Challenge!")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 30)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                                )
                        }
                        .padding(.bottom, 40)
                    }
                    .tag(3)
                    .transition(.opacity)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Сакријемо подразумеване индикаторе
                .animation(.easeInOut, value: currentTab)
                
                // Прилагођени индикатор страница
                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentTab ? dotColors[index] : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(dotColors[index].opacity(0.5), lineWidth: index == currentTab ? 2 : 0)
                                    .frame(width: 14, height: 14)
                            )
                            .scaleEffect(index == currentTab ? 1.2 : 1.0)
                            .animation(.spring(), value: currentTab)
                            .onTapGesture {
                                withAnimation {
                                    currentTab = index
                                }
                            }
                    }
                }
                .padding(.bottom, 20)
                
                // Add padding at the bottom for consistency
                Rectangle()
                    .frame(height: 0)
                    .padding(.bottom, 20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeInOut(duration: 0.3), value: currentTab)
    }
}

struct TutorialCard: View {
    let title: String
    let description: String
    let image: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Image(systemName: image)
                .font(.system(size: 70))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 0)
                .padding()
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 150, height: 150)
                )
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                        .frame(width: 150, height: 150)
                )
            
            // Text content
            VStack(spacing: 15) {
                Text(title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: 300)
        }
        .padding(.horizontal)
    }
} 