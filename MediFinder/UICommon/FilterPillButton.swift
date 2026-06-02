import SwiftUI

/// Rounded filter button used above search results.
struct FilterPillButton: View {
    let title: String
    var isActive: Bool = false
    var clearAction: (() -> Void)?
    let action: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: action) {
                HStack(spacing: 10) {
                    Text(title)
                        .font(.bodyLarge(.medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .foregroundStyle(Color.labelPrimary)

                    Image(systemName: "chevron.down")
                        .font(.bodyMedium(.semibold))
                        .foregroundStyle(Color.labelTertiary)
                }
                .frame(height: 44)
            }
            .buttonStyle(.plain)

            if isActive, let clearAction {
                Button(action: clearAction) {
                    Image(systemName: "xmark")
                        .font(.bodySmall(.bold))
                        .foregroundStyle(Color.labelWhite)
                        .frame(width: 22, height: 22)
                        .background(Color.actionBlue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(title) filtresini temizle")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, isActive && clearAction != nil ? 10 : 14)
        .frame(height: 52)
        .background(isActive ? Color.actionBlue.opacity(0.08) : Color.labelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(isActive ? Color.actionBlue.opacity(0.36) : Color.labelTertiary.opacity(0.28), lineWidth: 1.45)
        )
        .accessibilityLabel(title)
    }
}
