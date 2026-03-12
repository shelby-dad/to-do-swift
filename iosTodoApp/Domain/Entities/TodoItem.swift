import Foundation

struct TodoItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let notes: String?
    let isCompleted: Bool
    let priorityID: String
    let dueDate: Date?
    let createdAt: Date
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        priorityID: String = TodoPriorityOption.defaultID,
        dueDate: Date? = nil,
        createdAt: Date,
        updatedAt: Date
    ) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.validation("Title cannot be empty.")
        }
        if let dueDate, dueDate < createdAt.addingTimeInterval(-1) {
            throw AppError.validation("Due date cannot be earlier than creation date.")
        }

        self.id = id
        self.title = trimmed
        self.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isCompleted = isCompleted
        self.priorityID = priorityID
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
