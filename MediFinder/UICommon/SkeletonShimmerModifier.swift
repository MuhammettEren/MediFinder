import SwiftUI

/// Reusable shimmer overlay for skeleton loading placeholders.
struct SkeletonShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.25

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [
                            Color.labelTertiary.opacity(0),
                            Color.labelTertiary.opacity(0.2),
                            Color.labelTertiary.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .rotationEffect(.degrees(22))
                    .offset(x: proxy.size.width * phase)
                    .frame(width: proxy.size.width * 1.65, height: proxy.size.height * 1.8)
                }
                .mask(content)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: false)) {
                    phase = 1.35
                }
            }
    }
}

extension View {
    /// Applies the shared loading shimmer used by skeleton states.
    func skeletonShimmer() -> some View {
        modifier(SkeletonShimmerModifier())
    }
}
