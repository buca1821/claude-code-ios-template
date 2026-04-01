---
trigger:
  - "ViewModel"
  - "Pattern"
  - "MVVM"
  - "@Observable"
description: "Standard coding patterns for MVVM, state management, and dependency injection"
---

# Swift/SwiftUI Patterns

## MVVM
- ViewModels: `@MainActor`, `@Observable` (NOT `ObservableObject`, NOT `@Published`)
- Views own ViewModel via `@State private var viewModel:`
- Business logic in ViewModel; Views are declarative only

## State Management
- `@State private` for view-owned state and `@Observable` ViewModels
- `@Bindable` for injected observables needing bindings
- `@Environment` with `@Observable` for shared state (NOT `@EnvironmentObject`)
- Never pass values as `@State` — they ignore updates

## Dependency Injection
- Use protocols to abstract data sources
- Inject via initializer for testability
- Conditional compilation for simulator vs device data sources
