//
//  Typography.swift
//  MediFinder
//
//  Created by Muhammet Eren.
//

import Foundation
import SwiftUI

enum AppFontName: String {
    case black = "SF-Pro-Display-Black"
    case blackItalic = "SF-Pro-Display-BlackItalic"
    case bold = "SF-Pro-Display-Bold"
    case boldItalic = "SF-Pro-Display-BoldItalic"
    case heavy = "SF-Pro-Display-Heavy"
    case heavyItalic = "SF-Pro-Display-HeavyItalic"
    case light = "SF-Pro-Display-Light"
    case lightItalic = "SF-Pro-Display-LightItalic"
    case medium = "SF-Pro-Display-Medium"
    case mediumItalic = "SF-Pro-Display-MediumItalic"
    case regular = "SF-Pro-Display-Regular"
    case regularItalic = "SF-Pro-Display-RegularItalic"
    case semibold = "SF-Pro-Display-Semibold"
    case semiboldItalic = "SF-Pro-Display-SemiboldItalic"
    case thin = "SF-Pro-Display-Thin"
    case thinItalic = "SF-Pro-Display-ThinItalic"
    case ultralight = "SF-Pro-Display-Ultralight"
    case ultralightItalic = "SF-Pro-Display-UltralightItalic"
}

enum AppWeight {
    case bold, semibold, medium, regular
    
    var fontName: AppFontName {
        switch self {
        case .bold: return .bold
        case .semibold: return .semibold
        case .medium: return .medium
        case .regular: return .regular
        }
    }
}

extension Font {
    
    static func h1(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 48) }
    static func h2(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 40) }
    static func h3(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 32) }
    static func h4(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 24) }
    static func h5(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 20) }
    static func h6(_ weight: AppWeight = .bold) -> Font { Font.custom(weight.fontName.rawValue, size: 18) }
  
    
    private static func appBody(_ weight: AppWeight, size: CGFloat) -> Font {
        return Font.custom(weight.fontName.rawValue, size: size)
    }

    /// Body Jumbo 2 - 28px
    static func bodyJumbo2(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 28) }
    
    /// Body Jumbo - 24px
    static func bodyJumbo(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 24) }
    
    /// Body XXLarge - 20px
    static func bodyXXLarge(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 20) }
    
    /// Body XLarge - 18px
    static func bodyXLarge(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 18) }
    
    /// Body Large - 16px
    static func bodyLarge(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 16) }
    
    /// Body Medium - 14px
    static func bodyMedium(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 14) }
    
    /// Body Small - 12px
    static func bodySmall(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 12) }
    
    /// Body XSmall - 10px
    static func bodyXSmall(_ weight: AppWeight = .regular) -> Font { appBody(weight, size: 10) }
}
