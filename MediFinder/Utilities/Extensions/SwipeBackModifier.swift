//
//  SwipeBackModifier.swift
//  MediFinder
//
//  Created by Muhammet Eren on 29.01.2026.
//

import SwiftUI
import UIKit

struct SwipeBackModifier: ViewModifier {
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard isEnabled else { return }
                                isDragging = true
                                let translation = value.translation.width
                                if translation > 0 {
                                    dragOffset = min(translation, 100)
                                }
                            }
                            .onEnded { value in
                                guard isEnabled else { return }
                                isDragging = false
                                let translation = value.translation.width
                                if translation > 50 {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        dragOffset = 0
                                    }
                                    action()
                                } else {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
            )
            .overlay(alignment: .leading) {
                if isDragging && dragOffset > 0 {
                    Rectangle()
                        .fill(Color.black.opacity(0.1 * (dragOffset / 100)))
                        .frame(width: dragOffset)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
    }
}

extension View {
    func enableSwipeBack(isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        self.modifier(SwipeBackModifier(isEnabled: isEnabled, action: action))
    }
}
