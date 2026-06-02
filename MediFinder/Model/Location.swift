import Foundation

/// Geographic provider location and optional address.
struct Location: Hashable, Sendable {
    let country: Country
    let city: String
    let address: String?

    var formattedLocation: String {
        "\(city), \(country.displayName)"
    }
}
