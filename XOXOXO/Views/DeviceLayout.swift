import SwiftUI

// Базне вредности груписане у структуру
private struct BaseValues {
    // Фактори скалирања
    static let ipadScale: CGFloat = 1.2
    static let landscapeScale: CGFloat = 0.95
    
    // Распоред екрана
    static let screenUsagePortrait: CGFloat = 0.85
    static let screenUsageLandscape: CGFloat = 0.75
    static let verticalSpacing: CGFloat = 0.05
    static let contentSpacing: CGFloat = 16
    static let stackSpacing: CGFloat = 20
    
    // Размаци и падинг
    static let topPadding: CGFloat = 20
    static let bottomSafeArea: CGFloat = 40
    static let scoreSpacing: CGFloat = 30
    static let gridPadding: CGFloat = 24
    static let boardSpacing: CGFloat = 40
    
    // Величине текста
    static let titleSize: CGFloat = 56
    static let subtitleSize: CGFloat = 28
    static let descriptionSize: CGFloat = 18
    
    // Скале текста
    static let titleScale: CGFloat = 0.12
    static let subtitleScale: CGFloat = 0.055
    static let descriptionScale: CGFloat = 0.04
    
    // Score View величине
    static let scoreIndicator: CGFloat = 14
    static let scoreTimer: CGFloat = 22
    static let scoreResult: CGFloat = 26
    static let scoreViewHeight: CGFloat = 80
    
    // Анимације
    static let transitionDuration: CGFloat = 0.3
    static let boardScaleEffect: CGFloat = 1.015
    static let boardPadding: CGFloat = 4
}

enum DeviceLayout {
    case iphone, iphoneLandscape, ipad, ipadLandscape
    
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
    
    private var layoutMultiplier: CGFloat {
        switch self {
        case .iphone: return 1.0
        case .iphoneLandscape: return BaseValues.landscapeScale
        case .ipad: return BaseValues.ipadScale
        case .ipadLandscape: return BaseValues.ipadScale * BaseValues.landscapeScale
        }
    }
    
    // Размаци и падинг
    var topPadding: CGFloat { BaseValues.topPadding * layoutMultiplier }
    var bottomSafeArea: CGFloat { BaseValues.bottomSafeArea * layoutMultiplier }
    var scoreSpacing: CGFloat { BaseValues.scoreSpacing * layoutMultiplier }
    var gridPadding: CGFloat { BaseValues.gridPadding * layoutMultiplier }
    var boardSpacing: CGFloat { BaseValues.boardSpacing * layoutMultiplier }
    
    // Величине текста
    var titleSize: CGFloat { BaseValues.titleSize * layoutMultiplier }
    var subtitleSize: CGFloat { BaseValues.subtitleSize * layoutMultiplier }
    var descriptionSize: CGFloat { BaseValues.descriptionSize * layoutMultiplier }
    
    // Скале текста
    var titleScale: CGFloat { BaseValues.titleScale * layoutMultiplier }
    var subtitleScale: CGFloat { BaseValues.subtitleScale * layoutMultiplier }
    var descriptionScale: CGFloat { BaseValues.descriptionScale * layoutMultiplier }
    
    // Score View величине
    var scoreIndicatorSize: CGFloat { BaseValues.scoreIndicator * layoutMultiplier }
    var scoreTimerSize: CGFloat { BaseValues.scoreTimer * layoutMultiplier }
    var scoreResultSize: CGFloat { BaseValues.scoreResult * layoutMultiplier }
    var scoreViewHeight: CGFloat { BaseValues.scoreViewHeight * layoutMultiplier }
    
    // Анимације
    var transitionDuration: CGFloat { BaseValues.transitionDuration }
    var boardScaleEffect: CGFloat { BaseValues.boardScaleEffect }
    var boardPadding: CGFloat { BaseValues.boardPadding }
    
    // Нова функција за размак између елемената
    var adaptiveSpacing: CGFloat {
        BaseValues.stackSpacing * layoutMultiplier
    }
    
    // Нова функција за оптимални распоред
    func optimalStackOrientation(for geometry: GeometryProxy) -> Bool {
        if isLandscape {
            return geometry.size.width > geometry.size.height * 1.5
        } else {
            return geometry.size.width < geometry.size.height * 0.8
        }
    }
    
    // Побољшана функција за израчунавање величине табле
    func calculateBoardWidth(for geometry: GeometryProxy) -> CGFloat {
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height
        let useVerticalLayout = optimalStackOrientation(for: geometry)
        
        let topReservedSpace: CGFloat = isIphone ? 100.0 : 140.0
        let usableHeight = availableHeight - topReservedSpace - adaptiveSpacing * 2
        
        if useVerticalLayout {
            let maxWidth = availableWidth * BaseValues.screenUsagePortrait
            let boardWidth = maxWidth / 2.0
            let totalHeight = boardWidth * 4.0 + adaptiveSpacing * 3.0
            
            if totalHeight > usableHeight * 0.95 {
                return (usableHeight * 0.95 - adaptiveSpacing * 3.0) / 4.0
            }
            return boardWidth
        } else {
            let maxHeight = usableHeight * BaseValues.screenUsageLandscape
            let boardSize = min(
                maxHeight / 2.0,
                (availableWidth * 0.9 - adaptiveSpacing) / 4.0
            )
            return boardSize
        }
    }
} 
