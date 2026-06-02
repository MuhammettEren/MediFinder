import Foundation
import Combine

/// Represents the render state for the provider list.
enum ProviderListViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty(message: String)
    case error(message: String)
}

/// Defines the business interface consumed by the provider list view.
@MainActor
protocol ProviderListViewModelProtocol: ObservableObject {
    var viewState: ProviderListViewState { get }
    var searchText: String { get set }
    var filteredProviders: [Provider] { get }
    var activeFilter: FilterCriteria { get set }
    var sortOption: SortOption { get set }
    var selectedSearchTab: SearchTab { get set }
    var isRefreshing: Bool { get }
    var resultCountText: String { get }
    var hasActiveFilters: Bool { get }
    func loadProviders() async
    func retryLoading() async
    func updateSearchText(_ text: String)
    func clearSearchText()
    func selectSearchTab(_ tab: SearchTab)
    func applyFilter(_ filter: FilterCriteria)
    func selectSortOption(_ option: SortOption)
    func removeCountryFilter()
    func removeCityFilter()
    func clearSpecialtyFilters()
    func removeSpecialtyFilter(_ specialty: Specialty)
    func removeTypeFilter()
}

/// Search result sections shown in the top segmented bar.
enum SearchTab: String, CaseIterable, Identifiable {
    case all
    case providers
    case organizations

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "Tümü"
        case .providers: "Uzmanlar"
        case .organizations: "Kuruluşlar"
        }
    }
}

/// Manages provider fetching, searching, filtering, sorting, and retry behavior.
@MainActor
final class ProviderListViewModel: ProviderListViewModelProtocol {
    @Published private(set) var viewState: ProviderListViewState = .idle
    @Published var searchText: String = "" {
        didSet {
            updateStateForCurrentResults()
        }
    }
    @Published var activeFilter = FilterCriteria() {
        didSet {
            updateStateForCurrentResults()
        }
    }
    @Published var sortOption: SortOption = .newest {
        didSet {
            updateStateForCurrentResults()
        }
    }
    @Published var selectedSearchTab: SearchTab = .providers {
        didSet {
            updateStateForCurrentResults()
        }
    }
    @Published private(set) var isRefreshing = false

    private let providerService: ProviderServiceProtocol
    private var allProviders: [Provider] = []
    private var loadGeneration = 0

    var filteredProviders: [Provider] {
        sortedProviders(searchFilteredProviders)
    }

    var resultCountText: String {
        "\(filteredProviders.count) sonuç"
    }

    var hasActiveFilters: Bool {
        !activeFilter.isEmpty
    }

    /// Creates a provider list view model.
    /// - Parameter providerService: Data source used for provider retrieval.
    init(providerService: ProviderServiceProtocol) {
        self.providerService = providerService
    }

    /// Loads provider data and updates the list render state.
    func loadProviders() async {
        loadGeneration += 1
        let currentGeneration = loadGeneration
        isRefreshing = !allProviders.isEmpty

        if !isRefreshing {
            viewState = .loading
        }

        do {
            let providers = try await providerService.fetchProviders()

            guard currentGeneration == loadGeneration else {
                return
            }

            allProviders = providers
            isRefreshing = false
            updateStateForCurrentResults()
        } catch is CancellationError {
            if currentGeneration == loadGeneration {
                isRefreshing = false
                viewState = .idle
            }
        } catch {
            if currentGeneration == loadGeneration {
                isRefreshing = false
                viewState = .error(message: error.providerUserFacingMessage)
            }
        }
    }

    /// Retries provider loading after an error.
    func retryLoading() async {
        await loadProviders()
    }

    /// Updates the search query.
    /// - Parameter text: Search text entered by the user.
    func updateSearchText(_ text: String) {
        searchText = text
    }

    /// Clears the current search query.
    func clearSearchText() {
        searchText = ""
    }

    /// Selects the visible search section.
    /// - Parameter tab: Search tab selected by the user.
    func selectSearchTab(_ tab: SearchTab) {
        selectedSearchTab = tab
    }

    /// Applies filter criteria to the provider list.
    /// - Parameter filter: New filter criteria.
    func applyFilter(_ filter: FilterCriteria) {
        activeFilter = filter
    }

    /// Selects the result ordering strategy.
    /// - Parameter option: Sort option selected by the user.
    func selectSortOption(_ option: SortOption) {
        sortOption = option
    }

    /// Clears the selected country filter.
    func removeCountryFilter() {
        activeFilter.selectedCountry = nil
        activeFilter.selectedCity = nil
    }

    /// Clears the selected city filter.
    func removeCityFilter() {
        activeFilter.selectedCity = nil
    }

    /// Clears all selected specialty filters.
    func clearSpecialtyFilters() {
        activeFilter.selectedSpecialties.removeAll()
    }

    /// Removes a selected specialty filter.
    /// - Parameter specialty: Specialty to remove from the current criteria.
    func removeSpecialtyFilter(_ specialty: Specialty) {
        activeFilter.selectedSpecialties.remove(specialty)
    }

    /// Clears the selected provider type filter.
    func removeTypeFilter() {
        activeFilter.selectedType = nil
    }

    private var searchFilteredProviders: [Provider] {
        allProviders.filter { provider in
            tabMatches(provider) && searchMatches(provider) && filterMatches(provider)
        }
    }

    private func tabMatches(_ provider: Provider) -> Bool {
        switch selectedSearchTab {
        case .all:
            true
        case .providers:
            provider.type == .doctor || provider.type == .specialist
        case .organizations:
            provider.type == .clinic || provider.type == .hospital
        }
    }

    private func searchMatches(_ provider: Provider) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return true
        }

        return provider.searchScore(matching: query) > 0
    }

    private func filterMatches(_ provider: Provider) -> Bool {
        if let country = activeFilter.selectedCountry, provider.location.country != country {
            return false
        }

        if let city = activeFilter.selectedCity, provider.location.city != city {
            return false
        }

        if !activeFilter.selectedSpecialties.isEmpty, !activeFilter.selectedSpecialties.contains(provider.specialty) {
            return false
        }

        if let type = activeFilter.selectedType, provider.type != type {
            return false
        }

        return true
    }

    private func sortedProviders(_ providers: [Provider]) -> [Provider] {
        switch sortOption {
        case .newest:
            providers
        case .highestRated:
            providers.sorted { $0.rating > $1.rating }
        case .mostReviewed, .mostRecommended:
            providers.sorted { $0.reviewCount > $1.reviewCount }
        case .nearest:
            providers.sorted { $0.location.city < $1.location.city }
        }
    }

    private func updateStateForCurrentResults() {
        guard !allProviders.isEmpty else {
            viewState = .idle
            return
        }

        viewState = filteredProviders.isEmpty
            ? .empty(message: "Aramana uygun sonuç bulunamadı.")
            : .loaded
    }
}
