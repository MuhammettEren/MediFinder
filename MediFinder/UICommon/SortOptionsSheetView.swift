import SwiftUI

/// Bottom sheet for choosing result sort order.
struct SortOptionsSheetView: View {
    let selectedOption: SortOption
    let onSelect: (SortOption) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.labelTertiary.opacity(0.25))
                .frame(width: 44, height: 6)
                .padding(.top, 14)

            Text("Sonuçları sırala")
                .font(.h4(.bold))
                .foregroundStyle(Color.labelPrimary)
                .padding(.top, 42)
                .padding(.bottom, 42)

            ForEach(SortOption.allCases) { option in
                SelectableRowView(
                    title: option.displayName,
                    isSelected: selectedOption == option,
                    allowsMultipleSelection: false
                ) {
                    onSelect(option)
                    onDismiss()
                }

                Divider()
                    .padding(.horizontal, 24)
            }

            Spacer(minLength: 24)
        }
        .background(Color.labelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
    }
}
