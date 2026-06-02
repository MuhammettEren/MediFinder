import SwiftUI

/// Compact rating text with star icon.
struct RatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.bodySmall(.semibold))
                .foregroundStyle(Color.actionOrange)

            Text(String(format: "%.1f", rating))
                .font(.bodyMedium(.semibold))
                .foregroundStyle(Color.labelPrimary)

            Text("(\(reviewCount))")
                .font(.bodyMedium(.regular))
                .foregroundStyle(Color.labelTertiary)
        }
        .accessibilityLabel("\(rating) puan, \(reviewCount) değerlendirme")
    }
}
