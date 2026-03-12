import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var priorityStore: PriorityStore

    @AppStorage("settings.defaultSort") private var defaultSortRaw = TodoSortOption.createdNewest.rawValue
    @AppStorage("settings.defaultIncludeCompleted") private var defaultIncludeCompleted = true

    var body: some View {
        Form {
            Section("Display") {
                Picker("Default Sort", selection: $defaultSortRaw) {
                    ForEach(TodoSortOption.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                Toggle("Show completed by default", isOn: $defaultIncludeCompleted)
            }

            Section("Priorities") {
                ForEach(priorityStore.priorities) { item in
                    HStack {
                        TextField("Name", text: Binding(
                            get: { item.name },
                            set: { priorityStore.updateName(id: item.id, name: $0) }
                        ))
                        Spacer()
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: item.colorHex) },
                            set: { priorityStore.updateColor(id: item.id, colorHex: $0.toHex()) }
                        ))
                        .labelsHidden()
                        Button(role: .destructive) {
                            priorityStore.deletePriority(id: item.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(priorityStore.priorities.count <= 1)
                    }
                }

                Button {
                    priorityStore.addPriority()
                } label: {
                    Label("Add Priority", systemImage: "plus")
                }

                if priorityStore.priorities.count <= 1 {
                    Text("At least one priority must remain.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("About") {
                LabeledContent("Storage", value: "Local offline (SwiftData)")
                LabeledContent("Sync", value: "Not configured")
            }
        }
        .navigationTitle("Settings")
    }
}
