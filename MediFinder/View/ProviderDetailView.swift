import SwiftUI

/// Provider profile detail screen.
struct ProviderDetailView<ViewModel: ProviderDetailViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ProviderDetailTab = .overview
    @State private var tabTransitionDirection: Edge = .trailing
    @State private var isTreatmentExpanded = true

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.labelWhite
                .ignoresSafeArea()

            content
                .ignoresSafeArea(edges: .top)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadProviderDetail()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            detailSkeleton
        case .loaded:
            if let provider = viewModel.provider {
                profile(provider)
            }
        case .error(let message):
            ErrorStateView(message: message) {
                Task {
                    await viewModel.retryLoading()
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func profile(_ provider: Provider) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header(provider)
                    tabBar
                    tabContent(provider)
                }
                .padding(.bottom, 118)
            }

            bottomActions
        }
    }

    private func header(_ provider: Provider) -> some View {
        VStack(spacing: 16) {
            HStack {
                circularHeaderButton(iconName: "chevron.left") {
                    dismiss()
                }

                Spacer()
            }
            .responsiveHorizontalPadding(percent: 0.043)

            HStack(alignment: .center, spacing: 16) {
                ProviderAvatarView(provider: provider, size: 92)

                VStack(alignment: .leading, spacing: 8) {
                    Text(provider.name)
                        .font(.h5(.bold))
                        .foregroundStyle(Color.labelPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(provider.specialty.displayName)
                        .font(.bodyMedium(.semibold))
                        .foregroundStyle(Color.solidTurquoise)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.solidTurquoise.opacity(0.12))
                        .clipShape(Capsule())

                    HStack(spacing: 7) {
                        CountryFlagView(country: provider.location.country, size: 20)

                        Text(provider.location.formattedLocation)
                            .font(.bodyMedium(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .foregroundStyle(Color.labelSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.systemBGSecondary.opacity(0.65))
                    .clipShape(Capsule())
                }
            }
            .responsiveHorizontalPadding(percent: 0.043)

            stats(provider)
                .responsiveHorizontalPadding(percent: 0.043)

            HStack(spacing: 12) {
                MainReusableButton(title: "Mesaj", style: .light, height: 44) { }
                MainReusableButton(title: "Takip et", style: .custom(bg: Color.actionBlue, fg: Color.labelWhite), height: 44) { }
            }
            .responsiveHorizontalPadding(percent: 0.043)
        }
        .padding(.top, CGFloat.topInsets + 12)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color.actionBlue.opacity(0.22), Color.solidTurquoise.opacity(0.09), Color.labelWhite],
                startPoint: .topTrailing,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ProviderDetailTab.allCases) { tab in
                Button {
                    selectTab(tab)
                } label: {
                    Text(tab.title)
                        .font(.bodyMedium(selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? Color.labelPrimary : Color.labelSecondary)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background {
                            if selectedTab == tab {
                                Color.labelWhite
                                    .clipShape(ProviderDetailSelectedTabShape())
                            } else {
                                Color.labelWhite
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.labelWhite)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.labelTertiary.opacity(0.16))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func tabContent(_ provider: Provider) -> some View {
        Group {
            switch selectedTab {
            case .overview:
                overviewContent(provider)
            case .about:
                aboutContent(provider)
            case .media:
                mediaContent(provider)
            case .activity:
                activityContent(provider)
            }
        }
        .id(selectedTab)
        .transition(
            .asymmetric(
                insertion: .move(edge: tabTransitionDirection),
                removal: .move(edge: tabTransitionDirection == .trailing ? .leading : .trailing)
            )
        )
        .animation(.easeInOut(duration: 0.24), value: selectedTab)
    }

    private func selectTab(_ tab: ProviderDetailTab) {
        guard tab != selectedTab else { return }

        let tabs = ProviderDetailTab.allCases
        let currentIndex = tabs.firstIndex(of: selectedTab) ?? 0
        let nextIndex = tabs.firstIndex(of: tab) ?? currentIndex
        tabTransitionDirection = nextIndex > currentIndex ? .trailing : .leading

        withAnimation(.easeInOut(duration: 0.24)) {
            selectedTab = tab
        }
    }

    private func overviewContent(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionTitle("Tedavi ve hizmetler")
            treatmentDisclosure(provider)

            contactSection(provider)

            sectionTitle("Konum")
            mapPlaceholder(provider)

            sectionTitle("Çalışma saatleri")
            workingHours

            sectionTitle("Değerlendirmeler")
            ratingSummary(provider)
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 22)
    }

    private func aboutContent(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionTitle("Sosyal medya")
            Image(systemName: "f.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.actionBlue)

            sectionTitle("Olanaklar")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                facility(iconName: "car.fill", title: "Otopark")
                facility(iconName: "figure.roll", title: "Tekerlekli Sandalye")
                facility(iconName: "calendar.badge.plus", title: "Randevu Gerekli")
            }

            sectionTitle("Sıkça sorulan sorular")
            faq(provider, question: "\(provider.name) hangi tedavileri ve hizmetleri sunuyor?")
            faq(provider, question: "\(provider.name) nerede bulunuyor?")
            faq(provider, question: "\(provider.name) çalışma saatleri nedir?")
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 22)
    }

    private func mediaContent(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Medya")
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.linearPinkGrad1.opacity(0.28))
                .frame(height: 360)
                .overlay(
                    Image(systemName: provider.specialty.iconName)
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(Color.labelWhite.opacity(0.8))
                )
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 22)
    }

    private func activityContent(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionTitle("Aktivite")
            ratingSummary(provider)
            reviewCard
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 22)
    }

    private func stats(_ provider: Provider) -> some View {
        HStack(spacing: 0) {
            stat(iconName: "star.fill", iconColor: Color.actionOrange, value: String(format: "%.1f", provider.rating), title: "\(provider.reviewCount) değerlendirme")
            Divider().frame(height: 64)
            stat(iconName: "sparkle", iconColor: Color.solidPink, value: "\(provider.yearsOfExperience)", title: "yıl deneyim")
            Divider().frame(height: 64)
            stat(iconName: "person.2.fill", iconColor: Color.actionBlue, value: "0", title: "takipçi")
        }
        .padding(.vertical, 10)
    }

    private func stat(iconName: String, iconColor: Color, value: String, title: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(.bodyLarge(.bold))
                    .foregroundStyle(Color.labelPrimary)
            }

            Text(title)
                .font(.bodySmall(.semibold))
                .lineLimit(1)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func mapPlaceholder(_ provider: Provider) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.azure50.opacity(0.7), Color.solidMint.opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 164)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(Color.actionRed)
                    Text(provider.location.formattedLocation)
                        .font(.bodyMedium(.semibold))
                        .foregroundStyle(Color.labelSecondary)
                }
            }
    }

    private func treatmentDisclosure(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isTreatmentExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(provider.specialty.displayName)
                        .font(.bodyLarge(.medium))
                        .foregroundStyle(Color.labelPrimary)
                        .lineLimit(2)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.bodyMedium(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                        .rotationEffect(.degrees(isTreatmentExpanded ? 0 : -90))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isTreatmentExpanded {
                Text(provider.bio)
                    .font(.bodyMedium(.regular))
                    .foregroundStyle(Color.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private func contactSection(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("İletişim bilgileri")

            VStack(spacing: 0) {
                if let phone = provider.contactInfo.phone {
                    contactRow(iconName: "phone.fill", title: "Telefon", value: phone)
                }

                if let email = provider.contactInfo.email {
                    contactRow(iconName: "envelope.fill", title: "E-posta", value: email)
                }

                if let website = provider.contactInfo.website {
                    contactRow(iconName: "globe", title: "Web sitesi", value: website)
                }

                if !provider.contactInfo.hasAnyContact {
                    Text("Bu profil için iletişim bilgisi henüz paylaşılmadı.")
                        .font(.bodyMedium(.regular))
                        .foregroundStyle(Color.labelSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                }
            }
        }
    }

    private func contactRow(iconName: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.bodyMedium(.semibold))
                .foregroundStyle(Color.actionBlue)
                .frame(width: 28, height: 28)
                .background(Color.actionBlue.opacity(0.10))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bodySmall(.regular))
                    .foregroundStyle(Color.labelSecondary)

                Text(value)
                    .font(.bodyMedium(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 11)
    }

    private var workingHours: some View {
        VStack(spacing: 0) {
            ForEach(workingHourRows, id: \.day) { row in
                HStack {
                    Image(systemName: "briefcase")
                        .font(.bodyMedium(.regular))
                        .foregroundStyle(Color.labelSecondary)
                        .frame(width: 26)

                    Text(row.day)
                        .font(.bodyLarge(.regular))
                        .foregroundStyle(Color.labelSecondary)

                    Spacer()

                    Text(row.hours)
                        .font(.bodyMedium(.regular))
                        .foregroundStyle(row.isClosed ? Color.actionRed : Color.labelSecondary)
                }
                .padding(.vertical, 12)

                if row.day != workingHourRows.last?.day {
                    Divider()
                }
            }
        }
    }

    private func ratingSummary(_ provider: Provider) -> some View {
        HStack(alignment: .top, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(format: "%.1f", provider.rating))
                    .font(.h1(.bold))
                    .foregroundStyle(Color.labelPrimary)
                    .minimumScaleFactor(0.8)

                Text("Mükemmel")
                    .font(.bodyLarge(.bold))
                    .foregroundStyle(Color.labelPrimary)

                Text("\(provider.reviewCount) değerlendirme")
                    .font(.bodyMedium(.regular))
                    .foregroundStyle(Color.labelSecondary)
            }

            VStack(spacing: 10) {
                ratingMetric("İletişim", provider.rating)
                ratingMetric("Güvenlik", provider.rating)
                ratingMetric("Bekleme", provider.rating)
                ratingMetric("Temizlik", provider.rating)
            }
        }
    }

    private func ratingMetric(_ title: String, _ value: Double) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.bodySmall(.regular))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
                .frame(width: 72, alignment: .trailing)
            Capsule()
                .fill(Color.actionOrange)
                .frame(height: 8)
            Text(String(format: "%.1f", value))
                .font(.bodySmall(.regular))
                .frame(width: 28, alignment: .trailing)
        }
        .foregroundStyle(Color.labelPrimary)
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.linearPinkGrad1.opacity(0.22))
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Beyza Y")
                        .font(.bodyLarge(.bold))
                        .foregroundStyle(Color.labelPrimary)
                    Text("20.05.2026")
                        .font(.bodyMedium(.regular))
                        .foregroundStyle(Color.labelSecondary)
                }
            }

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.linearPinkGrad1.opacity(0.18))
                .frame(height: 260)
        }
    }

    private func facility(iconName: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.bodyLarge(.regular))
                .foregroundStyle(Color.labelSecondary)
                .frame(width: 28)

            Text(title)
                .font(.bodyMedium(.regular))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.labelSecondary)
        }
    }

    private func faq(_ provider: Provider, question: String) -> some View {
        HStack(spacing: 12) {
            Text(question)
                .font(.bodyLarge(.regular))
                .foregroundStyle(Color.labelPrimary)
                .lineLimit(3)

            Spacer()

            Image(systemName: "plus")
                .font(.bodyXLarge(.regular))
                .foregroundStyle(Color.labelPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.systemBGQuaternary.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.h6(.bold))
            .foregroundStyle(Color.labelPrimary)
    }

    private func circularHeaderButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.bodyLarge(.semibold))
                .foregroundStyle(Color.labelPrimary)
                .frame(width: 50, height: 50)
                .background(Color.labelWhite.opacity(0.92))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var bottomActions: some View {
        HStack(spacing: 12) {
            MainReusableButton(title: "İletişim", style: .light, height: 50) { }
            MainReusableButton(title: "Konsültasyon", style: .custom(bg: Color.actionBlue, fg: Color.labelWhite), height: 50) { }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, max(CGFloat.bottomInsets * 0.25, 6))
        .background(
            Color.labelWhite
                .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: -6)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var detailSkeleton: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                detailSkeletonHeader
                detailSkeletonTabs
                detailSkeletonContent
            }
            .padding(.bottom, 90)
        }
        .skeletonShimmer()
        .accessibilityHidden(true)
    }

    private var detailSkeletonHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.systemBGTertiary)
                    .frame(width: 50, height: 50)
                Spacer()
            }
            .responsiveHorizontalPadding(percent: 0.043)

            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.systemBGTertiary)
                    .frame(width: 92, height: 92)

                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.systemBGTertiary)
                        .frame(width: .widthPer(per: 0.50), height: 24)
                    Capsule()
                        .fill(Color.systemBGTertiary)
                        .frame(width: .widthPer(per: 0.24), height: 30)
                    Capsule()
                        .fill(Color.systemBGTertiary)
                        .frame(width: .widthPer(per: 0.34), height: 30)
                }
            }
            .responsiveHorizontalPadding(percent: 0.043)

            HStack(spacing: 18) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.systemBGTertiary)
                        .frame(height: 48)
                }
            }
            .responsiveHorizontalPadding(percent: 0.043)

            HStack(spacing: 12) {
                Capsule()
                    .fill(Color.systemBGTertiary)
                    .frame(height: 44)
                Capsule()
                    .fill(Color.systemBGTertiary)
                    .frame(height: 44)
            }
            .responsiveHorizontalPadding(percent: 0.043)
        }
        .padding(.top, CGFloat.topInsets + 12)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color.actionBlue.opacity(0.14), Color.solidTurquoise.opacity(0.06), Color.labelWhite],
                startPoint: .topTrailing,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var detailSkeletonTabs: some View {
        HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { _ in
                Rectangle()
                    .fill(Color.labelWhite)
                    .frame(height: 52)
                    .overlay {
                        Capsule()
                            .fill(Color.systemBGTertiary)
                            .frame(width: 58, height: 14)
                    }
            }
        }
    }

    private var detailSkeletonContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.systemBGTertiary)
                .frame(width: .widthPer(per: 0.52), height: 22)

            Capsule()
                .fill(Color.systemBGTertiary)
                .frame(width: .widthPer(per: 0.70), height: 30)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.systemBGTertiary)
                .frame(height: 164)

            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.systemBGTertiary)
                    .frame(height: 22)
            }
        }
        .responsiveHorizontalPadding(percent: 0.043)
        .padding(.top, 22)
    }

    private var workingHourRows: [(day: String, hours: String, isClosed: Bool)] {
        [
            ("Pazartesi", "10:00-12:30, 14:30-19:30", false),
            ("Salı", "10:00-12:30, 14:30-19:30", false),
            ("Çarşamba", "10:00-12:30, 14:30-19:30", false),
            ("Perşembe", "10:00-12:30, 14:30-19:30", false),
            ("Cuma", "10:00-12:30, 14:30-19:30", false),
            ("Cumartesi", "12:00-15:00", false),
            ("Pazar", "Kapalı", true)
        ]
    }
}

private struct ProviderDetailSelectedTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 12

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

private enum ProviderDetailTab: String, CaseIterable, Identifiable {
    case overview
    case about
    case media
    case activity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Önizleme"
        case .about: "Hakkında"
        case .media: "Medya"
        case .activity: "Aktivite"
        }
    }
}
