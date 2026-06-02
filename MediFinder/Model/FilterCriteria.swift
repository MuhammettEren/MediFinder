import Foundation

/// Selected filters applied to provider search results.
struct FilterCriteria: Equatable, Sendable {
    var selectedCountry: Country?
    var selectedCity: String?
    var selectedSpecialties: Set<Specialty> = []
    var selectedType: ProviderType?

    var isEmpty: Bool {
        selectedCountry == nil && selectedCity == nil && selectedSpecialties.isEmpty && selectedType == nil
    }

    var activeFilterCount: Int {
        var count = 0
        if selectedCountry != nil { count += 1 }
        if selectedCity != nil { count += 1 }
        count += selectedSpecialties.count
        if selectedType != nil { count += 1 }
        return count
    }

    mutating func reset() {
        selectedCountry = nil
        selectedCity = nil
        selectedSpecialties.removeAll()
        selectedType = nil
    }
}
