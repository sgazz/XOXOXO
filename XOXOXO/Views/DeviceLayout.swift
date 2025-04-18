import SwiftUI

enum DeviceLayout {
    case iphone
    case iphoneLandscape
    case ipad
    case ipadLandscape
    
    var isLandscape: Bool {
        self == .iphoneLandscape || self == .ipadLandscape
    }
    
    var isIphone: Bool {
        self == .iphone || self == .iphoneLandscape
    }
    
    var topPadding: CGFloat {
        switch self {
            case .iphone: return 10
            case .iphoneLandscape: return 5
            case .ipad: return 30
            case .ipadLandscape: return 20
        }
    }
    
    var bottomSafeArea: CGFloat {
        switch self {
            case .iphone: return 30
            case .iphoneLandscape: return 20
            case .ipad: return 40
            case .ipadLandscape: return 30
        }
    }
    
    var scoreSpacing: CGFloat {
        switch self {
            case .iphone: return 20
            case .iphoneLandscape: return 15
            case .ipad: return 40
            case .ipadLandscape: return 30
        }
    }
    
    var gridPadding: CGFloat {
        switch self {
            case .iphone: return 16
            case .iphoneLandscape: return 12
            case .ipad: return 24
            case .ipadLandscape: return 20
        }
    }
    
    func maxBoardWidth(for size: CGSize) -> CGFloat {
        switch self {
            case .iphone:
                return min(140, (size.width - 40) / 2)
            case .iphoneLandscape:
                let availableWidth = size.width * 0.85 // 85% екрана за табле
                return min(size.height * 0.45, (availableWidth - 60) / 4) // Веће табле у landscape режиму
            case .ipad:
                return min(200, (size.width - 80) / 3)
            case .ipadLandscape:
                return min(180, (size.width - 100) / 3)
        }
    }
} 