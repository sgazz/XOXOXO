import SwiftUI

enum DeviceLayout {
    case iphone
    case iphoneLandscape
    case ipad
    case ipadLandscape
    
    static func current(horizontalSizeClass: UserInterfaceSizeClass?, verticalSizeClass: UserInterfaceSizeClass?) -> DeviceLayout {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return .iphone
        case (.compact, .compact): return .iphoneLandscape
        case (.regular, .regular): return .ipad
        case (.regular, .compact): return .ipadLandscape
        default: return .iphone
        }
    }
    
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
    
    var titleSize: CGFloat {
        switch self {
            case .iphone: return 56
            case .iphoneLandscape: return 48
            case .ipad: return 86
            case .ipadLandscape: return 72
        }
    }
    
    var titleScale: CGFloat {
        switch self {
            case .iphone: return 0.12
            case .iphoneLandscape: return 0.10
            case .ipad: return 0.135
            case .ipadLandscape: return 0.115
        }
    }
    
    var subtitleSize: CGFloat {
        switch self {
            case .iphone: return 28
            case .iphoneLandscape: return 24
            case .ipad: return 38
            case .ipadLandscape: return 32
        }
    }
    
    var subtitleScale: CGFloat {
        switch self {
            case .iphone: return 0.055
            case .iphoneLandscape: return 0.048
            case .ipad: return 0.064
            case .ipadLandscape: return 0.056
        }
    }
    
    var descriptionSize: CGFloat {
        switch self {
            case .iphone: return 22
            case .iphoneLandscape: return 20
            case .ipad: return 30
            case .ipadLandscape: return 26
        }
    }
    
    var descriptionScale: CGFloat {
        switch self {
            case .iphone: return 0.04
            case .iphoneLandscape: return 0.035
            case .ipad: return 0.048
            case .ipadLandscape: return 0.042
        }
    }
    
    var boardSpacing: CGFloat {
        switch self {
            case .iphone: return 8
            case .iphoneLandscape: return 6
            case .ipad: return 15
            case .ipadLandscape: return 12
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
    
    func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height
        
        switch self {
        case .iphone:
            // За iPhone у portrait режиму, користимо 45% ширине екрана
            let maxWidth = availableWidth * 0.45
            let maxHeight = availableHeight * 0.2
            return min(maxWidth, maxHeight)
            
        case .iphoneLandscape:
            // За iPhone у landscape режиму, користимо 30% ширине екрана
            let maxWidth = availableWidth * 0.3
            let maxHeight = availableHeight * 0.4
            return min(maxWidth, maxHeight)
            
        case .ipad:
            // За iPad у portrait режиму, користимо 40% ширине екрана
            let maxWidth = availableWidth * 0.4
            let maxHeight = availableHeight * 0.25
            return min(maxWidth, maxHeight)
            
        case .ipadLandscape:
            // За iPad у landscape режиму, користимо 35% ширине екрана
            let maxWidth = availableWidth * 0.35
            let maxHeight = availableHeight * 0.35
            return min(maxWidth, maxHeight)
        }
    }
} 