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
    private let spacing: CGFloat = 2
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = calculateCellSize(for: geometry.size)
            
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
            .padding(deviceLayout.gridPadding)
            .background(
                RoundedRectangle(cornerRadius: deviceLayout.gridPadding * 2)
                    .fill(colorScheme == .dark ? 
                          Color(.systemBackground) : 
                          Color.white.opacity(0.8))
                    .shadow(
                        color: isActive ? Color.blue.opacity(0.6) : Color.black.opacity(0.2),
                        radius: isActive ? deviceLayout.gridPadding * 2 : deviceLayout.gridPadding,
                        x: 0,
                        y: isActive ? 5 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: deviceLayout.gridPadding * 2)
                    .stroke(
                        isActive ? Color.blue.opacity(0.8) : Color.gray.opacity(0.4), 
                        lineWidth: isActive ? 3 : 1
                    )
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: board) { oldValue, newValue in
            checkWinningCombination(in: newValue)
        }
    }
    
    private func calculateCellSize(for size: CGSize) -> CGFloat {
        let minDimension = min(size.width, size.height)
        let availableSpace = minDimension - (deviceLayout.gridPadding * 2)
        return (availableSpace - spacing * 2) / gridSize
    }
    
    private func handleCellTap(at index: Int) {
        if isActive && board[index].isEmpty {
            SoundManager.shared.playSound(.tap)
            SoundManager.shared.playLightHaptic()
            
            withAnimation(.spring(dampingFraction: 0.7)) {
                cellAnimations[index] = true
            }
            
            onTap(index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cellAnimations[index] = false
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
    
    private var cellBackground: Color {
        if isWinningCell {
            return .green.opacity(0.2)
        } else if isActive {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var cellBorder: Color {
        if isWinningCell {
            return .green.opacity(0.5)
        } else if isActive {
            return .blue.opacity(0.3)
        } else {
            return .gray.opacity(0.2)
        }
    }
    
    private var symbolSize: CGFloat {
        deviceLayout.gridPadding * 2
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellBackground)
                .cornerRadius(deviceLayout.gridPadding)
                .overlay(
                    Rectangle()
                        .stroke(cellBorder, lineWidth: deviceLayout.gridPadding * 0.5)
                        .cornerRadius(deviceLayout.gridPadding)
                )
            
            if symbol == "X" {
                XView()
                    .stroke(isWinningCell ? Color.green : Color.blue, lineWidth: deviceLayout.gridPadding * 0.5)
                    .frame(width: symbolSize, height: symbolSize)
                    .shadow(color: (isWinningCell ? Color.green : Color.blue).opacity(0.5),
                           radius: isWinningCell ? 6 : 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            } else if symbol == "O" {
                OView()
                    .stroke(isWinningCell ? Color.green : Color.red, lineWidth: deviceLayout.gridPadding * 0.5)
                    .frame(width: symbolSize, height: symbolSize)
                    .shadow(color: (isWinningCell ? Color.green : Color.red).opacity(0.5),
                           radius: isWinningCell ? 6 : 3)
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