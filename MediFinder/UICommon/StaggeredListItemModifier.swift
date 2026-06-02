import SwiftUI

/// Lightweight sequential reveal for provider cards and rows.
struct StaggeredListItemModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(.easeOut(duration: 0.28).delay(min(Double(index) * 0.045, 0.32))) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Reveals list items with a short index-based delay.
    func staggeredListItem(index: Int) -> some View {
        modifier(StaggeredListItemModifier(index: index))
    }
}
