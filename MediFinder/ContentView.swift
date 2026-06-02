//
//  ContentView.swift
//  MediFinder
//
//  Created by Muhammet Eren on 1.06.2026.
//

import SwiftUI

struct ContentView: View {
    private let providerService: ProviderServiceProtocol
    private let providerListViewModel: ProviderListViewModel
    @State private var path: [Provider] = []

    init(providerService: ProviderServiceProtocol) {
        self.providerService = providerService
        self.providerListViewModel = ProviderListViewModel(providerService: providerService)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ProviderListView(
                viewModel: providerListViewModel,
                makeFilterViewModel: { criteria in
                    FilterViewModel(providerService: providerService, criteria: criteria)
                },
                makeSearchViewModel: {
                    ProviderSearchViewModel(providerService: providerService)
                },
                onProviderSelected: { provider in
                    path.append(provider)
                }
            )
            .navigationDestination(for: Provider.self) { provider in
                ProviderDetailView(
                    viewModel: ProviderDetailViewModel(
                        providerService: providerService,
                        providerId: provider.id
                    )
                )
            }
        }
    }
}

#Preview {
    ContentView(providerService: MockProviderService())
}
