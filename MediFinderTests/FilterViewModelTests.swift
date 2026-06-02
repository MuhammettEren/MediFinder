import XCTest
@testable import MediFinder

final class FilterViewModelTests: XCTestCase {
    @MainActor
    func testLoadFiltersReturnsCountries() async {
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: FilterCriteria())

        await viewModel.loadFilters()

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.countries.count, Country.allCases.count)
    }

    @MainActor
    func testSelectingCountryLoadsCities() async {
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: FilterCriteria())

        await viewModel.loadFilters()
        viewModel.selectCountry(.turkey)
        await viewModel.loadFilters()

        XCTAssertEqual(viewModel.criteria.selectedCountry, .turkey)
        XCTAssertTrue(viewModel.cities.contains("Istanbul"))
    }

    @MainActor
    func testLoadFiltersWithoutCountryReturnsAllProviderCities() async {
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: FilterCriteria())

        await viewModel.loadFilters()

        XCTAssertTrue(viewModel.cities.contains("Istanbul"))
        XCTAssertTrue(viewModel.cities.contains("Berlin"))
        XCTAssertTrue(viewModel.cities.contains("Poznan"))
    }

    @MainActor
    func testChangingCountryResetsCity() async {
        var criteria = FilterCriteria()
        criteria.selectedCountry = .turkey
        criteria.selectedCity = "Istanbul"
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: criteria)

        viewModel.selectCountry(.germany)

        XCTAssertNil(viewModel.criteria.selectedCity)
    }

    @MainActor
    func testResetClearsCriteria() async {
        var criteria = FilterCriteria()
        criteria.selectedCountry = .turkey
        criteria.selectedSpecialties = [.dentistry, .orthopedics]
        criteria.selectedType = .doctor
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: criteria)

        viewModel.reset()

        XCTAssertTrue(viewModel.criteria.isEmpty)
    }

    @MainActor
    func testToggleSpecialtyAddsAndRemovesSelection() async {
        let viewModel = FilterViewModel(providerService: MockProviderService(delay: .zero), criteria: FilterCriteria())

        viewModel.toggleSpecialty(.dentistry)
        XCTAssertTrue(viewModel.criteria.selectedSpecialties.contains(.dentistry))

        viewModel.toggleSpecialty(.dentistry)
        XCTAssertFalse(viewModel.criteria.selectedSpecialties.contains(.dentistry))
    }
}
