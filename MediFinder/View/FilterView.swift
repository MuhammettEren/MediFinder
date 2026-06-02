import SwiftUI

/// Country filter bottom sheet.
struct CountryFilterSheet<ViewModel: FilterViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let onDone: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        BottomSheetSelectorView(
            title: "Ülkeler",
            searchPlaceholder: "Ülke ara...",
            items: viewModel.countries,
            allowsMultipleSelection: false,
            titleProvider: { $0.displayName },
            subtitleProvider: { _ in nil },
            leadingContentProvider: { AnyView(CountryFlagView(country: $0, size: 34)) },
            isSelected: { viewModel.criteria.selectedCountry == $0 },
            onToggle: { viewModel.selectCountry($0) },
            onDone: onDone,
            onDismiss: onDismiss
        )
        .task {
            await viewModel.loadFilters()
        }
    }
}

/// City filter bottom sheet.
struct CityFilterSheet<ViewModel: FilterViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let onDone: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        BottomSheetSelectorView(
            title: "Şehirler",
            searchPlaceholder: "Şehir ara...",
            items: viewModel.cities.map(CityFilterOption.init),
            allowsMultipleSelection: false,
            titleProvider: { $0.name },
            subtitleProvider: { _ in nil },
            isSelected: { viewModel.criteria.selectedCity == $0.name },
            onToggle: { viewModel.selectCity($0.name) },
            onDone: onDone,
            onDismiss: onDismiss
        )
        .task {
            await viewModel.loadFilters()
        }
    }
}

/// Service filter bottom sheet.
struct ServiceFilterSheet<ViewModel: FilterViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let onDone: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        BottomSheetSelectorView(
            title: "Servisler",
            searchPlaceholder: "Ara",
            items: viewModel.specialties,
            allowsMultipleSelection: true,
            titleProvider: { $0.displayName },
            subtitleProvider: { _ in nil },
            isSelected: { viewModel.criteria.selectedSpecialties.contains($0) },
            onToggle: { viewModel.toggleSpecialty($0) },
            onDone: onDone,
            onDismiss: onDismiss
        )
        .task {
            await viewModel.loadFilters()
        }
    }
}

/// Provider role filter bottom sheet.
struct RoleFilterSheet<ViewModel: FilterViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let onDone: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        BottomSheetSelectorView(
            title: "Rol",
            searchPlaceholder: "Ara",
            items: viewModel.providerTypes,
            allowsMultipleSelection: false,
            titleProvider: { $0.displayName },
            subtitleProvider: { _ in nil },
            isSelected: { viewModel.criteria.selectedType == $0 },
            onToggle: { viewModel.selectType($0) },
            onDone: onDone,
            onDismiss: onDismiss
        )
        .task {
            await viewModel.loadFilters()
        }
    }
}
