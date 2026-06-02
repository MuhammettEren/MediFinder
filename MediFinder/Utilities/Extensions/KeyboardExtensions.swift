//
//  KeyboardExtensions.swift
//  MediFinder
//
//  Created by Muhammet Eren on 7.01.2026.
//

import SwiftUI
import UIKit

extension View {
    func hideKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
}
