import SwiftUI

/// Reusable empty state view.
struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Color.labelTertiary)

            Text(title)
                .font(.h5(.bold))
                .foregroundStyle(Color.labelPrimary)

            Text(message)
                .font(.bodyLarge(.regular))
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}
