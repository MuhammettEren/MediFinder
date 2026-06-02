import SwiftUI

/// Reusable rounded bottom sheet with search and selectable rows.
struct BottomSheetSelectorView<Item: Identifiable>: View {
    let title: String
    let searchPlaceholder: String
    let items: [Item]
    let allowsMultipleSelection: Bool
    let titleProvider: (Item) -> String
    let subtitleProvider: (Item) -> String?
    var leadingContentProvider: ((Item) -> AnyView)? = nil
    let isSelected: (Item) -> Bool
    let onToggle: (Item) -> Void
    let onDone: () -> Void
    let onDismiss: () -> Void

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.labelTertiary.opacity(0.25))
                .frame(width: 44, height: 6)
                .padding(.top, 10)

            ZStack {
                Text(title)
                    .font(.h4(.bold))
                    .foregroundStyle(Color.labelPrimary)
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.bodyXLarge(.semibold))
                            .foregroundStyle(Color.labelPrimary)
                            .frame(width: 46, height: 46)
                            .background(Color.systemBGSecondary)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Kapat")
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)

            BottomSheetSearchField(placeholder: searchPlaceholder, text: $searchText)
                .padding(.horizontal, 22)
                .padding(.vertical, 24)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(filteredItems) { item in
                        SelectableRowView(
                            title: titleProvider(item),
                            subtitle: subtitleProvider(item),
                            leadingContent: leadingContentProvider?(item),
                            isSelected: isSelected(item),
                            allowsMultipleSelection: allowsMultipleSelection
                        ) {
                            onToggle(item)
                        }

                        Divider()
                            .padding(.leading, 24)
                    }
                }
                .padding(.bottom, 112)
            }

            MainReusableButton(title: "Bitti", style: .custom(bg: .actionBlue, fg: .labelWhite), height: 54) {
                onDone()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(Color.labelWhite)
        }
        .background(Color.labelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
    }

    private var filteredItems: [Item] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return items
        }

        return items.filter {
            titleProvider($0).localizedCaseInsensitiveContains(query)
                || (subtitleProvider($0)?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}

private struct BottomSheetSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(.bodyXLarge(.regular))
                .foregroundStyle(Color.labelPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.bodyMedium(.semibold))
                        .foregroundStyle(Color.labelTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Aramayı temizle")
            }

            Image(systemName: "magnifyingglass")
                .font(.h5(.semibold))
                .foregroundStyle(Color.actionBlue)
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
}
