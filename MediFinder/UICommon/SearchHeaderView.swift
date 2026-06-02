import SwiftUI

/// Search header with back, clear, and submit actions matching the MediFinder search flow.
struct SearchHeaderView: View {
    @Binding var text: String
    let placeholder: String
    var onBack: () -> Void
    var onClear: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.bodyLarge(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.systemBGSecondary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Geri")

            HStack(spacing: 12) {
                TextField(placeholder, text: $text)
                    .font(.bodyXLarge(.regular))
                    .foregroundStyle(Color.labelPrimary)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)

                if !text.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark")
                            .font(.bodyLarge(.semibold))
                            .foregroundStyle(Color.labelTertiary)
                    }
                    .accessibilityLabel("Aramayi temizle")
                }

                Rectangle()
                    .fill(Color.labelTertiary.opacity(0.35))
                    .frame(width: 1, height: 28)

                Button(action: onSubmit) {
                    Image(systemName: "magnifyingglass")
                        .font(.h5(.semibold))
                        .foregroundStyle(Color.actionBlue)
                }
                .accessibilityLabel("Ara")
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.labelWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.labelTertiary.opacity(0.22), lineWidth: 1.2)
            )
        }
        .responsiveHorizontalPadding(percent: 0.043)
    }
}
