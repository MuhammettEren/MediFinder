import XCTest
@testable import MediFinder

final class MockProviderServiceTests: XCTestCase {
    @MainActor
    func testFetchProvidersReturnsMockCatalog() async throws {
        let service = MockProviderService(delay: .zero)

        let providers = try await service.fetchProviders()

        XCTAssertEqual(providers.count, 20)
    }

    @MainActor
    func testFetchProviderByValidIdReturnsProvider() async throws {
        let service = MockProviderService(delay: .zero)

        let provider = try await service.fetchProvider(by: "tr-004")

        XCTAssertEqual(provider.name, "Dentacare Clinic")
    }

    @MainActor
    func testFetchProviderByInvalidIdThrowsProviderNotFound() async {
        let service = MockProviderService(delay: .zero)

        do {
            _ = try await service.fetchProvider(by: "missing")
            XCTFail("Expected providerNotFound")
        } catch let error as ProviderServiceError {
            XCTAssertEqual(error, .providerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testShouldFailThrowsNetworkUnavailable() async {
        let service = MockProviderService(shouldFail: true, delay: .zero)

        do {
            _ = try await service.fetchProviders()
            XCTFail("Expected networkUnavailable")
        } catch let error as ProviderServiceError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
