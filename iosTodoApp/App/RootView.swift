import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        TabView {
            TodoListView(
                viewModel: TodoListViewModel(
                    getTodosUseCase: container.getTodosUseCase,
                    toggleTodoUseCase: container.toggleTodoUseCase,
                    deleteTodoUseCase: container.deleteTodoUseCase
                ),
                makeTodoEditView: { existing, onSaved in
                    TodoEditView(
                        viewModel: TodoEditViewModel(
                            existing: existing,
                            createTodoUseCase: container.createTodoUseCase,
                            updateTodoUseCase: container.updateTodoUseCase
                        ),
                        onSaved: onSaved
                    )
                }
            )
            .tabItem {
                Label("Todos", systemImage: "checklist")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}
