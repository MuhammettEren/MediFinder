import Foundation

/// Domain-specific errors surfaced by provider data operations.
enum ProviderServiceError: LocalizedError, Equatable, Sendable {
    case networkUnavailable
    case providerNotFound
    case serverError
    case timeout
    case unknown

    var errorDescription: String? {
        userFacingMessage
    }

    /// Copy shown in UI error states instead of transport-level diagnostics.
    var userFacingMessage: String {
        switch self {
        case .networkUnavailable: "Bağlantı kurulamadı. İnternetini kontrol edip tekrar deneyebilirsin."
        case .providerNotFound: "Bu sağlık hizmetine şu anda ulaşılamıyor."
        case .serverError: "Bilgileri alırken bir sorun oluştu. Lütfen biraz sonra tekrar dene."
        case .timeout: "İstek beklenenden uzun sürdü. Lütfen tekrar dene."
        case .unknown: "Beklenmeyen bir sorun oluştu. Lütfen tekrar dene."
        }
    }
}

extension Error {
    /// Normalizes provider data errors into language safe for user-facing screens.
    var providerUserFacingMessage: String {
        if let providerError = self as? ProviderServiceError {
            return providerError.userFacingMessage
        }

        return "Bilgileri alırken bir sorun oluştu. Lütfen tekrar dene."
    }
}
