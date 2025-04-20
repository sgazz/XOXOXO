import SwiftUI

enum DeviceLayout {
    // Константе за израчунавање
    private static let ipadScaleFactor: CGFloat = 1.2 // Смањен фактор за iPad
    private static let landscapeScaleFactor: CGFloat = 0.95 // Повећан фактор за landscape
    
    // Нове константе за израчунавање величине табле
    private static let screenUsagePortrait: CGFloat = 0.85 // Користимо 85% ширине екрана у портрет моду
    private static let screenUsageLandscape: CGFloat = 0.75 // Користимо 75% висине у пејзажном моду
    private static let verticalSpacingFactor: CGFloat = 0.05 // 5% висине екрана за вертикални размак
    
    // Нове константе за флексибилне распореде
    private static let contentSpacing: CGFloat = 16
    private static let stackSpacing: CGFloat = 20
    
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
    
    // Повећане базне вредности
    private var baseTopPadding: CGFloat { 20 }
    private var baseBottomSafeArea: CGFloat { 40 }
    private var baseScoreSpacing: CGFloat { 30 }
    private var baseGridPadding: CGFloat { 24 }
    private var baseBoardSpacing: CGFloat { 40 }
    
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
    
    // Нова функција за оптимални распоред
    func optimalStackOrientation(for geometry: GeometryProxy) -> Bool {
        if isLandscape {
            // У пејзажном моду, користимо HStack ако имамо довољно простора
            return geometry.size.width > geometry.size.height * 1.5
        } else {
            // У портрет моду, користимо VStack осим ако је екран јако широк
            return geometry.size.width < geometry.size.height * 0.8
        }
    }
    
    // Нова функција за размак између елемената
    var adaptiveSpacing: CGFloat {
        switch self {
        case .iphone: return Self.stackSpacing
        case .iphoneLandscape: return Self.stackSpacing * Self.landscapeScaleFactor
        case .ipad: return Self.stackSpacing * Self.ipadScaleFactor
        case .ipadLandscape: return Self.stackSpacing * Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    // Побољшана функција за израчунавање величине табле
    func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height
        let useVerticalLayout = optimalStackOrientation(for: geometry)
        
        // Резервишемо простор за горњи део (тајмер и резултат)
        let topReservedSpace: CGFloat = isIphone ? 100.0 : 140.0
        let usableHeight = availableHeight - topReservedSpace - adaptiveSpacing * 2
        
        if useVerticalLayout {
            // Вертикални распоред
            let maxWidth = availableWidth * Self.screenUsagePortrait
            let boardWidth = maxWidth / 2.0
            let totalHeight = boardWidth * 4.0 + adaptiveSpacing * 3.0
            
            if totalHeight > usableHeight * 0.95 {
                return (usableHeight * 0.95 - adaptiveSpacing * 3.0) / 4.0
            }
            return boardWidth
        } else {
            // Хоризонтални распоред
            let maxHeight = usableHeight * Self.screenUsageLandscape
            let boardSize = min(
                maxHeight / 2.0,
                (availableWidth * 0.9 - adaptiveSpacing) / 4.0
            )
            return boardSize
        }
    }
    
    // Остале функције остају исте...
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
} 
