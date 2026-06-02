import Foundation

/// Defines read operations for provider discovery data.
protocol ProviderServiceProtocol: Sendable {
    func fetchProviders() async throws -> [Provider]
    func fetchProvider(by id: String) async throws -> Provider
    func availableCountries() async throws -> [Country]
    func availableCities(for country: Country) async throws -> [String]
}
