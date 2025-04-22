import Foundation

enum GameDuration: Int {
    case oneMinute = 60
    case threeMinutes = 180
    case fiveMinutes = 300
    
    var displayName: String {
        switch self {
        case .oneMinute:
            return "1 Minute"
        case .threeMinutes:
            return "3 Minutes"
        case .fiveMinutes:
            return "5 Minutes"
        }
    }
}

class GameTimerSettings: ObservableObject {
    static let shared = GameTimerSettings()
    
    @Published var gameDuration: GameDuration {
        didSet {
            UserDefaults.standard.set(gameDuration.rawValue, forKey: "gameDuration")
        }
    }
    
    private init() {
        let savedDuration = UserDefaults.standard.integer(forKey: "gameDuration")
        self.gameDuration = GameDuration(rawValue: savedDuration) ?? .oneMinute
    }
    
    var remainingSeconds: Int {
        return gameDuration.rawValue
    }
} 