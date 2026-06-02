//
//  CGFloat.swift
//  MediFinder
//
//  Created by Muhammet Eren on 23.01.2026.
//


import UIKit
import SwiftUI

// MARK: - Device Type Detection
enum DeviceType {
    case iPhone
    case iPadPortrait
    case iPadLandscape

    static var current: DeviceType {
        let idiom = UIDevice.current.userInterfaceIdiom
        let size = UIScreen.main.bounds.size
        let isLandscape = size.width > size.height

        switch idiom {
        case .phone:
            return .iPhone
        case .pad:
            return isLandscape ? .iPadLandscape : .iPadPortrait
        default:
            return .iPhone
        }
    }
}

// MARK: - CGFloat Responsive Extensions
extension CGFloat {

    // MARK: - Screen Dimensions
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.size.width
    }

    static var screenHeight: CGFloat {
        UIScreen.main.bounds.size.height
    }

    static func widthPer(per: CGFloat) -> CGFloat {
        screenWidth * per
    }

    static func heightPer(per: CGFloat) -> CGFloat {
        screenHeight * per
    }

    // MARK: - Safe Area (modern keyWindow lookup)
    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    static var topInsets: CGFloat {
        keyWindow?.safeAreaInsets.top ?? 0
    }

    static var bottomInsets: CGFloat {
        keyWindow?.safeAreaInsets.bottom ?? 0
    }

    static var tabBarBottomPadding: CGFloat { 60 }

    static var horizontalInsets: CGFloat {
        guard let insets = keyWindow?.safeAreaInsets else { return 0 }
        return insets.left + insets.right
    }

    static var verticalInsets: CGFloat {
        guard let insets = keyWindow?.safeAreaInsets else { return 0 }
        return insets.top + insets.bottom
    }

    // MARK: - Device Detection
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    static var isLandscape: Bool {
        screenWidth > screenHeight
    }

    static var deviceType: DeviceType {
        DeviceType.current
    }

    // MARK: - Responsive Positioning

    static func responsiveTop(percent: CGFloat) -> CGFloat {
        heightPer(per: percent)
    }

    static func responsiveLeading(percent: CGFloat) -> CGFloat {
        widthPer(per: percent)
    }

    static func responsiveOffset(x: CGFloat = 0, y: CGFloat = 0) -> (x: CGFloat, y: CGFloat) {
        (x: widthPer(per: x), y: heightPer(per: y))
    }

    static func responsiveHorizontalMargin(percent: CGFloat = 0.06) -> CGFloat {
        widthPer(per: percent)
    }

    static func responsiveVerticalMargin(percent: CGFloat = 0.02) -> CGFloat {
        heightPer(per: percent)
    }

    static func responsiveSpacing(percent: CGFloat) -> CGFloat {
        let baseSize = Swift.min(screenWidth, screenHeight)
        return baseSize * percent
    }

    static func responsiveValue(iPhone: CGFloat, iPadPortrait: CGFloat, iPadLandscape: CGFloat) -> CGFloat {
        switch deviceType {
        case .iPhone: return iPhone
        case .iPadPortrait: return iPadPortrait
        case .iPadLandscape: return iPadLandscape
        }
    }

    static func responsiveValue(iPhone: CGFloat, iPad: CGFloat) -> CGFloat {
        switch deviceType {
        case .iPhone: return iPhone
        case .iPadPortrait, .iPadLandscape: return iPad
        }
    }
}

// MARK: - View Extensions
extension View {

    func responsivePadding(_ edges: Edge.Set = .all, percent: CGFloat) -> some View {
        let paddingValue = CGFloat.responsiveSpacing(percent: percent)
        return self.padding(edges, paddingValue)
    }

    func responsiveHorizontalPadding(percent: CGFloat = 0.06) -> some View {
        self.padding(.horizontal, .responsiveHorizontalMargin(percent: percent))
    }

    func responsiveVerticalPadding(percent: CGFloat = 0.02) -> some View {
        self.padding(.vertical, .responsiveVerticalMargin(percent: percent))
    }

    func responsiveFrame(widthPercent: CGFloat? = nil, heightPercent: CGFloat? = nil) -> some View {
        self.frame(
            width: widthPercent.map { .widthPer(per: $0) },
            height: heightPercent.map { .heightPer(per: $0) }
        )
    }

    func responsiveOffset(xPercent: CGFloat = 0, yPercent: CGFloat = 0) -> some View {
        let offset = CGFloat.responsiveOffset(x: xPercent, y: yPercent)
        return self.offset(x: offset.x, y: offset.y)
    }

    @ViewBuilder
    func responsivePosition(topPercent: CGFloat? = nil, leadingPercent: CGFloat? = nil) -> some View {
        self
            .padding(.top, topPercent != nil ? .responsiveTop(percent: topPercent!) : 0)
            .padding(.leading, leadingPercent != nil ? .responsiveLeading(percent: leadingPercent!) : 0)
    }

    func responsiveFrame(widthPercent: CGFloat? = nil, heightPercent: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self.frame(
            width: widthPercent != nil ? .widthPer(per: widthPercent!) : nil,
            height: heightPercent != nil ? .heightPer(per: heightPercent!) : nil,
            alignment: alignment
        )
    }
}
