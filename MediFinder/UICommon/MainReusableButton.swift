//
//  MainReusableButton.swift
//  MediFinder
//
//  Created by Muhammet Eren.
//

import Foundation
import SwiftUI

enum MainButtonStyle: Equatable {
    case dark
    case light
    case custom(bg: Color, fg: Color)
}

/// Primary app button with shared sizing, radius, disabled, and color treatment.
struct MainReusableButton: View {
    var title: LocalizedStringKey
    var style: MainButtonStyle = .dark
    
    var width: CGFloat = .infinity
    var height: CGFloat = 52
    var cornerRadius: CGFloat = 32
    
    var isDisabled: Bool = false
    var isTitleUppercased: Bool = false
    
    var action: () -> Void

    private var bgColor: Color {
        if isDisabled { return Color.gray.opacity(0.3) }
        switch style {
        case .dark: return Color.labelPrimary
        case .light: return Color.labelSecondary.opacity(0.2)
        case .custom(let bg, _): return bg
        }
    }
    
    private var fgColor: Color {
        if isDisabled { return .gray }
        switch style {
        case .dark: return .white
        case .light: return Color.labelPrimary
        case .custom(_, let fg): return fg
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyMedium(.semibold))
                .textCase(isTitleUppercased ? .uppercase : nil)
                .frame(maxWidth: width)
                .frame(height: height)
                .background(bgColor)
                .foregroundColor(fgColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(style == .light ? Color.clear : Color.clear, lineWidth: 1)
                )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        MainReusableButton(title: "Search Providers", width: .infinity) { }
        
        MainReusableButton(title: "Cancel", style: .light, width: .infinity) { }
    }
}
