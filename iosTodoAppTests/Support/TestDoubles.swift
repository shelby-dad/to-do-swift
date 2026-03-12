import Foundation
@testable import iosTodoApp

final class InMemoryTodoRepository: TodoRepository {
    var todos: [TodoItem] = []
    var shouldThrow = false

    func fetchTodos(searchQuery: String?, includeCompleted: Bool, sort: TodoSortOption) async throws -> [TodoItem] {
        if shouldThrow { throw AppError.unknown }
        var results = todos
        if !includeCompleted {
            results = results.filter { !$0.isCompleted }
        }
        if let q = searchQuery, !q.isEmpty {
            let lower = q.lowercased()
            results = results.filter { $0.title.lowercased().contains(lower) || ($0.notes?.lowercased().contains(lower) ?? false) }
        }
        return results
    }

    func fetchTodo(id: UUID) async throws -> TodoItem {
        if let todo = todos.first(where: { $0.id == id }) { return todo }
        throw AppError.notFound
    }

    func create(todo: TodoItem) async throws {
        if shouldThrow { throw AppError.unknown }
        todos.append(todo)
    }

    func update(todo: TodoItem) async throws {
        if shouldThrow { throw AppError.unknown }
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { throw AppError.notFound }
        todos[idx] = todo
    }

    func delete(id: UUID) async throws {
        if shouldThrow { throw AppError.unknown }
        todos.removeAll { $0.id == id }
    }
}

struct FixedClockProvider: ClockProvider {
    let fixed: Date
    func now() -> Date { fixed }
}

struct TestLogger: AppLogger {
    func info(_ message: String) {}
    func error(_ message: String) {}
}
