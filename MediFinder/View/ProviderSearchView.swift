import SwiftUI

/// Full-screen search flow with recent searches and ranked results.
struct ProviderSearchView<ViewModel: ProviderSearchViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let onSearchSubmitted: (String) -> Void
    let onProviderSelected: (Provider) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.labelWhite
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                SearchTabBarView(tabs: SearchTab.allCases, selectedTab: viewModel.selectedSearchTab) { tab in
                    viewModel.selectSearchTab(tab)
                }
                Divider()
                content
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var header: some View {
        SearchHeaderView(
            text: searchTextBinding,
            placeholder: "Doktor, klinik veya tedavi..."
        ) {
            dismiss()
        } onClear: {
            viewModel.clearSearchText()
        } onSubmit: {
            viewModel.submitSearch()
        }
        .padding(.top, 18)
        .padding(.bottom, 22)
        .background(Color.systemBGQuaternary.opacity(0.45))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            recentSearches
        } else {
            searchResults
        }
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Son aramalar")
                    .font(.h5(.bold))
                    .foregroundStyle(Color.labelPrimary)

                Spacer()

                Button("Temizle") {
                    viewModel.clearRecentSearches()
                }
                .font(.bodyLarge(.regular))
                .foregroundStyle(Color.labelPrimary)
                .opacity(viewModel.recentSearches.isEmpty ? 0 : 1)
            }

            VStack(alignment: .leading, spacing: 18) {
                ForEach(viewModel.recentSearches, id: \.self) { query in
                    Button {
                        viewModel.selectRecentSearch(query)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "clock")
                                .font(.h5(.regular))
                                .foregroundStyle(Color.labelTertiary)

                            Text(query)
                                .font(.bodyXLarge(.regular))
                                .foregroundStyle(Color.labelPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 36)
    }

    private var searchResults: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                searchSuggestion

                switch viewModel.viewState {
                case .loading:
                    LazyVStack(spacing: 18) {
                        ForEach(0..<4, id: \.self) { _ in
                            ProviderSearchResultSkeletonRow()
                        }
                    }
                case .loaded:
                    Text(viewModel.resultCountText)
                        .font(.bodyLarge(.regular))
                        .foregroundStyle(Color.labelTertiary)

                    LazyVStack(spacing: 18) {
                        ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, provider in
                            Button {
                                viewModel.submitSearch()
                                onProviderSelected(provider)
                            } label: {
                                ProviderSearchResultRow(provider: provider)
                                    .staggeredListItem(index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                case .empty(let message):
                    EmptyStateView(title: "Sonuç yok", message: message)
                        .padding(.top, 40)
                case .error(let message):
                    ErrorStateView(message: message) {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .padding(.top, 40)
                case .idle:
                    EmptyView()
                }
            }
            .responsiveHorizontalPadding(percent: 0.043)
            .padding(.top, 22)
            .padding(.bottom, 28)
        }
    }

    private var searchSuggestion: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.h4(.regular))
                .foregroundStyle(Color.labelSecondary)

            Text(viewModel.searchText)
                .font(.bodyXLarge(.regular))
                .foregroundStyle(Color.labelSecondary)

            Spacer()

            Text(viewModel.resultCountText)
                .font(.bodyLarge(.semibold))
                .foregroundStyle(Color.labelPrimary)

            Button {
                viewModel.submitSearch()
                onSearchSubmitted(viewModel.searchText)
            } label: {
                Image(systemName: "arrow.up.right")
                    .font(.bodyLarge(.semibold))
                    .foregroundStyle(Color.labelPrimary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sonuç listesine git")
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(Color.systemBGSecondary.opacity(0.55))
        .clipShape(Capsule())
    }

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.updateSearchText($0) }
        )
    }
}

/// Compact search result row used inside the dedicated search page.
private struct ProviderSearchResultRow: View {
    let provider: Provider

    var body: some View {
        HStack(spacing: 14) {
            ProviderAvatarView(provider: provider, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(provider.name)
                    .font(.bodyXXLarge(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(provider.specialty.displayName)
                        .foregroundStyle(Color.actionBlue)
                    Text("·")
                        .foregroundStyle(Color.labelTertiary)
                    Text("Açık")
                        .foregroundStyle(Color.actionGreen)
                }
                .font(.bodyMedium(.semibold))

                HStack(spacing: 6) {
                    CountryFlagView(country: provider.location.country, size: 16)

                    Text(provider.location.formattedLocation)
                        .font(.bodyMedium(.regular))
                        .lineLimit(1)
                        .foregroundStyle(Color.labelSecondary)
                }
            }

            Spacer()
        }
    }
}

private struct ProviderSearchResultSkeletonRow: View {
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.systemBGTertiary)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 8) {
                Capsule()
                    .fill(Color.systemBGTertiary)
                    .frame(width: .widthPer(per: 0.34), height: 18)

                Capsule()
                    .fill(Color.systemBGTertiary)
                    .frame(width: .widthPer(per: 0.22), height: 14)

                Capsule()
                    .fill(Color.systemBGTertiary)
                    .frame(width: .widthPer(per: 0.30), height: 14)
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .skeletonShimmer()
        .accessibilityHidden(true)
    }
}
