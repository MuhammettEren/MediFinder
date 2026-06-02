import SwiftUI

/// Non-editable search bar that opens the dedicated search flow.
struct SearchLaunchBarView: View {
    let title: String
    let showsBackButton: Bool
    var onBack: () -> Void
    var onTap: () -> Void

    /// Creates a launch-only search bar.
    /// - Parameters:
    ///   - title: Placeholder or current query.
    ///   - showsBackButton: Controls the optional leading back button.
    ///   - onBack: Back action when visible.
    ///   - onTap: Search launch action.
    init(title: String, showsBackButton: Bool = true, onBack: @escaping () -> Void, onTap: @escaping () -> Void) {
        self.title = title
        self.showsBackButton = showsBackButton
        self.onBack = onBack
        self.onTap = onTap
    }

    var body: some View {
        HStack(spacing: 12) {
            if showsBackButton {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.bodyLarge(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                        .frame(width: 48, height: 48)
                        .background(Color.systemBGSecondary)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Geri")
            }

            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.bodyLarge(.regular))
                        .lineLimit(1)
                        .foregroundStyle(Color.labelTertiary)

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .font(.h5(.semibold))
                        .foregroundStyle(Color.actionBlue)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.labelWhite)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.labelTertiary.opacity(0.22), lineWidth: 1.2)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Arama aç")
        }
        .responsiveHorizontalPadding(percent: 0.043)
    }
}
