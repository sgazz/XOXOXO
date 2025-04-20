import SwiftUI

enum DeviceLayout {
    // Константе за израчунавање
    private static let ipadScaleFactor: CGFloat = 1.5 // iPad елементи су 1.5x већи од iPhone
    private static let landscapeScaleFactor: CGFloat = 0.85 // Landscape елементи су 0.85x од portrait
    
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
    
    // Базне вредности за iPhone portrait
    private var baseTopPadding: CGFloat { 10 }
    private var baseBottomSafeArea: CGFloat { 30 }
    private var baseScoreSpacing: CGFloat { 20 }
    private var baseGridPadding: CGFloat { 16 }
    private var baseBoardSpacing: CGFloat { 28 }
    
    var topPadding: CGFloat {
        let base = baseTopPadding
        switch self {
            case .iphone: return base
            case .iphoneLandscape: return base * Self.landscapeScaleFactor
            case .ipad: return base * Self.ipadScaleFactor
            case .ipadLandscape: return base * Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    var bottomSafeArea: CGFloat {
        let base = baseBottomSafeArea
        switch self {
            case .iphone: return base
            case .iphoneLandscape: return base * Self.landscapeScaleFactor
            case .ipad: return base * Self.ipadScaleFactor
            case .ipadLandscape: return base * Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    var scoreSpacing: CGFloat {
        let base = baseScoreSpacing
        switch self {
            case .iphone: return base
            case .iphoneLandscape: return base * Self.landscapeScaleFactor
            case .ipad: return base * Self.ipadScaleFactor
            case .ipadLandscape: return base * Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    var gridPadding: CGFloat {
        let base = baseGridPadding
        switch self {
            case .iphone: return base
            case .iphoneLandscape: return base * Self.landscapeScaleFactor
            case .ipad: return base * Self.ipadScaleFactor
            case .ipadLandscape: return base * Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    var boardSpacing: CGFloat {
        let base = baseBoardSpacing
        switch self {
            case .iphone: return base
            case .iphoneLandscape: return base * Self.landscapeScaleFactor
            case .ipad: return base * Self.ipadScaleFactor
            case .ipadLandscape: return base * Self.ipadScaleFactor * Self.landscapeScaleFactor
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
        
        // Константе за израчунавање
        let topSpaceScale: CGFloat = isIphone ? 140/baseBoardSpacing : 200/baseBoardSpacing
        let verticalSpacingScale: CGFloat = isIphone ? 5.0 : 5.5
        let horizontalSpacingScale: CGFloat = isIphone ? 3.0 : 3.5
        let sideMarginScale: CGFloat = isIphone ? 56/baseBoardSpacing : 80/baseBoardSpacing
        let boardScale: CGFloat = isIphone ? 0.85 : 0.80
        
        // Одузимамо простор за горњи део (тајмер и резултат)
        let topSpace: CGFloat = boardSpacing * topSpaceScale
        let usableHeight = availableHeight - topSpace
        
        // Рачунамо размаке између табли
        let verticalSpacing = boardSpacing * verticalSpacingScale
        let horizontalSpacing = boardSpacing * horizontalSpacingScale
        
        // Рачунамо максималне димензије
        let maxHeightForBoard = (usableHeight - verticalSpacing) / 4
        let sideMargins: CGFloat = boardSpacing * sideMarginScale
        let maxWidthForBoard = (availableWidth - horizontalSpacing - sideMargins) / 2
        
        // Узимамо мању вредност да бисмо одржали квадратни облик
        return min(maxHeightForBoard, maxWidthForBoard) * boardScale
    }
} 
