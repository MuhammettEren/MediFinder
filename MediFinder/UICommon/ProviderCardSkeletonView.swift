import SwiftUI

/// Skeleton card used while refreshing provider results.
struct ProviderCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                shimmerCircle(size: 54)
                Spacer()
                shimmerCircle(size: 54)
            }

            VStack(alignment: .leading, spacing: 8) {
                shimmerCapsule(width: .widthPer(per: 0.26), height: 18)
                shimmerCapsule(width: .widthPer(per: 0.20), height: 18)
            }
            .frame(height: 52, alignment: .bottomLeading)

            shimmerCapsule(width: .widthPer(per: 0.25), height: 30)
            shimmerCapsule(width: .widthPer(per: 0.28), height: 28)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 198, alignment: .topLeading)
        .background(Color.labelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.labelTertiary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 10, x: 0, y: 7)
        .skeletonShimmer()
        .accessibilityHidden(true)
    }

    private func shimmerCircle(size: CGFloat) -> some View {
        Circle()
            .fill(Color.systemBGTertiary)
            .frame(width: size, height: size)
    }

    private func shimmerCapsule(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color.systemBGTertiary)
            .frame(width: width, height: height)
    }
}
