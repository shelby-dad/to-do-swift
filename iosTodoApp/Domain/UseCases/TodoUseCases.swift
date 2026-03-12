import Foundation

protocol CreateTodoUseCase {
    func execute(title: String, notes: String?, priorityID: String, dueDate: Date?) async throws
}

protocol UpdateTodoUseCase {
    func execute(id: UUID, title: String, notes: String?, priorityID: String, dueDate: Date?) async throws
}

protocol DeleteTodoUseCase {
    func execute(id: UUID) async throws
}

protocol ToggleTodoUseCase {
    func execute(id: UUID) async throws
}

protocol GetTodosUseCase {
    func execute(searchQuery: String?, includeCompleted: Bool, sort: TodoSortOption) async throws -> [TodoItem]
}

struct DefaultCreateTodoUseCase: CreateTodoUseCase {
    let repository: TodoRepository
    let clock: ClockProvider
    let logger: AppLogger

    func execute(title: String, notes: String?, priorityID: String, dueDate: Date?) async throws {
        let now = clock.now()
        let todo = try TodoItem(title: title, notes: notes, priorityID: priorityID, dueDate: dueDate, createdAt: now, updatedAt: now)
        try await repository.create(todo: todo)
        logger.info("Created todo \(todo.id)")
    }
}

struct DefaultUpdateTodoUseCase: UpdateTodoUseCase {
    let repository: TodoRepository
    let clock: ClockProvider
    let logger: AppLogger

    func execute(id: UUID, title: String, notes: String?, priorityID: String, dueDate: Date?) async throws {
        let current = try await repository.fetchTodo(id: id)
        let updated = try TodoItem(
            id: current.id,
            title: title,
            notes: notes,
            isCompleted: current.isCompleted,
            priorityID: priorityID,
            dueDate: dueDate,
            createdAt: current.createdAt,
            updatedAt: clock.now()
        )
        try await repository.update(todo: updated)
        logger.info("Updated todo \(id)")
    }
}

struct DefaultDeleteTodoUseCase: DeleteTodoUseCase {
    let repository: TodoRepository
    let logger: AppLogger

    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
        logger.info("Deleted todo \(id)")
    }
}

struct DefaultToggleTodoUseCase: ToggleTodoUseCase {
    let repository: TodoRepository
    let clock: ClockProvider
    let logger: AppLogger

    func execute(id: UUID) async throws {
        let current = try await repository.fetchTodo(id: id)
        let updated = try TodoItem(
            id: current.id,
            title: current.title,
            notes: current.notes,
            isCompleted: !current.isCompleted,
            priorityID: current.priorityID,
            dueDate: current.dueDate,
            createdAt: current.createdAt,
            updatedAt: clock.now()
        )
        try await repository.update(todo: updated)
        logger.info("Toggled todo \(id)")
    }
}

struct DefaultGetTodosUseCase: GetTodosUseCase {
    let repository: TodoRepository

    func execute(searchQuery: String?, includeCompleted: Bool, sort: TodoSortOption) async throws -> [TodoItem] {
        try await repository.fetchTodos(searchQuery: searchQuery, includeCompleted: includeCompleted, sort: sort)
    }
}
