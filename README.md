# MediFinder

MediFinder is a native iOS case study implementation of a provider discovery flow:

`Provider List -> Filter -> Provider Detail`

The project is built with SwiftUI, strict MVVM, protocol-oriented dependencies, constructor injection, and async/await-based mock data loading.

## Demo

<video src="Demo/MediFinder_Demo.mp4" controls width="320"></video>

[Watch the demo video](Demo/MediFinder_Demo.mp4)

## Features

- Provider list with search, sorting, and pull-to-refresh loading states.
- Provider cards showing name, specialty/category, location, and rating.
- Filters for country, city, specialty/category, and provider type.
- Provider detail with profile summary, treatment information, contact information, location, working hours, ratings, and tabbed sections.
- Loading, empty, and error states with user-facing Turkish copy.
- Skeleton and shimmer placeholders for list and detail loading.
- Local search scoring with Turkish normalization, phrase matching, token matching, prefix matching, and small typo tolerance.

## Architecture

- Model: Plain data structures and enums only.
- Service: `ProviderServiceProtocol` plus `MockProviderService` for async mock data, delay simulation, and error injection.
- ViewModel: `@MainActor` classes own fetching, searching, filtering, sorting, retry, and render state.
- View: SwiftUI views are passive. They render state and forward user actions to ViewModels.
- UICommon: Reusable visual building blocks such as provider cards, search header, filter pills, selectable rows, bottom sheets, buttons, skeleton shimmer, empty/error states, and info rows.

## State Management

Each major flow uses explicit view state:

- `ProviderListViewState`
- `FilterViewState`
- `ProviderDetailViewState`

Views consume `@Published` state through `@ObservedObject` or `@StateObject`. Business decisions such as search matching, filter intersection, result counts, retry behavior, and error copy stay inside ViewModels.

## Navigation

`ContentView` owns the root `NavigationStack` path. Provider cards append a selected `Provider`, and the detail destination receives a constructor-injected `ProviderDetailViewModel`.

Search is presented as a full-screen flow so recent searches, live suggestions, and submitted result navigation stay separate from the list screen state.

## Data Layer

Backend integration is intentionally out of scope for the case study. `MockProviderService` provides a deterministic provider catalog across multiple countries, cities, specialties, and provider types.

Some providers intentionally omit optional fields such as contact or address information to exercise null and missing-data handling in the UI.

## Testing

The project includes `MediFinderTests` with XCTest coverage for:

- Provider list loading, error, search, filters, and empty state.
- Filter country/city loading and reset behavior.
- Provider detail loading and missing-profile error handling.
- Mock service success and failure cases.
- Turkish phrase search for dentistry-related queries.

Run:

```sh
xcodebuild -project MediFinder.xcodeproj -scheme MediFinder -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -parallel-testing-enabled NO test
```

Latest verified result: 23 tests, 0 failures.

## Requirements

- Xcode 26+
- iOS 16.6+
- Swift 6 with Approachable Concurrency enabled for the app target

## Notes

- The app uses local mock data only; no network credentials or external service configuration is required.
- Error messages are mapped to user-facing Turkish copy instead of exposing transport-level diagnostics.
- Shared UI pieces live under `UICommon` to keep repeated visual patterns consistent across the list, filter, search, and detail flows.
