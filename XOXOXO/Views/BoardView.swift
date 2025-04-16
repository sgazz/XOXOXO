import SwiftUI

struct BoardView: View {
    @Binding var board: [String]
    var isActive: Bool
    var onTap: (Int) -> Void
    
    @State private var cellAnimations: [Bool] = Array(repeating: false, count: 9)
    @State private var isWinning = false
    @State private var winningCombination: [Int] = []
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let symbols = ["", "X", "O"]
    private let gridSize: CGFloat = 3
    private let spacing: CGFloat = 2
    
    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width / 3.5 - spacing * 2) / gridSize
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<3) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<3) { column in
                        let index = row * 3 + column
                        CellView(
                            symbol: board[index],
                            isActive: isActive && board[index].isEmpty,
                            isAnimating: cellAnimations[index],
                            isWinningCell: winningCombination.contains(index)
                        )
                        .frame(width: cellSize, height: cellSize)
                        .onTapGesture {
                            if isActive && board[index].isEmpty {
                                // Звучни ефекат при тапу
                                SoundManager.shared.playSound(.tap)
                                SoundManager.shared.playLightHaptic()
                                
                                withAnimation(.spring(dampingFraction: 0.7)) {
                                    cellAnimations[index] = true
                                }
                                
                                // Позивање онТап колбека
                                onTap(index)
                                
                                // Ресетовање анимације
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    cellAnimations[index] = false
                                }
                            } else if !board[index].isEmpty {
                                // Звук грешке ако је ћелија већ заузета
                                SoundManager.shared.playSound(.error)
                            }
                        }
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? 
                      Color(.systemBackground) : 
                      Color(.systemGray6))
                .shadow(
                    color: isActive ? Color.blue.opacity(0.4) : Color.gray.opacity(0.3),
                    radius: isActive ? 10 : 5,
                    x: 0,
                    y: isActive ? 5 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isActive ? Color.blue.opacity(0.7) : Color.gray.opacity(0.6), 
                    lineWidth: isActive ? 3 : 2
                )
        )
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
        .onChange(of: board) { oldValue, newValue in
            checkWinningCombination(in: newValue)
        }
    }
    
    private func checkWinningCombination(in board: [String]) {
        // Проверавамо хоризонталне, вертикалне и дијагоналне комбинације
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],  // хоризонтално
            [0, 3, 6], [1, 4, 7], [2, 5, 8],  // вертикално
            [0, 4, 8], [2, 4, 6]              // дијагонално
        ]
        
        for pattern in winPatterns {
            let symbols = pattern.map { board[$0] }
            if symbols[0] != "" && symbols[0] == symbols[1] && symbols[1] == symbols[2] {
                withAnimation(.spring()) {
                    isWinning = true
                    winningCombination = pattern
                }
                SoundManager.shared.playSound(.win)
                SoundManager.shared.playHeavyHaptic()
                break
            }
        }
    }
}

struct CellView: View {
    let symbol: String
    let isActive: Bool
    let isAnimating: Bool
    let isWinningCell: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cellBackground: Color {
        if isWinningCell {
            return Color.green.opacity(0.2)
        } else if isActive {
            return Color.blue.opacity(0.1)
        } else {
            return colorScheme == .dark ? 
                   Color(.systemBackground) : 
                   Color(.systemGray5).opacity(0.7)
        }
    }
    
    private var cellBorder: Color {
        if isWinningCell {
            return Color.green.opacity(0.7)
        } else if isActive {
            return Color.blue.opacity(0.5)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellBackground)
                .cornerRadius(4)
                .overlay(
                    Rectangle()
                        .stroke(cellBorder, lineWidth: 1.5)
                        .cornerRadius(4)
                )
            
            if symbol == "X" {
                XView()
                    .stroke(isWinningCell ? Color.green : Color.blue, lineWidth: 3)
                    .frame(width: min(30, UIScreen.main.bounds.width / 16), height: min(30, UIScreen.main.bounds.width / 16))
                    .shadow(color: (isWinningCell ? Color.green : Color.blue).opacity(0.5), radius: isWinningCell ? 6 : 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            } else if symbol == "O" {
                OView()
                    .stroke(isWinningCell ? Color.green : Color.red, lineWidth: 3)
                    .frame(width: min(30, UIScreen.main.bounds.width / 16), height: min(30, UIScreen.main.bounds.width / 16))
                    .shadow(color: (isWinningCell ? Color.green : Color.red).opacity(0.5), radius: isWinningCell ? 6 : 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            }
        }
        .scaleEffect(isWinningCell ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isWinningCell)
    }
}

struct XView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Цртамо X
        let width = rect.width
        let height = rect.height
        
        // Прва линија (горњи леви до доњи десни)
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        
        // Друга линија (доњи леви до горњи десни)
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        
        return path
    }
}

struct OView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Цртамо O (круг)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        
        return path
    }
}

#Preview {
    BoardView(
        board: .constant(Array(repeating: "", count: 9)),
        isActive: true,
        onTap: { _ in }
    )
    .padding()
} 