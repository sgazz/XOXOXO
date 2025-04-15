import SwiftUI

struct BoardView: View {
    @Binding var board: [String]
    let isActive: Bool
    let onTap: (Int) -> Void
    
    // Dynamic sizing properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var cellSize: CGFloat {
        if isIPad {
            return isLandscape ? 50 : 60
        } else {
            return isLandscape ? 35 : 40
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3) { row in
                HStack(spacing: 3) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        CellView(
                            value: board[index],
                            onTap: { onTap(index) }
                        )
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(
                    color: isActive ? .blue.opacity(0.5) : .gray.opacity(0.3),
                    radius: isActive ? 8 : 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isActive ? Color.blue : Color.gray.opacity(0.3),
                    lineWidth: isActive ? 2 : 1
                )
        )
        .scaleEffect(isActive ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
}

struct CellView: View {
    let value: String
    let onTap: () -> Void
    
    // Dynamic font sizing
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var fontSize: CGFloat {
        if isIPad {
            return isLandscape ? 30 : 35
        } else {
            return isLandscape ? 20 : 25
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(value)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(value == "X" ? .blue : .red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .disabled(!value.isEmpty)
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