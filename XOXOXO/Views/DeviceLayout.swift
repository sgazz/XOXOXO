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
    private var baseTitleSize: CGFloat { 56 }
    private var baseSubtitleSize: CGFloat { 28 }
    private var baseDescriptionSize: CGFloat { 22 }
    private var baseTitleScale: CGFloat { 0.12 }
    private var baseSubtitleScale: CGFloat { 0.055 }
    private var baseDescriptionScale: CGFloat { 0.04 }
    
    private var layoutMultiplier: CGFloat {
        switch self {
        case .iphone: return 1.0
        case .iphoneLandscape: return Self.landscapeScaleFactor
        case .ipad: return Self.ipadScaleFactor
        case .ipadLandscape: return Self.ipadScaleFactor * Self.landscapeScaleFactor
        }
    }
    
    var topPadding: CGFloat {
        baseTopPadding * layoutMultiplier
    }
    
    var bottomSafeArea: CGFloat {
        baseBottomSafeArea * layoutMultiplier
    }
    
    var scoreSpacing: CGFloat {
        baseScoreSpacing * layoutMultiplier
    }
    
    var gridPadding: CGFloat {
        baseGridPadding * layoutMultiplier
    }
    
    var boardSpacing: CGFloat {
        baseBoardSpacing * layoutMultiplier
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
        Self.stackSpacing * layoutMultiplier
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
    
    var titleSize: CGFloat {
        baseTitleSize * layoutMultiplier
    }
    
    var titleScale: CGFloat {
        baseTitleScale * layoutMultiplier
    }
    
    var subtitleSize: CGFloat {
        baseSubtitleSize * layoutMultiplier
    }
    
    var subtitleScale: CGFloat {
        baseSubtitleScale * layoutMultiplier
    }
    
    var descriptionSize: CGFloat {
        baseDescriptionSize * layoutMultiplier
    }
    
    var descriptionScale: CGFloat {
        baseDescriptionScale * layoutMultiplier
    }
} 
