import Foundation

/// Supported country values for filtering and display.
enum Country: String, CaseIterable, Identifiable, Sendable {
    case turkey = "Turkey"
    case germany = "Germany"
    case unitedKingdom = "United Kingdom"
    case unitedStates = "United States"
    case austria = "Austria"
    case ireland = "Ireland"
    case portugal = "Portugal"
    case poland = "Poland"
    case afghanistan = "Afghanistan"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turkey: "Türkiye"
        case .germany: "Almanya"
        case .unitedKingdom: "Birleşik Krallık"
        case .unitedStates: "Amerika Birleşik Devletleri"
        case .austria: "Avusturya"
        case .ireland: "İrlanda"
        case .portugal: "Portekiz"
        case .poland: "Polonya"
        case .afghanistan: "Afganistan"
        }
    }

    var code: String {
        switch self {
        case .turkey: "TR"
        case .germany: "DE"
        case .unitedKingdom: "GB"
        case .unitedStates: "US"
        case .austria: "AT"
        case .ireland: "IE"
        case .portugal: "PT"
        case .poland: "PL"
        case .afghanistan: "AF"
        }
    }

    var flag: String {
        switch self {
        case .turkey: "🇹🇷"
        case .germany: "🇩🇪"
        case .unitedKingdom: "🇬🇧"
        case .unitedStates: "🇺🇸"
        case .austria: "🇦🇹"
        case .ireland: "🇮🇪"
        case .portugal: "🇵🇹"
        case .poland: "🇵🇱"
        case .afghanistan: "🇦🇫"
        }
    }
}
