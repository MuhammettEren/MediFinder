import SwiftUI

/// Provider search result screen.
struct ProviderListView<ViewModel: ProviderListViewModelProtocol, FilterViewModelType: FilterViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let makeFilterViewModel: (FilterCriteria) -> FilterViewModelType
    let makeSearchViewModel: () -> ProviderSearchViewModel
    let onProviderSelected: (Provider) -> Void

    @State private var activeSheet: ProviderListSheet?
    @State private var filterViewModel: FilterViewModelType?
    @State private var cachedFilterViewModel: FilterViewModelType?
    @State private var isSearchPresented = false
    @State private var isPullRefreshArmed = false

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

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        pullRefreshReader
                        activeSearchQueryChip
                        filters
                        resultsHeader
                        content
                    }
                    .responsiveHorizontalPadding(percent: 0.043)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "providerListScroll")
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadProviders()
        }
        .task {
            await prepareFilterViewModel()
        }
        .sheet(item: $activeSheet) { sheet in
            presentedSheet(sheet)
                .presentationDetents(sheet == .sort ? [.fraction(0.48)] : [.fraction(0.82), .large])
                .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $isSearchPresented) {
            ProviderSearchView(
                viewModel: makeSearchViewModel(),
                onSearchSubmitted: { query in
                    viewModel.updateSearchText(query)
                    isSearchPresented = false
                },
                onProviderSelected: { provider in
                    isSearchPresented = false
                    onProviderSelected(provider)
                }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 22) {
            SearchLaunchBarView(title: "Doktor, klinik veya tedavi...", showsBackButton: false) {
            } onTap: {
                isSearchPresented = true
            }
            .padding(.top, 18)
        }
        .padding(.bottom, 28)
        .background(Color.systemBGQuaternary.opacity(0.45))
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterPillButton(title: countryFilterTitle, isActive: viewModel.activeFilter.selectedCountry != nil, clearAction: {
                    viewModel.removeCountryFilter()
                }) {
                    presentFilterSheet(.country)
                }

                FilterPillButton(title: cityFilterTitle, isActive: viewModel.activeFilter.selectedCity != nil, clearAction: {
                    viewModel.removeCityFilter()
                }) {
                    presentFilterSheet(.city)
                }

                FilterPillButton(title: servicesFilterTitle, isActive: !viewModel.activeFilter.selectedSpecialties.isEmpty, clearAction: {
                    viewModel.clearSpecialtyFilters()
                }) {
                    presentFilterSheet(.services)
                }

                FilterPillButton(title: roleFilterTitle, isActive: viewModel.activeFilter.selectedType != nil, clearAction: {
                    viewModel.removeTypeFilter()
                }) {
                    presentFilterSheet(.role)
                }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var activeSearchQueryChip: some View {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !query.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.bodySmall(.semibold))
                    .foregroundStyle(Color.labelSecondary)

                Text(query)
                    .font(.bodyMedium(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .lineLimit(1)

                Button {
                    viewModel.clearSearchText()
                } label: {
                    Image(systemName: "xmark")
                        .font(.bodySmall(.bold))
                        .foregroundStyle(Color.labelWhite)
                        .frame(width: 22, height: 22)
                        .background(Color.actionBlue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Arama terimini temizle")
            }
            .padding(.leading, 12)
            .padding(.trailing, 8)
            .frame(height: 42)
            .background(Color.systemBGSecondary.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var resultsHeader: some View {
        HStack {
            Text(viewModel.resultCountText)
                .font(.bodyMedium(.medium))
                .foregroundStyle(Color.labelPrimary)

            Spacer()

            Button {
                activeSheet = .sort
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.sortOption.displayName)
                        .font(.bodyLarge(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.bodyMedium(.semibold))
                }
                .foregroundStyle(Color.labelPrimary)
            }
            .accessibilityLabel("Sonuçları sırala")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            skeletonGrid
        case .loaded:
            providerGrid
        case .empty(let message):
            EmptyStateView(title: "Sonuç yok", message: message)
                .padding(.top, 40)
        case .error(let message):
            ErrorStateView(message: message) {
                Task {
                    await viewModel.retryLoading()
                }
            }
            .padding(.top, 40)
        }
    }

    private var providerGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            if viewModel.isRefreshing {
                ForEach(0..<6, id: \.self) { _ in
                    ProviderCardSkeletonView()
                }
            } else {
                ForEach(Array(viewModel.filteredProviders.enumerated()), id: \.element.id) { index, provider in
                    Button {
                        onProviderSelected(provider)
                    } label: {
                        ProviderCardView(provider: provider)
                            .staggeredListItem(index: index)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var skeletonGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                ProviderCardSkeletonView()
            }
        }
    }

    private var pullRefreshReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: PullRefreshOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("providerListScroll")).minY
                )
        }
        .frame(height: 1)
        .onPreferenceChange(PullRefreshOffsetPreferenceKey.self) { offset in
            handlePullRefresh(offset: offset)
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    private var countryFilterTitle: String {
        guard let country = viewModel.activeFilter.selectedCountry else {
            return "Ülke"
        }

        return country.displayName
    }

    private var servicesFilterTitle: String {
        guard let first = viewModel.activeFilter.selectedSpecialties.first else {
            return "Servisler"
        }

        let extraCount = viewModel.activeFilter.selectedSpecialties.count - 1
        return extraCount > 0 ? "\(first.displayName) +\(extraCount)" : first.displayName
    }

    private var cityFilterTitle: String {
        viewModel.activeFilter.selectedCity ?? "Şehir"
    }

    private var roleFilterTitle: String {
        viewModel.activeFilter.selectedType?.displayName ?? "Rol"
    }

    private func presentFilterSheet(_ sheet: ProviderListSheet) {
        if let cachedFilterViewModel {
            cachedFilterViewModel.criteria = viewModel.activeFilter
            filterViewModel = cachedFilterViewModel

            Task {
                await cachedFilterViewModel.loadFilters()
            }
        } else {
            let nextViewModel = makeFilterViewModel(viewModel.activeFilter)
            filterViewModel = nextViewModel
            cachedFilterViewModel = nextViewModel

            Task {
                await nextViewModel.loadFilters()
            }
        }

        activeSheet = sheet
    }

    private func prepareFilterViewModel() async {
        guard cachedFilterViewModel == nil else {
            return
        }

        let nextViewModel = makeFilterViewModel(viewModel.activeFilter)
        cachedFilterViewModel = nextViewModel
        await nextViewModel.loadFilters()
    }

    private func handlePullRefresh(offset: CGFloat) {
        let threshold: CGFloat = .responsiveValue(iPhone: 74, iPad: 96)

        guard offset > threshold, !isPullRefreshArmed, !viewModel.isRefreshing else {
            if offset < 8 {
                isPullRefreshArmed = false
            }
            return
        }

        isPullRefreshArmed = true

        Task {
            await viewModel.loadProviders()
        }
    }

    @ViewBuilder
    private func presentedSheet(_ sheet: ProviderListSheet) -> some View {
        let resolvedFilterViewModel = filterViewModel ?? cachedFilterViewModel

        switch sheet {
        case .country:
            if let resolvedFilterViewModel {
                CountryFilterSheet(viewModel: resolvedFilterViewModel) {
                    viewModel.applyFilter(resolvedFilterViewModel.criteria)
                    activeSheet = nil
                } onDismiss: {
                    activeSheet = nil
                }
            }
        case .city:
            if let resolvedFilterViewModel {
                CityFilterSheet(viewModel: resolvedFilterViewModel) {
                    viewModel.applyFilter(resolvedFilterViewModel.criteria)
                    activeSheet = nil
                } onDismiss: {
                    activeSheet = nil
                }
            }
        case .services:
            if let resolvedFilterViewModel {
                ServiceFilterSheet(viewModel: resolvedFilterViewModel) {
                    viewModel.applyFilter(resolvedFilterViewModel.criteria)
                    activeSheet = nil
                } onDismiss: {
                    activeSheet = nil
                }
            }
        case .role:
            if let resolvedFilterViewModel {
                RoleFilterSheet(viewModel: resolvedFilterViewModel) {
                    viewModel.applyFilter(resolvedFilterViewModel.criteria)
                    activeSheet = nil
                } onDismiss: {
                    activeSheet = nil
                }
            }
        case .sort:
            SortOptionsSheetView(selectedOption: viewModel.sortOption) { option in
                viewModel.selectSortOption(option)
            } onDismiss: {
                activeSheet = nil
            }
        }
    }
}

private struct PullRefreshOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private enum ProviderListSheet: String, Identifiable {
    case country
    case city
    case services
    case role
    case sort

    var id: String { rawValue }
}
