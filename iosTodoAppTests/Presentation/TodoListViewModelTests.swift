import XCTest
@testable import iosTodoApp

final class TodoListViewModelTests: XCTestCase {
    func testLoadTodosSuccess() async throws {
        let repo = InMemoryTodoRepository()
        let now = Date()
        repo.todos = [try TodoItem(title: "A", createdAt: now, updatedAt: now)]

        let vm = await TodoListViewModel(
            getTodosUseCase: DefaultGetTodosUseCase(repository: repo),
            toggleTodoUseCase: DefaultToggleTodoUseCase(repository: repo, clock: FixedClockProvider(fixed: now), logger: TestLogger()),
            deleteTodoUseCase: DefaultDeleteTodoUseCase(repository: repo, logger: TestLogger())
        )

        await vm.loadTodos()
        let todos = await vm.todos
        XCTAssertEqual(todos.count, 1)
    }

    func testLoadTodosFailureSetsErrorMessage() async {
        let repo = InMemoryTodoRepository()
        repo.shouldThrow = true

        let vm = await TodoListViewModel(
            getTodosUseCase: DefaultGetTodosUseCase(repository: repo),
            toggleTodoUseCase: DefaultToggleTodoUseCase(repository: repo, clock: FixedClockProvider(fixed: Date()), logger: TestLogger()),
            deleteTodoUseCase: DefaultDeleteTodoUseCase(repository: repo, logger: TestLogger())
        )

        await vm.loadTodos()
        let message = await vm.errorMessage
        XCTAssertNotNil(message)
    }
}
