import Foundation

/// Represents a searchable healthcare provider in MediFinder.
struct Provider: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let type: ProviderType
    let specialty: Specialty
    let location: Location
    let rating: Double
    let reviewCount: Int
    let bio: String
    let contactInfo: ContactInfo
    let imageURL: String?
    let yearsOfExperience: Int
    let languages: [String]
    let isVerified: Bool
}

extension Provider {
    /// Returns a stable provider instance for previews and tests.
    static let preview = Provider(
        id: "tr-001",
        name: "Dr. Ahmet Yilmaz",
        type: .doctor,
        specialty: .cardiology,
        location: Location(country: .turkey, city: "Istanbul", address: "Nisantasi, Tesvikiye Cad. No:45"),
        rating: 4.8,
        reviewCount: 234,
        bio: "Istanbul Universitesi Tip Fakultesi mezunu. Kalp ve damar hastaliklari alaninda 18 yillik deneyime sahiptir.",
        contactInfo: ContactInfo(phone: "+90 212 555 0001", email: "info@drahmety.com", website: "www.drahmety.com"),
        imageURL: nil,
        yearsOfExperience: 18,
        languages: ["TR", "EN"],
        isVerified: true
    )
}

extension Provider {
    /// Calculates a local relevance score for user-entered provider search text.
    ///
    /// The scorer favors exact phrase matches first, then token and prefix matches, and finally small typo tolerance.
    /// - Parameter query: Free-form search phrase entered by the user.
    /// - Returns: Positive score when the provider matches the query; zero otherwise.
    func searchScore(matching query: String) -> Int {
        let normalizedQuery = query.normalizedProviderSearchText
        let queryTokens = normalizedQuery.providerSearchTokens

        guard !queryTokens.isEmpty else {
            return 1
        }

        let fields = searchFields.map(\.normalizedProviderSearchText)
        let searchableText = fields.joined(separator: " ")
        let searchableTokens = fields.flatMap(\.providerSearchTokens)

        if fields.contains(where: { $0 == normalizedQuery }) {
            return 160
        }

        if searchableText.contains(normalizedQuery) {
            return 135
        }

        if queryTokens.allSatisfy({ queryToken in searchableTokens.contains(queryToken) }) {
            return 110 + queryTokens.count
        }

        if queryTokens.allSatisfy({ queryToken in searchableTokens.contains(where: { $0.hasPrefix(queryToken) }) }) {
            return 92 + queryTokens.count
        }

        if queryTokens.allSatisfy({ queryToken in searchableTokens.contains(where: { $0.contains(queryToken) || queryToken.contains($0) }) }) {
            return 76 + queryTokens.count
        }

        if queryTokens.allSatisfy({ queryToken in searchableTokens.contains(where: { queryToken.isCloseSearchMatch(to: $0) }) }) {
            return 58 + queryTokens.count
        }

        return 0
    }

    private var searchFields: [String] {
        [
            name,
            type.displayName,
            type.searchDisplayName,
            specialty.displayName,
            specialty.englishName,
            specialty.searchAliases.joined(separator: " "),
            location.city,
            location.country.displayName,
            location.country.rawValue
        ]
    }
}

private extension String {
    var normalizedProviderSearchText: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased(with: Locale(identifier: "tr_TR"))
            .replacingOccurrences(of: "ı", with: "i")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var providerSearchTokens: [String] {
        components(separatedBy: " ").filter { !$0.isEmpty }
    }

    func isCloseSearchMatch(to target: String) -> Bool {
        guard count > 2, target.count > 2 else {
            return self == target
        }

        let threshold = Swift.max(1, Swift.min(count, target.count) / 4)
        return levenshteinDistance(to: target) <= threshold
    }

    func levenshteinDistance(to target: String) -> Int {
        let sourceCharacters = Array(self)
        let targetCharacters = Array(target)
        var distances = Array(0...targetCharacters.count)

        for (sourceIndex, sourceCharacter) in sourceCharacters.enumerated() {
            var previousDistance = distances[0]
            distances[0] = sourceIndex + 1

            for (targetIndex, targetCharacter) in targetCharacters.enumerated() {
                let temporaryDistance = distances[targetIndex + 1]
                distances[targetIndex + 1] = sourceCharacter == targetCharacter
                    ? previousDistance
                    : Swift.min(previousDistance, distances[targetIndex], distances[targetIndex + 1]) + 1
                previousDistance = temporaryDistance
            }
        }

        return distances[targetCharacters.count]
    }
}
