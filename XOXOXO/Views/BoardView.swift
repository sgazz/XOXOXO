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
    
    private var deviceType: DeviceType {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return .iphone
        case (.compact, .compact): return .iphoneLandscape
        case (.regular, .regular): return .ipad
        case (.regular, .compact): return .ipadLandscape
        default: return .iphone
        }
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
                                deviceType: deviceType
                            )
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                handleCellTap(at: index)
                            }
                        }
                    }
                }
            }
            .padding(deviceType.boardPadding)
            .background(
                RoundedRectangle(cornerRadius: deviceType.cornerRadius)
                    .fill(colorScheme == .dark ? 
                          Color(.systemBackground) : 
                          Color.white.opacity(0.8))
                    .shadow(
                        color: isActive ? Color.blue.opacity(0.6) : Color.black.opacity(0.2),
                        radius: isActive ? deviceType.activeShadowRadius : deviceType.inactiveShadowRadius,
                        x: 0,
                        y: isActive ? 5 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: deviceType.cornerRadius)
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
        let availableSpace = minDimension - (deviceType.boardPadding * 2)
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
    fileprivate let deviceType: DeviceType
    
    @Environment(\.colorScheme) private var colorScheme
    
    fileprivate var symbolSize: CGFloat {
        deviceType.symbolSize
    }
    
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
                .cornerRadius(deviceType.cellCornerRadius)
                .overlay(
                    Rectangle()
                        .stroke(cellBorder, lineWidth: deviceType.cellBorderWidth)
                        .cornerRadius(deviceType.cellCornerRadius)
                )
            
            if symbol == "X" {
                XView()
                    .stroke(isWinningCell ? Color.green : Color.blue, lineWidth: deviceType.symbolStrokeWidth)
                    .frame(width: symbolSize, height: symbolSize)
                    .shadow(color: (isWinningCell ? Color.green : Color.blue).opacity(0.5),
                           radius: isWinningCell ? 6 : 3)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            } else if symbol == "O" {
                OView()
                    .stroke(isWinningCell ? Color.green : Color.red, lineWidth: deviceType.symbolStrokeWidth)
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

fileprivate enum DeviceType {
    case iphone
    case iphoneLandscape
    case ipad
    case ipadLandscape
    
    var boardPadding: CGFloat {
        switch self {
        case .iphone: return 4
        case .iphoneLandscape: return 3
        case .ipad: return 6
        case .ipadLandscape: return 5
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .iphone: return 10
        case .iphoneLandscape: return 8
        case .ipad: return 15
        case .ipadLandscape: return 12
        }
    }
    
    var activeShadowRadius: CGFloat {
        switch self {
        case .iphone: return 15
        case .iphoneLandscape: return 12
        case .ipad: return 20
        case .ipadLandscape: return 18
        }
    }
    
    var inactiveShadowRadius: CGFloat {
        switch self {
        case .iphone: return 5
        case .iphoneLandscape: return 4
        case .ipad: return 8
        case .ipadLandscape: return 6
        }
    }
    
    var symbolSize: CGFloat {
        switch self {
        case .iphone: return 30
        case .iphoneLandscape: return 25
        case .ipad: return 40
        case .ipadLandscape: return 35
        }
    }
    
    var symbolStrokeWidth: CGFloat {
        switch self {
        case .iphone: return 3
        case .iphoneLandscape: return 2.5
        case .ipad: return 4
        case .ipadLandscape: return 3.5
        }
    }
    
    var cellCornerRadius: CGFloat {
        switch self {
        case .iphone: return 4
        case .iphoneLandscape: return 3
        case .ipad: return 6
        case .ipadLandscape: return 5
        }
    }
    
    var cellBorderWidth: CGFloat {
        switch self {
        case .iphone: return 1.5
        case .iphoneLandscape: return 1.2
        case .ipad: return 2
        case .ipadLandscape: return 1.8
        }
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