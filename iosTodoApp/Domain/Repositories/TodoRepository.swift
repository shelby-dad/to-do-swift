import Foundation

protocol TodoRepository {
    func fetchTodos(searchQuery: String?, includeCompleted: Bool, sort: TodoSortOption) async throws -> [TodoItem]
    func fetchTodo(id: UUID) async throws -> TodoItem
    func create(todo: TodoItem) async throws
    func update(todo: TodoItem) async throws
    func delete(id: UUID) async throws
}
