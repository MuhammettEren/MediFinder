import Foundation

/// Categorizes providers by role or institutional type.
enum ProviderType: String, CaseIterable, Identifiable, Sendable {
    case doctor
    case clinic
    case hospital
    case specialist

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .doctor: "Doktor"
        case .clinic: "Klinik"
        case .hospital: "Hastane"
        case .specialist: "Uzman"
        }
    }

    var searchDisplayName: String {
        switch self {
        case .doctor: "Doctor"
        case .clinic: "Clinic"
        case .hospital: "Hospital"
        case .specialist: "Specialist"
        }
    }

    var iconName: String {
        switch self {
        case .doctor: "stethoscope"
        case .clinic: "cross.case"
        case .hospital: "building.2"
        case .specialist: "staroflife"
        }
    }
}
