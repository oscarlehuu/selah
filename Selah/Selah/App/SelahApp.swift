import SwiftUI
import SwiftData
import UIKit

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
                .background {
                    WindowFillView()
                        .allowsHitTesting(false)
                }
        }
    }
}

private struct WindowFillView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = SelahAppearance.canvasUIColor
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.backgroundColor = SelahAppearance.canvasUIColor
            window.overrideUserInterfaceStyle = .light
            if let screen = window.windowScene?.screen {
                window.frame = screen.bounds
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
