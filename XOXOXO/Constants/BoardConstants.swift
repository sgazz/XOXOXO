import SwiftUI

enum BoardConstants {
    // Grid constants
    static let gridSize: CGFloat = 3
    static let cellSpacing: CGFloat = 4
    
    // Animation constants
    static let cellAnimationDuration: Double = 0.15
    static let cellAnimationMass: Double = 0.5
    static let cellAnimationStiffness: Double = 200
    static let cellAnimationDamping: Double = 10
    
    // Visual constants
    static let cellCornerRadius: CGFloat = 6
    static let cellBorderWidth: CGFloat = 1.5
    static let cellShadowRadius: CGFloat = 4
    static let cellShadowYOffset: CGFloat = 2
    
    // Symbol constants
    static let symbolLineWidthMultiplier: CGFloat = 0.25
    static let symbolSizeMultiplier: CGFloat = 1.5
    static let symbolScaleMultiplier: CGFloat = 1.1
    
    // Color opacity constants
    static let activeCellGradientStartOpacity: Double = 0.3
    static let activeCellGradientEndOpacity: Double = 0.15
    static let inactiveCellGradientStartOpacity: Double = 0.2
    static let inactiveCellGradientEndOpacity: Double = 0.05
    static let shadowOpacity: Double = 0.3
    static let darkShadowOpacity: Double = 0.2
    static let lightShadowOpacity: Double = 0.08
    
    // Animation timing constants
    static let springResponse: Double = 0.5
    static let springDampingFraction: Double = 0.8
    static let winningAnimationResponse: Double = 0.4
} 