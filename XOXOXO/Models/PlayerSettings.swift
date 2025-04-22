import Foundation

class PlayerSettings: ObservableObject {
    static let shared = PlayerSettings()
    
    @Published var playerSymbol: String {
        didSet {
            UserDefaults.standard.set(playerSymbol, forKey: "playerSymbol")
        }
    }
    
    private init() {
        self.playerSymbol = UserDefaults.standard.string(forKey: "playerSymbol") ?? "X"
    }
    
    var isPlayerX: Bool {
        return playerSymbol == "X"
    }
    
    var isPlayerO: Bool {
        return playerSymbol == "O"
    }
    
    var aiSymbol: String {
        return isPlayerX ? "O" : "X"
    }
} 