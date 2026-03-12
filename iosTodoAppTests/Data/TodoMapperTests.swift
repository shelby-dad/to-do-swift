import XCTest
@testable import iosTodoApp

final class TodoMapperTests: XCTestCase {
    func testMapperRoundTrip() throws {
        let now = Date()
        let entity = try TodoItem(title: "Map", notes: "N", isCompleted: true, priorityID: "low", dueDate: now, createdAt: now, updatedAt: now)
        let mapper = TodoMapper()

        let record = mapper.toRecord(entity)
        let mappedBack = try mapper.toEntity(record)

        XCTAssertEqual(mappedBack.id, entity.id)
        XCTAssertEqual(mappedBack.title, entity.title)
        XCTAssertEqual(mappedBack.priorityID, entity.priorityID)
    }
}
