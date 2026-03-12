import SwiftUI

struct TodoEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var priorityStore: PriorityStore
    @StateObject private var viewModel: TodoEditViewModel
    let onSaved: () async -> Void

    init(viewModel: TodoEditViewModel, onSaved: @escaping () async -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priorityID) {
                        ForEach(priorityStore.priorities) { item in
                            Label(item.name, systemImage: "circle.fill")
                                .foregroundStyle(Color(hex: item.colorHex))
                                .tag(item.id)
                        }
                    }
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $viewModel.hasDueDate)
                    if viewModel.hasDueDate {
                        DatePicker("Due", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                if let message = viewModel.errorMessage {
                    Section {
                        Text(message).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.existing == nil ? "New Todo" : "Edit Todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let fallback = priorityStore.firstAvailableID()
                            let validIDs = priorityStore.priorities.map(\.id)
                            viewModel.ensureValidPriority(validIDs: validIDs, fallback: fallback)
                            let success = await viewModel.save()
                            if success {
                                await onSaved()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .task {
                let validIDs = priorityStore.priorities.map(\.id)
                viewModel.ensureValidPriority(validIDs: validIDs, fallback: priorityStore.firstAvailableID())
            }
        }
    }
}
