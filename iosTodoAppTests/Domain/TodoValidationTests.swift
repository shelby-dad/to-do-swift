import XCTest
@testable import iosTodoApp

final class TodoValidationTests: XCTestCase {
    func testTitleCannotBeEmpty() {
        XCTAssertThrowsError(try TodoItem(title: "   ", createdAt: Date(), updatedAt: Date()))
    }

    func testTitleIsTrimmed() throws {
        let item = try TodoItem(title: "  Buy milk  ", createdAt: Date(), updatedAt: Date())
        XCTAssertEqual(item.title, "Buy milk")
    }

    func testDueDateCannotBeEarlierThanCreatedDate() {
        let created = Date()
        let due = created.addingTimeInterval(-100)
        XCTAssertThrowsError(try TodoItem(title: "Task", dueDate: due, createdAt: created, updatedAt: created))
    }
}
