import SwiftUI

struct BoardView: View {
    @Binding var board: [String]
    var isActive: Bool
    var onTap: (Int) -> Void
    
    @State private var cellAnimations: [Bool] = Array(repeating: false, count: Int(BoardConstants.gridSize * BoardConstants.gridSize))
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let symbols = ["", "X", "O"]
    
    private var deviceLayout: DeviceLayout {
        DeviceLayout.current(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = calculateCellSize(for: geometry.size)
            let totalWidth = cellSize * BoardConstants.gridSize + BoardConstants.cellSpacing * (BoardConstants.gridSize - 1)
            
            VStack(spacing: BoardConstants.cellSpacing) {
                ForEach(0..<Int(BoardConstants.gridSize), id: \.self) { row in
                    HStack(spacing: BoardConstants.cellSpacing) {
                        ForEach(0..<Int(BoardConstants.gridSize), id: \.self) { column in
                            let index = row * Int(BoardConstants.gridSize) + column
                            CellView(
                                symbol: board[index],
                                isActive: isActive && board[index].isEmpty,
                                isAnimating: cellAnimations[index],
                                deviceLayout: deviceLayout
                            )
                            .aspectRatio(1, contentMode: .fit)
                            .drawingGroup()
                            .onTapGesture {
                                handleCellTap(at: index)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(cellAccessibilityLabel(for: index, symbol: board[index]))
                            .accessibilityHint(cellAccessibilityHint(for: index, isActive: isActive && board[index].isEmpty))
                            .accessibilityAddTraits(cellAccessibilityTraits(for: index, symbol: board[index], isActive: isActive && board[index].isEmpty))
                        }
                    }
                }
            }
            .frame(width: totalWidth, height: totalWidth)
            .padding(4)
            .clipShape(Rectangle())
            .drawingGroup()
            .scaleEffect(isActive ? 1.015 : 1.0)
            .animation(.spring(response: BoardConstants.springResponse, dampingFraction: BoardConstants.springDampingFraction), value: isActive)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Tic Tac Toe Board")
            .accessibilityHint(isActive ? "Your turn to play" : "Waiting for opponent")
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func calculateCellSize(for size: CGSize) -> CGFloat {
        let minDimension = min(size.width, size.height)
        return (minDimension - BoardConstants.cellSpacing * (BoardConstants.gridSize - 1)) / BoardConstants.gridSize
    }
    
    private func handleCellTap(at index: Int) {
        if isActive && board[index].isEmpty {
            SoundManager.shared.playLightHaptic()
            
            withAnimation(.interpolatingSpring(
                mass: BoardConstants.cellAnimationMass,
                stiffness: BoardConstants.cellAnimationStiffness,
                damping: BoardConstants.cellAnimationDamping
            )) {
                cellAnimations[index] = true
            }
            
            onTap(index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + BoardConstants.cellAnimationDuration) {
                withAnimation(.interpolatingSpring(
                    mass: BoardConstants.cellAnimationMass,
                    stiffness: BoardConstants.cellAnimationStiffness,
                    damping: BoardConstants.cellAnimationDamping
                )) {
                    cellAnimations[index] = false
                }
            }
        } else if !board[index].isEmpty {
            SoundManager.shared.playSound(.error)
        }
    }
    
    // Accessibility helpers
    private func cellAccessibilityLabel(for index: Int, symbol: String) -> String {
        let row = index / Int(BoardConstants.gridSize) + 1
        let col = index % Int(BoardConstants.gridSize) + 1
        
        if symbol.isEmpty {
            return "Empty cell at row \(row), column \(col)"
        } else {
            return "\(symbol) at row \(row), column \(col)"
        }
    }
    
    private func cellAccessibilityHint(for index: Int, isActive: Bool) -> String {
        if isActive {
            return "Double tap to place your symbol"
        } else if !board[index].isEmpty {
            return "This cell is already taken"
        } else {
            return "This cell is not active yet"
        }
    }
    
    private func cellAccessibilityTraits(for index: Int, symbol: String, isActive: Bool) -> AccessibilityTraits {
        var traits: AccessibilityTraits = []
        
        if isActive {
            traits = traits.union(.isButton)
        }
        
        if !symbol.isEmpty {
            traits = traits.union(.isSelected)
        }
        
        return traits
    }
}

struct CellView: View {
    let symbol: String
    let isActive: Bool
    let isAnimating: Bool
    let deviceLayout: DeviceLayout
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool {
        colorScheme == .dark
    }
    
    private var cellBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BoardConstants.cellCornerRadius)
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
                RoundedRectangle(cornerRadius: BoardConstants.cellCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(BoardConstants.activeCellGradientStartOpacity),
                                Color.blue.opacity(BoardConstants.activeCellGradientEndOpacity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
    
    private var cellBorder: some View {
        RoundedRectangle(cornerRadius: BoardConstants.cellCornerRadius)
            .stroke(
                LinearGradient(
                    colors: isActive ? 
                        [Color.blue.opacity(1), Color.blue.opacity(0.6)] :
                        [Color.white.opacity(isDark ? BoardConstants.inactiveCellGradientStartOpacity : BoardConstants.inactiveCellGradientEndOpacity),
                         Color.white.opacity(isDark ? BoardConstants.inactiveCellGradientEndOpacity : BoardConstants.inactiveCellGradientEndOpacity)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: BoardConstants.cellBorderWidth
            )
    }
    
    private var symbolSize: CGFloat {
        deviceLayout.gridPadding * BoardConstants.symbolSizeMultiplier
    }
    
    var body: some View {
        ZStack {
            cellBackground
            cellBorder
            
            if !symbol.isEmpty {
                SymbolView(
                    symbol: symbol,
                    isAnimating: isAnimating,
                    size: symbolSize
                )
            }
        }
        .compositingGroup()
        .shadow(
            color: Color.black.opacity(isDark ? BoardConstants.darkShadowOpacity : BoardConstants.lightShadowOpacity),
            radius: BoardConstants.cellShadowRadius,
            x: 0,
            y: BoardConstants.cellShadowYOffset
        )
    }
}

struct SymbolView: View {
    let symbol: String
    let isAnimating: Bool
    let size: CGFloat
    
    var body: some View {
        Group {
            if symbol == "X" {
                XView()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color(red: 0.4, green: 0.8, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: size * BoardConstants.symbolLineWidthMultiplier,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
            } else if symbol == "O" {
                OView()
                    .stroke(
                        LinearGradient(
                            colors: [Color.red, Color(red: 1.0, green: 0.4, blue: 0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: size * BoardConstants.symbolLineWidthMultiplier,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
            }
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .shadow(
            color: (symbol == "X" ? Color.blue : Color.red).opacity(BoardConstants.shadowOpacity),
            radius: 3
        )
        .scaleEffect(isAnimating ? BoardConstants.symbolScaleMultiplier : 1.0)
        .animation(.interpolatingSpring(
            mass: BoardConstants.cellAnimationMass,
            stiffness: BoardConstants.cellAnimationStiffness,
            damping: BoardConstants.cellAnimationDamping
        ), value: isAnimating)
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

#Preview("Standard") {
    BoardView(
        board: .constant(Array(repeating: "", count: 9)),
        isActive: true,
        onTap: { _ in }
    )
    .padding()
}

#Preview("Small Screen") {
    BoardView(
        board: .constant(Array(repeating: "", count: 9)),
        isActive: true,
        onTap: { _ in }
    )
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Landscape") {
    BoardView(
        board: .constant(Array(repeating: "", count: 9)),
        isActive: true,
        onTap: { _ in }
    )
    .frame(width: 400, height: 200)
    .padding()
}

#Preview("iPad Split View") {
    HStack {
        BoardView(
            board: .constant(Array(repeating: "", count: 9)),
            isActive: true,
            onTap: { _ in }
        )
        .padding()
        
        BoardView(
            board: .constant(Array(repeating: "X", count: 9)),
            isActive: false,
            onTap: { _ in }
        )
        .padding()
    }
}

#Preview("Dark Mode") {
    BoardView(
        board: .constant(Array(repeating: "", count: 9)),
        isActive: true,
        onTap: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
} 