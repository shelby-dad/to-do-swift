import Foundation

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var todos: [TodoItem] = []
    @Published var searchQuery: String = ""
    @Published var includeCompleted: Bool = true
    @Published var sortOption: TodoSortOption = .createdNewest
    @Published var errorMessage: String?

    private let getTodosUseCase: GetTodosUseCase
    private let toggleTodoUseCase: ToggleTodoUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase
    private let errorMapper = ErrorMapper()

    init(getTodosUseCase: GetTodosUseCase, toggleTodoUseCase: ToggleTodoUseCase, deleteTodoUseCase: DeleteTodoUseCase) {
        self.getTodosUseCase = getTodosUseCase
        self.toggleTodoUseCase = toggleTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
    }

    func loadTodos() async {
        do {
            todos = try await getTodosUseCase.execute(
                searchQuery: searchQuery,
                includeCompleted: includeCompleted,
                sort: sortOption
            )
            errorMessage = nil
        } catch {
            errorMessage = errorMapper.userMessage(for: error)
        }
    }

    func toggle(id: UUID) async {
        do {
            try await toggleTodoUseCase.execute(id: id)
            await loadTodos()
        } catch {
            errorMessage = errorMapper.userMessage(for: error)
        }
    }

    func delete(id: UUID) async {
        do {
            try await deleteTodoUseCase.execute(id: id)
            await loadTodos()
        } catch {
            errorMessage = errorMapper.userMessage(for: error)
        }
    }
}
