import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var priorityStore: PriorityStore
    @StateObject private var viewModel: TodoListViewModel
    let makeTodoEditView: (TodoItem?, @escaping () async -> Void) -> TodoEditView

    @State private var showingCreate = false
    @State private var editingTodo: TodoItem?

    init(viewModel: TodoListViewModel, makeTodoEditView: @escaping (TodoItem?, @escaping () async -> Void) -> TodoEditView) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeTodoEditView = makeTodoEditView
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.todos.isEmpty {
                    ContentUnavailableView("No Todos", systemImage: "checklist", description: Text("Create your first task to get started."))
                } else {
                    List(viewModel.todos) { todo in
                        TodoRowView(todo: todo, priority: priorityStore.option(for: todo.priorityID))
                            .contentShape(Rectangle())
                            .onTapGesture { editingTodo = todo }
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task { await viewModel.toggle(id: todo.id) }
                                } label: {
                                    Label("Toggle", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(id: todo.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Todos")
            .searchable(text: $viewModel.searchQuery)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Filter") {
                        Toggle("Include Completed", isOn: $viewModel.includeCompleted)
                        Picker("Sort", selection: $viewModel.sortOption) {
                            ForEach(TodoSortOption.allCases) { sort in
                                Text(sort.title).tag(sort)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreate = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .alert("Error", isPresented: Binding(get: {
                viewModel.errorMessage != nil
            }, set: { newVal in
                if !newVal { viewModel.errorMessage = nil }
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task { await viewModel.loadTodos() }
            .onChange(of: viewModel.searchQuery) { _, _ in Task { await viewModel.loadTodos() } }
            .onChange(of: viewModel.includeCompleted) { _, _ in Task { await viewModel.loadTodos() } }
            .onChange(of: viewModel.sortOption) { _, _ in Task { await viewModel.loadTodos() } }
            .sheet(isPresented: $showingCreate, onDismiss: {
                Task { await viewModel.loadTodos() }
            }) {
                makeTodoEditView(nil) {
                    await viewModel.loadTodos()
                }
            }
            .sheet(item: $editingTodo, onDismiss: {
                Task { await viewModel.loadTodos() }
            }) { todo in
                makeTodoEditView(todo) {
                    await viewModel.loadTodos()
                }
            }
        }
    }
}
