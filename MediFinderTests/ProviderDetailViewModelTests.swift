import XCTest
@testable import MediFinder

final class ProviderDetailViewModelTests: XCTestCase {
    @MainActor
    func testLoadProviderDetailSetsLoadedProvider() async {
        let viewModel = ProviderDetailViewModel(providerService: MockProviderService(delay: .zero), providerId: "tr-001")

        await viewModel.loadProviderDetail()

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.provider?.name, "Nadiye Haciomeroglu")
        XCTAssertEqual(viewModel.provider?.contactInfo.phone, "+90 212 555 0001")
    }

    @MainActor
    func testLoadProviderDetailWithMissingIdSetsUserFacingError() async {
        let viewModel = ProviderDetailViewModel(providerService: MockProviderService(delay: .zero), providerId: "missing")

        await viewModel.loadProviderDetail()

        XCTAssertEqual(viewModel.viewState, .error(message: "Bu sağlık hizmetine şu anda ulaşılamıyor."))
        XCTAssertNil(viewModel.provider)
    }
}
