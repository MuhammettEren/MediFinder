import SwiftUI

/// Provider avatar placeholder used by cards, rows, and details.
struct ProviderAvatarView: View {
    let provider: Provider
    var size: CGFloat = 58

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.labelWhite)
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 5)

            Circle()
                .stroke(Color.solidPeriwinkle.opacity(0.42), lineWidth: 1.6)
                .frame(width: size - 4, height: size - 4)

            Image(systemName: provider.type.iconName)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(Color.labelTertiary.opacity(0.62))
        }
        .frame(width: size, height: size)
    }
}
