import Foundation

/// Sorting options supported by the provider result list.
enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case newest
    case highestRated
    case mostReviewed
    case mostRecommended
    case nearest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newest: "En yeni"
        case .highestRated: "En yüksek puan"
        case .mostReviewed: "En çok değerlendirilen"
        case .mostRecommended: "En çok önerilen"
        case .nearest: "En yakın"
        }
    }
}
