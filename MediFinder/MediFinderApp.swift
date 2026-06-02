//
//  MediFinderApp.swift
//  MediFinder
//
//  Created by Muhammet Eren on 1.06.2026.
//

import SwiftUI

@main
struct MediFinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(providerService: MockProviderService())
        }
    }
}
