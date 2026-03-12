import Foundation

struct TodoMapper {
    func toEntity(_ record: TodoRecord) throws -> TodoItem {
        try TodoItem(
            id: record.id,
            title: record.title,
            notes: record.notes,
            isCompleted: record.isCompleted,
            priorityID: record.priority,
            dueDate: record.dueDate,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }

    func updateRecord(_ record: TodoRecord, with entity: TodoItem) {
        record.title = entity.title
        record.notes = entity.notes
        record.isCompleted = entity.isCompleted
        record.priority = entity.priorityID
        record.dueDate = entity.dueDate
        record.createdAt = entity.createdAt
        record.updatedAt = entity.updatedAt
    }

    func toRecord(_ entity: TodoItem) -> TodoRecord {
        TodoRecord(
            id: entity.id,
            title: entity.title,
            notes: entity.notes,
            isCompleted: entity.isCompleted,
            priority: entity.priorityID,
            dueDate: entity.dueDate,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }
}
