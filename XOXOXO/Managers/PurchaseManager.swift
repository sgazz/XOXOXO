import Foundation

class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var isPvPUnlocked: Bool {
        didSet {
            UserDefaults.standard.set(isPvPUnlocked, forKey: "isPvPUnlocked")
        }
    }
    
    private init() {
        self.isPvPUnlocked = UserDefaults.standard.bool(forKey: "isPvPUnlocked")
    }
    
    func unlockPvP() {
        isPvPUnlocked = true
    }
} 