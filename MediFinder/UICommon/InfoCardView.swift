import SwiftUI

/// Detail information tile.
struct InfoCardView: View {
    let iconName: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.bodyXLarge(.semibold))
                .foregroundStyle(Color.actionBlue)

            Text(value)
                .font(.bodyLarge(.bold))
                .foregroundStyle(Color.labelPrimary)
                .lineLimit(1)

            Text(title)
                .font(.bodySmall(.regular))
                .foregroundStyle(Color.labelTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.systemBGSecondary.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
