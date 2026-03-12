import Foundation
import SwiftData

@MainActor
final class AppContainer: ObservableObject {
    let modelContainer: ModelContainer
    let logger: AppLogger
    let clock: ClockProvider

    let createTodoUseCase: CreateTodoUseCase
    let updateTodoUseCase: UpdateTodoUseCase
    let deleteTodoUseCase: DeleteTodoUseCase
    let toggleTodoUseCase: ToggleTodoUseCase
    let getTodosUseCase: GetTodosUseCase

    init(inMemoryOnly: Bool = false) {
        self.logger = OSAppLogger()
        self.clock = SystemClockProvider()

        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: inMemoryOnly)
            self.modelContainer = try ModelContainer(for: TodoRecord.self, configurations: config)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        let repo = SwiftDataTodoRepository(container: modelContainer, logger: logger)
        self.createTodoUseCase = DefaultCreateTodoUseCase(repository: repo, clock: clock, logger: logger)
        self.updateTodoUseCase = DefaultUpdateTodoUseCase(repository: repo, clock: clock, logger: logger)
        self.deleteTodoUseCase = DefaultDeleteTodoUseCase(repository: repo, logger: logger)
        self.toggleTodoUseCase = DefaultToggleTodoUseCase(repository: repo, clock: clock, logger: logger)
        self.getTodosUseCase = DefaultGetTodosUseCase(repository: repo)
    }
}
