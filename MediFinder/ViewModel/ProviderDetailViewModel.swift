import Foundation
import Combine

/// Represents the render state for provider detail.
enum ProviderDetailViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(message: String)
}

/// Defines the business interface consumed by the provider detail view.
@MainActor
protocol ProviderDetailViewModelProtocol: ObservableObject {
    var viewState: ProviderDetailViewState { get }
    var provider: Provider? { get }
    func loadProviderDetail() async
    func retryLoading() async
}

/// Loads and owns one provider profile for the detail screen.
@MainActor
final class ProviderDetailViewModel: ProviderDetailViewModelProtocol {
    @Published private(set) var viewState: ProviderDetailViewState = .idle
    @Published private(set) var provider: Provider?

    private let providerService: ProviderServiceProtocol
    private let providerId: String
    private var loadGeneration = 0

    /// Creates a provider detail view model.
    /// - Parameters:
    ///   - providerService: Data source used for profile retrieval.
    ///   - providerId: Identifier of the profile to load.
    init(providerService: ProviderServiceProtocol, providerId: String) {
        self.providerService = providerService
        self.providerId = providerId
    }

    /// Loads the selected provider profile.
    func loadProviderDetail() async {
        if provider != nil, viewState == .loaded {
            return
        }

        loadGeneration += 1
        let currentGeneration = loadGeneration
        viewState = .loading

        do {
            let loadedProvider = try await providerService.fetchProvider(by: providerId)

            guard currentGeneration == loadGeneration else {
                return
            }

            provider = loadedProvider
            viewState = .loaded
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

    /// Retries loading the selected provider profile.
    func retryLoading() async {
        await loadProviderDetail()
    }
}
