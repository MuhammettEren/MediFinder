import SwiftUI

/// Bottom sheet selectable row with radio or check state.
struct SelectableRowView: View {
    let title: String
    var subtitle: String?
    var leadingContent: AnyView? = nil
    let isSelected: Bool
    let allowsMultipleSelection: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let leadingContent {
                    leadingContent
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.bodyXLarge(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                        .multilineTextAlignment(.leading)

                    if let subtitle {
                        Text(subtitle)
                            .font(.bodyLarge(.regular))
                            .foregroundStyle(Color.labelTertiary)
                    }
                }

                Spacer()

                selectionIndicator
            }
            .padding(.horizontal, 24)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.actionBlue : Color.labelTertiary.opacity(0.4), lineWidth: 3)
                .frame(width: 26, height: 26)

            if isSelected {
                if allowsMultipleSelection {
                    Image(systemName: "checkmark")
                        .font(.bodyMedium(.bold))
                        .foregroundStyle(Color.labelWhite)
                        .frame(width: 26, height: 26)
                        .background(Color.actionBlue)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.actionBlue)
                        .frame(width: 12, height: 12)
                }
            }
        }
    }
}
