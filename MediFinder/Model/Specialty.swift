import Foundation

/// Medical branch or service category used for search and filtering.
enum Specialty: String, CaseIterable, Identifiable, Sendable {
    case cardiology
    case dermatology
    case orthopedics
    case pediatrics
    case neurology
    case ophthalmology
    case generalSurgery
    case internalMedicine
    case psychiatry
    case dentistry
    case plasticSurgery
    case gynecology
    case physiatry

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cardiology: "Kardiyoloji"
        case .dermatology: "Dermatoloji"
        case .orthopedics: "Ortopedi"
        case .pediatrics: "Pediatri"
        case .neurology: "Nöroloji"
        case .ophthalmology: "Göz Hastalıkları"
        case .generalSurgery: "Genel Cerrahi"
        case .internalMedicine: "Dahiliye"
        case .psychiatry: "Psikiyatri"
        case .dentistry: "Diş Hekimi"
        case .plasticSurgery: "Plastik Cerrahi"
        case .gynecology: "Kadın Hastalıkları ve Doğum"
        case .physiatry: "Fizik Tedavi"
        }
    }

    var englishName: String {
        switch self {
        case .cardiology: "Cardiology"
        case .dermatology: "Dermatologist"
        case .orthopedics: "Orthopedics"
        case .pediatrics: "Pediatrics"
        case .neurology: "Neurology"
        case .ophthalmology: "Ophthalmology"
        case .generalSurgery: "General Surgery"
        case .internalMedicine: "Internal Medicine"
        case .psychiatry: "Psychiatry"
        case .dentistry: "Diş Hekimi"
        case .plasticSurgery: "Plastik Cerrahi"
        case .gynecology: "Kadın Hastalıkları"
        case .physiatry: "Fizik Tedavi"
        }
    }

    var iconName: String {
        switch self {
        case .cardiology: "heart.fill"
        case .dermatology: "hand.raised.fill"
        case .orthopedics: "figure.walk"
        case .pediatrics: "figure.and.child.holdinghands"
        case .neurology: "brain.head.profile"
        case .ophthalmology: "eye.fill"
        case .generalSurgery: "cross.case.fill"
        case .internalMedicine: "stethoscope"
        case .psychiatry: "brain"
        case .dentistry: "mouth.fill"
        case .plasticSurgery: "sparkles"
        case .gynecology: "figure.arms.open"
        case .physiatry: "figure.flexibility"
        }
    }

    var searchAliases: [String] {
        switch self {
        case .cardiology: ["cardiology", "kalp"]
        case .dermatology: ["dermatology", "dermatologist", "cilt"]
        case .orthopedics: ["orthopedics", "ortopedi"]
        case .pediatrics: ["pediatrics", "cocuk"]
        case .neurology: ["neurology", "noroloji", "nöroloji"]
        case .ophthalmology: ["ophthalmology", "goz", "göz"]
        case .generalSurgery: ["general surgery", "cerrahi"]
        case .internalMedicine: ["internal medicine", "general practitioner", "dahiliye"]
        case .psychiatry: ["psychiatry", "psikiyatri"]
        case .dentistry: ["dentist", "dentistry", "dis", "diş", "dis hekimi", "diş hekimi"]
        case .plasticSurgery: ["plastic surgeon", "plastic surgery", "estetik"]
        case .gynecology: ["gynecology", "kadin", "kadın"]
        case .physiatry: ["physiatrist", "physical therapy", "fizik tedavi"]
        }
    }
}
