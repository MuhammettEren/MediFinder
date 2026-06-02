import Foundation

/// Optional contact channels for a provider profile.
struct ContactInfo: Hashable, Sendable {
    let phone: String?
    let email: String?
    let website: String?

    var hasAnyContact: Bool {
        phone != nil || email != nil || website != nil
    }
}
