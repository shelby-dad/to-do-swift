import Foundation
import SwiftData

actor SwiftDataTodoRepository: TodoRepository {
    private let container: ModelContainer
    private let mapper: TodoMapper
    private let logger: AppLogger

    init(container: ModelContainer, mapper: TodoMapper = .init(), logger: AppLogger) {
        self.container = container
        self.mapper = mapper
        self.logger = logger
    }

    func fetchTodos(searchQuery: String?, includeCompleted: Bool, sort: TodoSortOption) async throws -> [TodoItem] {
        do {
            let context = ModelContext(container)
            let records = try context.fetch(FetchDescriptor<TodoRecord>())
            var todos = try records.map { try mapper.toEntity($0) }

            if !includeCompleted {
                todos = todos.filter { !$0.isCompleted }
            }

            if let q = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
                let lower = q.lowercased()
                todos = todos.filter {
                    $0.title.lowercased().contains(lower) || ($0.notes?.lowercased().contains(lower) ?? false)
                }
            }

            return sortTodos(todos, sort: sort)
        } catch {
            logger.error("Fetch todos failed: \(error.localizedDescription)")
            throw AppError.persistence(error.localizedDescription)
        }
    }

    func fetchTodo(id: UUID) async throws -> TodoItem {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TodoRecord>(predicate: #Predicate { $0.id == id })
        guard let record = try context.fetch(descriptor).first else {
            throw AppError.notFound
        }
        return try mapper.toEntity(record)
    }

    func create(todo: TodoItem) async throws {
        do {
            let context = ModelContext(container)
            context.insert(mapper.toRecord(todo))
            try context.save()
        } catch {
            logger.error("Create todo failed: \(error.localizedDescription)")
            throw AppError.persistence(error.localizedDescription)
        }
    }

    func update(todo: TodoItem) async throws {
        do {
            let context = ModelContext(container)
            let todoID = todo.id
            let descriptor = FetchDescriptor<TodoRecord>(predicate: #Predicate { $0.id == todoID })
            guard let existing = try context.fetch(descriptor).first else {
                throw AppError.notFound
            }
            mapper.updateRecord(existing, with: todo)
            try context.save()
        } catch let appError as AppError {
            throw appError
        } catch {
            logger.error("Update todo failed: \(error.localizedDescription)")
            throw AppError.persistence(error.localizedDescription)
        }
    }

    func delete(id: UUID) async throws {
        do {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<TodoRecord>(predicate: #Predicate { $0.id == id })
            guard let existing = try context.fetch(descriptor).first else {
                throw AppError.notFound
            }
            context.delete(existing)
            try context.save()
        } catch let appError as AppError {
            throw appError
        } catch {
            logger.error("Delete todo failed: \(error.localizedDescription)")
            throw AppError.persistence(error.localizedDescription)
        }
    }

    private func sortTodos(_ todos: [TodoItem], sort: TodoSortOption) -> [TodoItem] {
        switch sort {
        case .createdNewest:
            return todos.sorted { $0.createdAt > $1.createdAt }
        case .createdOldest:
            return todos.sorted { $0.createdAt < $1.createdAt }
        case .dueSoonest:
            return todos.sorted { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (l?, r?): return l < r
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return lhs.createdAt > rhs.createdAt
                }
            }
        case .priorityHighFirst:
            let rank: [String: Int] = ["high": 0, "medium": 1, "low": 2]
            return todos.sorted {
                if rank[$0.priorityID, default: 3] == rank[$1.priorityID, default: 3] {
                    return $0.createdAt > $1.createdAt
                }
                return rank[$0.priorityID, default: 3] < rank[$1.priorityID, default: 3]
            }
        }
    }
}
