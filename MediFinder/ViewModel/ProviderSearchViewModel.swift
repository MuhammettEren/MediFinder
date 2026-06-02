import Foundation
import Combine

/// Render state for the full-screen provider search flow.
enum ProviderSearchViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty(message: String)
    case error(message: String)
}

/// Defines the business interface consumed by provider search UI.
@MainActor
protocol ProviderSearchViewModelProtocol: ObservableObject {
    var viewState: ProviderSearchViewState { get }
    var searchText: String { get set }
    var selectedSearchTab: SearchTab { get set }
    var recentSearches: [String] { get }
    var results: [Provider] { get }
    var resultCountText: String { get }
    func load() async
    func updateSearchText(_ text: String)
    func clearSearchText()
    func clearRecentSearches()
    func submitSearch()
    func selectRecentSearch(_ text: String)
    func selectSearchTab(_ tab: SearchTab)
}

/// Manages the dedicated search screen, recent searches, and ranked local matching.
@MainActor
final class ProviderSearchViewModel: ProviderSearchViewModelProtocol {
    @Published private(set) var viewState: ProviderSearchViewState = .idle
    @Published var searchText = "" {
        didSet {
            updateResults()
        }
    }
    @Published var selectedSearchTab: SearchTab = .all {
        didSet {
            updateResults()
        }
    }
    @Published private(set) var recentSearches: [String] = ["diş hekimi"]

    private let providerService: ProviderServiceProtocol
    private var providers: [Provider] = []
    private var rankedResults: [Provider] = []
    private var loadGeneration = 0

    var results: [Provider] {
        rankedResults
    }

    var resultCountText: String {
        "\(results.count) sonuç"
    }

    /// Creates a search view model.
    /// - Parameter providerService: Data source used for provider retrieval.
    init(providerService: ProviderServiceProtocol) {
        self.providerService = providerService
    }

    /// Loads searchable provider data.
    func load() async {
        loadGeneration += 1
        let currentGeneration = loadGeneration
        viewState = .loading

        do {
            let providers = try await providerService.fetchProviders()

            guard currentGeneration == loadGeneration else {
                return
            }

            self.providers = providers
            updateResults()
        } catch is CancellationError {
            if currentGeneration == loadGeneration {
                viewState = .idle
            }
        } catch {
            if currentGeneration == loadGeneration {
                viewState = .error(message: error.providerUserFacingMessage)
            }
        }
    }

    /// Updates the active query.
    /// - Parameter text: Query entered by the user.
    func updateSearchText(_ text: String) {
        searchText = text
    }

    /// Clears the active query.
    func clearSearchText() {
        searchText = ""
    }

    /// Clears all recent searches.
    func clearRecentSearches() {
        recentSearches.removeAll()
    }

    /// Persists the current query into recent searches.
    func submitSearch() {
        let query = normalizedDisplayQuery(searchText)

        guard !query.isEmpty else {
            return
        }

        recentSearches.removeAll { $0.normalizedForSearch == query.normalizedForSearch }
        recentSearches.insert(query, at: 0)
        recentSearches = Array(recentSearches.prefix(6))
        updateResults()
    }

    /// Selects a recent search as the active query.
    /// - Parameter text: Recent query text.
    func selectRecentSearch(_ text: String) {
        searchText = text
    }

    /// Selects the active search result section.
    /// - Parameter tab: Section selected by the user.
    func selectSearchTab(_ tab: SearchTab) {
        selectedSearchTab = tab
    }

    private func updateResults() {
        guard !providers.isEmpty else {
            viewState = .idle
            rankedResults = []
            return
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            rankedResults = []
            viewState = .idle
            return
        }

        rankedResults = providers
            .filter(tabMatches)
            .compactMap { provider in
                rankedProvider(provider, query: query)
            }
            .sorted { lhs, rhs in
                lhs.score == rhs.score ? lhs.provider.reviewCount > rhs.provider.reviewCount : lhs.score > rhs.score
            }
            .map(\.provider)

        viewState = rankedResults.isEmpty
            ? .empty(message: "Aramana uygun sonuç bulunamadı.")
            : .loaded
    }

    private func rankedProvider(_ provider: Provider, query: String) -> (provider: Provider, score: Int)? {
        let score = provider.searchScore(matching: query)

        return score > 0 ? (provider, score) : nil
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

    private func normalizedDisplayQuery(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

private extension String {
    var normalizedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
