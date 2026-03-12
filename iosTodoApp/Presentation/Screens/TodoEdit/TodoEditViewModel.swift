import Foundation

@MainActor
final class TodoEditViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var notes: String = ""
    @Published var priorityID: String = TodoPriorityOption.defaultID
    @Published var hasDueDate: Bool = false
    @Published var dueDate: Date = Date()
    @Published var errorMessage: String?

    let existing: TodoItem?

    private let createTodoUseCase: CreateTodoUseCase
    private let updateTodoUseCase: UpdateTodoUseCase
    private let errorMapper = ErrorMapper()

    init(existing: TodoItem?, createTodoUseCase: CreateTodoUseCase, updateTodoUseCase: UpdateTodoUseCase) {
        self.existing = existing
        self.createTodoUseCase = createTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase

        if let existing {
            self.title = existing.title
            self.notes = existing.notes ?? ""
            self.priorityID = existing.priorityID
            self.hasDueDate = existing.dueDate != nil
            self.dueDate = existing.dueDate ?? Date()
        }
    }

    func ensureValidPriority(validIDs: [String], fallback: String) {
        if priorityID.isEmpty || !validIDs.contains(priorityID) {
            priorityID = fallback
        }
    }

    func save() async -> Bool {
        do {
            let notesValue = notes.isEmpty ? nil : notes
            let dueDateValue = hasDueDate ? dueDate : nil

            if let existing {
                try await updateTodoUseCase.execute(
                    id: existing.id,
                    title: title,
                    notes: notesValue,
                    priorityID: priorityID,
                    dueDate: dueDateValue
                )
            } else {
                try await createTodoUseCase.execute(
                    title: title,
                    notes: notesValue,
                    priorityID: priorityID,
                    dueDate: dueDateValue
                )
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = errorMapper.userMessage(for: error)
            return false
        }
    }
}
