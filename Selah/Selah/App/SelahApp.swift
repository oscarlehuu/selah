import SwiftUI
import SwiftData

@MainActor
final class AppBootstrap {
    let container: ModelContainer
    let environment: AppEnvironment

    init() {
        SelahAppearance.apply()
        do {
            let container = try ModelContainerFactory.make()
            let environment = try AppEnvironment(modelContext: container.mainContext)
            self.container = container
            self.environment = environment
        } catch {
            let fallbackContainer = try! ModelContainerFactory.make(inMemory: true)
            self.container = fallbackContainer
            self.environment = try! AppEnvironment(modelContext: fallbackContainer.mainContext, demoMode: true)
        }
    }
}

@main
struct SelahApp: App {
    @State private var bootstrap = AppBootstrap()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(bootstrap.environment)
                .modelContainer(bootstrap.container)
        }
    }
}
