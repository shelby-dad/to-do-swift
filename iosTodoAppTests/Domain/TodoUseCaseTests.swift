import XCTest
@testable import iosTodoApp

final class TodoUseCaseTests: XCTestCase {
    func testCreateTodoUseCaseStoresTodo() async throws {
        let repo = InMemoryTodoRepository()
        let now = Date()
        let useCase = DefaultCreateTodoUseCase(repository: repo, clock: FixedClockProvider(fixed: now), logger: TestLogger())

        try await useCase.execute(title: "Task A", notes: "Note", priorityID: "high", dueDate: nil)

        XCTAssertEqual(repo.todos.count, 1)
        XCTAssertEqual(repo.todos.first?.title, "Task A")
        XCTAssertEqual(repo.todos.first?.priorityID, "high")
    }

    func testToggleTodoUseCaseFlipsState() async throws {
        let repo = InMemoryTodoRepository()
        let now = Date()
        let existing = try TodoItem(title: "Task", isCompleted: false, createdAt: now, updatedAt: now)
        repo.todos = [existing]
        let useCase = DefaultToggleTodoUseCase(repository: repo, clock: FixedClockProvider(fixed: now.addingTimeInterval(20)), logger: TestLogger())

        try await useCase.execute(id: existing.id)

        XCTAssertEqual(repo.todos.first?.isCompleted, true)
    }
}
