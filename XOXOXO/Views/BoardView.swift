import SwiftUI

struct BoardView: View {
    @Binding var board: [String]
    let isActive: Bool
    let onTap: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
            ForEach(0..<9) { index in
                CellView(symbol: board[index])
                    .frame(height: 40)
                    .onTapGesture {
                        if isActive {
                            onTap(index)
                        }
                    }
            }
        }
        .padding(5)
        .background(isActive ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CellView: View {
    let symbol: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black, lineWidth: 1)
                .background(Color.white)
            Text(symbol)
                .font(.system(size: 20, weight: .bold))
        }
    }
} 