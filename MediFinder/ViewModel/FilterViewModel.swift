import Foundation
import Combine

/// Represents the render state for the filter sheet.
enum FilterViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(message: String)
}

/// Defines filtering operations consumed by filter sheet views.
@MainActor
protocol FilterViewModelProtocol: ObservableObject {
    var viewState: FilterViewState { get }
    var criteria: FilterCriteria { get set }
    var countries: [Country] { get }
    var cities: [String] { get }
    var specialties: [Specialty] { get }
    var providerTypes: [ProviderType] { get }
    func loadFilters() async
    func selectCountry(_ country: Country?)
    func selectCity(_ city: String?)
    func toggleSpecialty(_ specialty: Specialty)
    func selectType(_ type: ProviderType?)
    func reset()
}

/// Manages available filter values and selected filter criteria.
@MainActor
final class FilterViewModel: FilterViewModelProtocol {
    @Published private(set) var viewState: FilterViewState = .idle
    @Published var criteria: FilterCriteria
    @Published private(set) var countries: [Country] = []
    @Published private(set) var cities: [String] = []

    let specialties = Specialty.allCases
    let providerTypes = ProviderType.allCases

    private let providerService: ProviderServiceProtocol
    private var didLoadCountries = false
    private var loadedCitiesCountry: Country?

    /// Creates a filter view model.
    /// - Parameters:
    ///   - providerService: Data source used for filter options.
    ///   - criteria: Initial selected filter criteria.
    init(providerService: ProviderServiceProtocol, criteria: FilterCriteria) {
        self.providerService = providerService
        self.criteria = criteria
    }

    /// Loads country and dependent city filter data.
    func loadFilters() async {
        guard viewState != .loading else {
            return
        }

        let shouldLoadCities = criteria.selectedCountry != loadedCitiesCountry

        guard !didLoadCountries || shouldLoadCities || cities.isEmpty else {
            viewState = .loaded
            return
        }

        viewState = .loading

        do {
            if !didLoadCountries {
                countries = try await providerService.availableCountries()
                didLoadCountries = true
            }

            if let selectedCountry = criteria.selectedCountry {
                cities = try await providerService.availableCities(for: selectedCountry)
                loadedCitiesCountry = selectedCountry
            } else {
                let providers = try await providerService.fetchProviders()
                cities = Array(Set(providers.map(\.location.city))).sorted()
                loadedCitiesCountry = nil
            }

            viewState = .loaded
        } catch is CancellationError {
            viewState = .idle
        } catch {
            viewState = .error(message: error.providerUserFacingMessage)
        }
    }

    /// Selects country and resets city when country changes.
    /// - Parameter country: Country to select.
    func selectCountry(_ country: Country?) {
        let countryChanged = criteria.selectedCountry != country
        criteria.selectedCountry = country

        if countryChanged {
            criteria.selectedCity = nil
            cities = []
            loadedCitiesCountry = nil
        }
    }

    /// Selects city inside the current country.
    /// - Parameter city: City to select.
    func selectCity(_ city: String?) {
        criteria.selectedCity = city
    }

    /// Toggles a specialty in the multi-select criteria.
    /// - Parameter specialty: Specialty to toggle.
    func toggleSpecialty(_ specialty: Specialty) {
        if criteria.selectedSpecialties.contains(specialty) {
            criteria.selectedSpecialties.remove(specialty)
        } else {
            criteria.selectedSpecialties.insert(specialty)
        }
    }

    /// Selects provider role or institutional type.
    /// - Parameter type: Provider type to select.
    func selectType(_ type: ProviderType?) {
        criteria.selectedType = type
    }

    /// Resets all selected filters.
    func reset() {
        criteria.reset()
        cities = []
        loadedCitiesCountry = nil
    }
}
