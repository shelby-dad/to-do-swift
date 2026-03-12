# iOS Todo App (SwiftUI + SwiftData)

Offline-first Todo app built with a clean, enterprise-style architecture for maintainability, testability, and team scalability.

This guide is written for developers coming from other language ecosystems (Java, Kotlin, C#, JavaScript/TypeScript, Python, Go, etc.).

## 1) What this project teaches
- How to structure a SwiftUI codebase by **layers + feature**.
- How to enforce separation of concerns with **protocols and use cases**.
- How to implement offline persistence using **SwiftData**.
- How to design for growth with dependency injection, logging, and test seams.
- How to build user-customizable domain settings (dynamic priorities with colors).

## 2) Folder map
- `App/`
  - App entry point and composition root.
  - Wires dependencies once and passes them down.
- `Core/`
  - Cross-cutting concerns shared by all layers.
  - Examples: DI container, error mapping, logging abstraction, clock provider.
- `Domain/`
  - Pure business layer.
  - Entities, repository contracts (protocols), use case contracts + implementations.
  - No SwiftUI, no SwiftData details.
- `Data/`
  - Infrastructure layer.
  - SwiftData models, mappers, repository implementations.
  - Converts persistence models <-> domain entities.
- `Presentation/`
  - UI layer.
  - SwiftUI Views + ViewModels, navigation and user interactions.
- `../iosTodoAppTests`
  - Unit tests grouped by `Domain`, `Data`, `Presentation`.

## 2.1) Code walkthrough inside each folder
### `App/`
- `iosTodoAppApp.swift`
  - `@main` entry point of the app.
  - Creates `AppContainer` once and injects dependencies into the root UI.
  - Attaches SwiftData container to SwiftUI with `.modelContainer(...)`.
- `RootView.swift`
  - Top-level tab navigation (`Todos`, `Settings`).
  - Creates feature ViewModels using dependencies from `AppContainer`.
  - Connects UI events to use cases through ViewModels.

### `Core/DI`
- `AppContainer.swift`
  - Composition root for dependency injection.
  - Builds `ModelContainer`, repository implementation, and all use cases.
  - Keeps wiring in one place so feature files stay clean.

### `Core/Errors`
- `AppError.swift`
  - Shared error enum for validation, persistence, and not-found scenarios.
  - Prevents storage-specific errors leaking to UI.
- `ErrorMapper.swift`
  - Converts internal errors into user-safe display messages.
  - Used by ViewModels before showing alerts.

### `Core/Logging`
- `AppLogger.swift`
  - Logging abstraction (`AppLogger`) plus OSLog implementation (`OSAppLogger`).
  - Lets you replace logger in tests or future analytics pipelines.

### `Core/Time`
- `ClockProvider.swift`
  - Abstraction for current time.
  - Enables deterministic tests by injecting fixed clock values.

### `Domain/Entities`
- `TodoItem.swift`
  - Main business entity as immutable value type.
  - Validates title and due-date rules in initializer.
  - Stores `priorityID` (string key) instead of hardcoded enum priority.
  - Represents app behavior, independent from UI/database format.

### `Domain/Enums`
- `TodoPriority.swift`
  - Defines `TodoPriorityOption` (id, display name, color hex) and defaults.
  - Used by settings and edit/list UI to support dynamic priorities.
- `TodoSortOption.swift`
  - Domain-level sorting options with UI-friendly titles.
  - Keeps sorting choices explicit and type-safe.

### `Domain/Repositories`
- `TodoRepository.swift`
  - Contract for storage operations (fetch, create, update, delete).
  - Domain/use-cases depend on this protocol, not SwiftData directly.

### `Domain/UseCases`
- `TodoUseCases.swift`
  - Declares protocol interfaces per business action.
  - Contains `Default...UseCase` implementations.
  - Coordinates validation, timestamps, repository calls, and logging.

### `Data/Models`
- `TodoRecord.swift`
  - SwiftData persistence model (`@Model`) stored on device.
  - May differ from domain entity shape in larger apps.

### `Data/Mappers`
- `TodoMapper.swift`
  - Converts `TodoRecord <-> TodoItem`.
  - Central place for transformation logic to avoid duplication.

### `Data/Repositories`
- `SwiftDataTodoRepository.swift`
  - Concrete repository implementation using SwiftData.
  - Executes CRUD, filtering/search/sort behavior, and error wrapping.
  - Implemented as `actor` for concurrency safety.

### `Presentation/Navigation`
- `AppTab.swift`
  - Tab identity enum for root navigation.
  - Keeps navigation state type-safe.

### `Presentation/Screens/TodoList`
- `TodoListView.swift`
  - List UI with search/filter/sort and swipe actions.
  - Opens create/edit sheet and refreshes state after changes.
  - Resolves priority display metadata (name/color) from `PriorityStore`.
- `TodoListViewModel.swift`
  - Holds list state (`todos`, filter, search, errors).
  - Calls get/toggle/delete use cases and maps failures for UI.
- `TodoRowView.swift`
  - Reusable row renderer for one todo item.
  - Shows priority badge using customizable color from settings.

### `Presentation/Screens/TodoEdit`
- `TodoEditView.swift`
  - Create/edit form UI with fields, validation feedback, and save action.
  - Priority picker is dynamic (driven by `PriorityStore`).
- `TodoEditViewModel.swift`
  - Form state owner.
  - Chooses create vs update path based on existing item.
  - Converts form input into use case calls with `priorityID`.

### `Presentation/Screens/Settings`
- `SettingsView.swift`
  - Local settings UI using `@AppStorage` and `PriorityStore`.
  - Lets user add/delete/rename priorities and assign a custom color.
  - Enforces rule: at least one priority must remain.

### `Presentation/Shared`
- `PriorityStore.swift`
  - Persistent store for priority options in user defaults (JSON encoded).
  - Supports add, update name, update color, delete, and fallback resolution.
  - Includes color hex conversion helpers for SwiftUI `Color`.

### `iosTodoAppTests/Support`
- `TestDoubles.swift`
  - In-memory fake repository, fixed clock, and test logger.
  - Used to isolate domain/presentation tests from real persistence.

### `iosTodoAppTests/Domain`
- `TodoValidationTests.swift`
  - Verifies entity-level business rules.
- `TodoUseCaseTests.swift`
  - Verifies use case behavior and side effects with fakes.

### `iosTodoAppTests/Data`
- `TodoMapperTests.swift`
  - Verifies mapping between persistence and domain.
- `SwiftDataTodoRepositoryTests.swift`
  - Verifies repository CRUD using in-memory SwiftData container.

### `iosTodoAppTests/Presentation`
- `TodoListViewModelTests.swift`
  - Verifies state transitions and error handling in list ViewModel.

## 3) Architecture principles
### Dependency direction
- `Presentation -> Domain`
- `Data -> Domain`
- `Core` can be used by all layers.
- `Domain` should not depend on `Presentation` or `Data`.

### Why this matters
- Business logic is reusable and easy to test.
- UI and storage can evolve independently.
- Easier onboarding for larger teams.

## 4) OOP and design principles used
### SOLID in practice
- **Single Responsibility**: each class/struct has one reason to change.
- **Open/Closed**: extend behavior by adding use cases/repositories, not editing everything.
- **Liskov Substitution**: any `TodoRepository` implementation should work behind the protocol.
- **Interface Segregation**: focused use case protocols (`CreateTodoUseCase`, `GetTodosUseCase`, etc.).
- **Dependency Inversion**: high-level logic depends on protocols, not concrete storage/UI classes.

### Composition over inheritance
- Swift favors protocols + structs/classes composition.
- We use protocol contracts and inject implementations via `AppContainer`.

### Immutability-first domain modeling
- `TodoItem` is a value type (`struct`) and validated in initializer.
- Reduces accidental side effects and makes tests deterministic.

## 5) Design patterns used
- **Repository Pattern**: `TodoRepository` hides data source details.
- **Use Case Pattern**: one business action per use case (create/update/delete/toggle/get).
- **Mapper Pattern**: isolates conversion between `TodoRecord` (SwiftData) and `TodoItem` (Domain).
- **Dependency Injection**: app container wires concrete implementations to abstractions.
- **MVVM (Presentation)**: Views render state; ViewModels coordinate user actions and async calls.
- **Settings Store Pattern**: `PriorityStore` centralizes user-configurable metadata used across screens.

## 6) Data flow (request lifecycle)
1. User interacts with a SwiftUI `View`.
2. `ViewModel` calls a `UseCase` protocol.
3. Use case executes business rules and calls `TodoRepository`.
4. Repository reads/writes SwiftData records.
5. Mapper converts records to domain entities.
6. Priority metadata (name/color) is resolved from `PriorityStore` when rendering/editing.
7. Result returns to ViewModel, then UI updates via `@Published` state.

## 7) Error handling strategy
- Infrastructure errors are normalized as `AppError`.
- UI never needs low-level storage details.
- `ErrorMapper` maps errors to user-safe messages.

## 8) Testing strategy
- `Domain` tests: validation/business logic and use case behavior with fakes.
- `Data` tests: mapper correctness and in-memory SwiftData repository CRUD.
- `Presentation` tests: ViewModel state transitions and error behavior.

This keeps tests fast and focused while giving high confidence.

## 9) Naming conventions
- Protocols describe capability: `TodoRepository`, `CreateTodoUseCase`.
- Concrete implementations use `Default...` or storage-specific names:
  - `DefaultCreateTodoUseCase`
  - `SwiftDataTodoRepository`
- View models end with `ViewModel`, views end with `View`.

## 10) How to add a new feature (recommended workflow)
1. Add/extend domain entity and repository contract.
2. Add use case protocol + default implementation.
3. Implement/extend data repository + mapper.
4. Build ViewModel using use case protocols only.
5. Build SwiftUI View bound to ViewModel.
6. Wire in `AppContainer`.
7. Add unit tests for domain/data/presentation.

## 11) For developers from other languages
- Swift `protocol` ~= interface (Java/C#/TypeScript).
- Swift `struct` ~= immutable data model (Kotlin data class / TS type object style).
- `actor` provides concurrency safety for mutable shared state.
- `@StateObject`, `@Published`, `@EnvironmentObject` are SwiftUI state management tools.
- `async/await` behaves similarly to modern async patterns in Kotlin/C#/JS.

## 12) Build and run
### Generate/open project
```bash
cd /path/to/iosTodoApp
xcodegen generate
open iosTodoApp.xcodeproj
```

### Run app
- In Xcode: select `iosTodoApp` scheme and an iOS simulator.
- Press `Cmd + R`.

### Run tests
- In Xcode: `Cmd + U`.

## 13) Common pitfalls
- If you see Info.plist/codesign errors, regenerate project and clean build folder.
- If `modelContainer` is not recognized, ensure `import SwiftData` is present where needed.
- Keep business logic out of Views; put it in use cases and view models.
- If a priority is deleted, ensure edit flows fallback to a valid remaining priority ID.

## 14) Where to start reading
1. `App/iosTodoAppApp.swift` and `Core/DI/AppContainer.swift`
2. `Domain/UseCases/TodoUseCases.swift`
3. `Data/Repositories/SwiftDataTodoRepository.swift`
4. `Presentation/Screens/TodoList/TodoListViewModel.swift`

This order shows the dependency flow from app wiring -> business logic -> persistence -> UI behavior.
