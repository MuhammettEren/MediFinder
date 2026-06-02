import XCTest
@testable import MediFinder

final class ProviderListViewModelTests: XCTestCase {
    @MainActor
    func testLoadProvidersSetsLoadedState() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.filteredProviders.count, 20)
    }

    @MainActor
    func testFailedLoadSetsErrorState() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(shouldFail: true, delay: .zero))

        await viewModel.loadProviders()

        guard case .error = viewModel.viewState else {
            XCTFail("Expected error state")
            return
        }
    }

    @MainActor
    func testSearchByDentistryReturnsDentists() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.searchText = "dentist"

        XCTAssertEqual(viewModel.filteredProviders.count, 4)
    }

    @MainActor
    func testSearchByDentistryPhraseReturnsDentists() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.searchText = "diş hekimi"

        XCTAssertEqual(viewModel.filteredProviders.count, 4)
    }

    @MainActor
    func testDedicatedSearchByDentistryPhraseReturnsDentists() async {
        let viewModel = ProviderSearchViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.load()
        viewModel.updateSearchText("diş hekimi")

        XCTAssertEqual(viewModel.results.count, 4)
    }

    @MainActor
    func testCountryFilterReturnsCountryProviders() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.activeFilter.selectedCountry = .turkey

        XCTAssertEqual(viewModel.filteredProviders.count, 7)
    }

    @MainActor
    func testCityFilterReturnsCityProviders() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.activeFilter.selectedCity = "Istanbul"

        XCTAssertEqual(Set(viewModel.filteredProviders.map(\.location.city)), ["Istanbul"])
        XCTAssertEqual(viewModel.filteredProviders.count, 3)
    }

    @MainActor
    func testSpecialtyAndTypeFiltersReturnIntersection() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.activeFilter.selectedSpecialties = [.ophthalmology]
        viewModel.activeFilter.selectedType = .hospital

        XCTAssertEqual(viewModel.filteredProviders.map(\.name), ["Ozel Egeumut Hastanesi", "test hospital"])
    }

    @MainActor
    func testFilterAndSearchReturnsIntersection() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.activeFilter.selectedCountry = .poland
        viewModel.searchText = "physiatrist"

        XCTAssertEqual(viewModel.filteredProviders.map(\.name), ["Julia Wisniewska"])
    }

    @MainActor
    func testHighestRatedSortOrdersResultsByRating() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.selectSortOption(.highestRated)

        XCTAssertEqual(viewModel.filteredProviders.prefix(3).map(\.name), ["Serkan Aygin", "Dr. James Wilson", "Mayo Clinic LA"])
    }

    @MainActor
    func testEmptySearchSetsEmptyState() async {
        let viewModel = ProviderListViewModel(providerService: MockProviderService(delay: .zero))
        viewModel.selectedSearchTab = .all

        await viewModel.loadProviders()
        viewModel.searchText = "not-a-real-provider"

        XCTAssertEqual(viewModel.viewState, .empty(message: "Aramana uygun sonuç bulunamadı."))
    }
}
