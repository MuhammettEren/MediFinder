import Foundation

/// Identifiable city option used by bottom sheet selectors.
struct CityFilterOption: Identifiable, Hashable {
    let id: String
    let name: String

    /// Creates a city option from a city name.
    /// - Parameter name: City display name.
    init(name: String) {
        self.id = name
        self.name = name
    }
}
