import SwiftUI

/// Grid card displaying a provider summary.
struct ProviderCardView: View {
    let provider: Provider

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ProviderAvatarView(provider: provider, size: 54)

                Spacer()

                Image(systemName: provider.specialty.iconName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(cardAccent.opacity(0.32))
                    .frame(width: 54, height: 54)
                    .background(cardAccent.opacity(0.10))
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }

            Text(provider.name)
                .font(.bodyXXLarge(.bold))
                .foregroundStyle(Color.labelPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(height: 52, alignment: .bottomLeading)

            HStack(spacing: 8) {
                Text(provider.specialty.displayName)
                    .font(.bodyMedium(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(cardAccent)
                    .background(cardAccent.opacity(0.12))
                    .clipShape(Capsule())

                Spacer(minLength: 4)

                ratingChip
            }

            HStack(alignment: .center, spacing: 6) {
                CountryFlagView(country: provider.location.country, size: 18)

                Text(provider.location.formattedLocation)
                    .font(.bodySmall(.semibold))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color.labelPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.labelTertiary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 198, alignment: .topLeading)
        .background(Color.labelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.labelTertiary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 10, x: 0, y: 7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(provider.name), \(provider.specialty.displayName), \(provider.location.formattedLocation), \(provider.rating) puan")
    }

    private var cardAccent: Color {
        provider.type == .hospital ? Color.actionRed : Color.solidTurquoise
    }

    private var ratingChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.bodyXSmall(.bold))
                .foregroundStyle(Color.actionOrange)

            Text(String(format: "%.1f", provider.rating))
                .font(.bodySmall(.bold))
                .foregroundStyle(Color.labelPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.systemBGSecondary.opacity(0.82))
        .clipShape(Capsule())
    }
}
