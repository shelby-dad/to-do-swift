import Foundation
import SwiftData

@Model
final class TodoRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String?
    var isCompleted: Bool
    var priority: String
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        title: String,
        notes: String?,
        isCompleted: Bool,
        priority: String,
        dueDate: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
