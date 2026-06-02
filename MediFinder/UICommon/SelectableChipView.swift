import SwiftUI

/// Reusable capsule chip for categories and quick filters.
struct SelectableChipView: View {
    let title: String
    var iconName: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.bodyMedium(.semibold))
                }

                Text(title)
                    .font(.bodyMedium(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.labelWhite : Color.labelPrimary)
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background(isSelected ? Color.actionBlue : Color.labelWhite)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.labelTertiary.opacity(0.22), lineWidth: 1.2)
            )
            .shadow(color: isSelected ? Color.actionBlue.opacity(0.18) : Color.black.opacity(0.035), radius: 8, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
