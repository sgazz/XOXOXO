import SwiftUI

struct BoardView: View {
    @Binding var board: [String]
    var isActive: Bool
    var onTap: (Int) -> Void
    
    @State private var cellAnimations: [Bool] = Array(repeating: false, count: 9)
    @State private var isWinning = false
    @State private var winningCombination: [Int] = []
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let symbols = ["", "X", "O"]
    private let gridSize: CGFloat = 3
    private let spacing: CGFloat = 4  // Смањен размак између ћелија
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = calculateCellSize(for: geometry.size)
            let totalWidth = cellSize * 3 + spacing * 2
            
            VStack(spacing: spacing) {
                ForEach(0..<3) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<3) { column in
                            let index = row * 3 + column
                            CellView(
                                symbol: board[index],
                                isActive: isActive && board[index].isEmpty,
                                isAnimating: cellAnimations[index],
                                isWinningCell: winningCombination.contains(index),
                                deviceLayout: deviceLayout
                            )
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                handleCellTap(at: index)
                            }
                        }
                    }
                }
            }
            .frame(width: totalWidth, height: totalWidth)
            .scaleEffect(isActive ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: board) { oldValue, newValue in
            checkWinningCombination(in: newValue)
        }
    }
    
    private func calculateCellSize(for size: CGSize) -> CGFloat {
        let minDimension = min(size.width, size.height)
        return (minDimension - spacing * 2) / gridSize
    }
    
    private func handleCellTap(at index: Int) {
        if isActive && board[index].isEmpty {
            SoundManager.shared.playSound(.tap)
            SoundManager.shared.playLightHaptic()
            
            withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 200, damping: 10)) {
                cellAnimations[index] = true
            }
            
            onTap(index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 200, damping: 10)) {
                    cellAnimations[index] = false
                }
            }
        } else if !board[index].isEmpty {
            SoundManager.shared.playSound(.error)
        }
    }
    
    private func checkWinningCombination(in board: [String]) {
        // Провери хоризонталне комбинације
        for row in 0..<3 {
            let start = row * 3
            if board[start] != "" && board[start] == board[start + 1] && board[start] == board[start + 2] {
                winningCombination = [start, start + 1, start + 2]
                isWinning = true
                return
            }
        }
        
        // Провери вертикалне комбинације
        for col in 0..<3 {
            if board[col] != "" && board[col] == board[col + 3] && board[col] == board[col + 6] {
                winningCombination = [col, col + 3, col + 6]
                isWinning = true
                return
            }
        }
        
        // Провери дијагонале
        if board[0] != "" && board[0] == board[4] && board[0] == board[8] {
            winningCombination = [0, 4, 8]
            isWinning = true
            return
        }
        
        if board[2] != "" && board[2] == board[4] && board[2] == board[6] {
            winningCombination = [2, 4, 6]
            isWinning = true
            return
        }
        
        // Ако нема победника, ресетуј стање
        winningCombination = []
        isWinning = false
    }
}

struct CellView: View {
    let symbol: String
    let isActive: Bool
    let isAnimating: Bool
    let isWinningCell: Bool
    let deviceLayout: DeviceLayout
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool {
        colorScheme == .dark
    }
    
    private var cellBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            isDark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white,
                            isDark ? Color(red: 0.2, green: 0.2, blue: 0.25) : Color.white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            if isActive {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.blue.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
    
    private var cellBorder: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(
                LinearGradient(
                    colors: isActive ? 
                        [Color.blue.opacity(1), Color.blue.opacity(0.6)] :
                        [Color.white.opacity(isDark ? 0.3 : 0.2), Color.white.opacity(isDark ? 0.1 : 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
    
    private var symbolSize: CGFloat {
        deviceLayout.gridPadding * 1.5
    }
    
    var body: some View {
        ZStack {
            cellBackground
            cellBorder
            
            if symbol == "X" {
                XView()
                    .stroke(
                        LinearGradient(
                            colors: isWinningCell ? 
                                [Color.green, Color.green.opacity(0.7)] :
                                [Color.blue, Color(red: 0.4, green: 0.8, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: deviceLayout.gridPadding * 0.25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: symbolSize, height: symbolSize)
                    .shadow(
                        color: (isWinningCell ? Color.green : Color.blue).opacity(0.3),
                        radius: isWinningCell ? 6 : 3
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(mass: 0.5, stiffness: 200, damping: 10), value: isAnimating)
            } else if symbol == "O" {
                OView()
                    .stroke(
                        LinearGradient(
                            colors: isWinningCell ? 
                                [Color.green, Color.green.opacity(0.7)] :
                                [Color.red, Color(red: 1.0, green: 0.4, blue: 0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: deviceLayout.gridPadding * 0.25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: symbolSize, height: symbolSize)
                    .shadow(
                        color: (isWinningCell ? Color.green : Color.red).opacity(0.3),
                        radius: isWinningCell ? 6 : 3
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(mass: 0.5, stiffness: 200, damping: 10), value: isAnimating)
            }
        }
        .shadow(
            color: Color.black.opacity(isDark ? 0.2 : 0.08),
            radius: 4,
            x: 0,
            y: 2
        )
        .scaleEffect(isWinningCell ? 1.1 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isWinningCell)
    }
}

struct XView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let padding: CGFloat = width * 0.2
        
        // Прва линија (горњи леви до доњи десни)
        path.move(to: CGPoint(x: padding, y: padding))
        path.addLine(to: CGPoint(x: width - padding, y: height - padding))
        
        // Друга линија (доњи леви до горњи десни)
        path.move(to: CGPoint(x: padding, y: height - padding))
        path.addLine(to: CGPoint(x: width - padding, y: padding))
        
        return path
    }
}

struct OView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.4
        
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