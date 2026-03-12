import SwiftUI
import SwiftData

@main
struct iosTodoAppApp: App {
    @StateObject private var container = AppContainer()
    @StateObject private var priorityStore = PriorityStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(priorityStore)
                .modelContainer(container.modelContainer)
        }
    }
}
