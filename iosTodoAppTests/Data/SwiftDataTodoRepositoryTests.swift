import XCTest
import SwiftData
@testable import iosTodoApp

final class SwiftDataTodoRepositoryTests: XCTestCase {
    func testCRUDInMemoryContainer() async throws {
        let container = try ModelContainer(for: TodoRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let repo = SwiftDataTodoRepository(container: container, logger: TestLogger())
        let now = Date()
        let todo = try TodoItem(title: "Local", createdAt: now, updatedAt: now)

        try await repo.create(todo: todo)

        let all = try await repo.fetchTodos(searchQuery: nil, includeCompleted: true, sort: .createdNewest)
        XCTAssertEqual(all.count, 1)

        let updated = try TodoItem(id: todo.id, title: "Local 2", isCompleted: false, priorityID: "medium", dueDate: nil, createdAt: now, updatedAt: now)
        try await repo.update(todo: updated)

        let fetched = try await repo.fetchTodo(id: todo.id)
        XCTAssertEqual(fetched.title, "Local 2")

        try await repo.delete(id: todo.id)
        let afterDelete = try await repo.fetchTodos(searchQuery: nil, includeCompleted: true, sort: .createdNewest)
        XCTAssertTrue(afterDelete.isEmpty)
    }
}
