import Foundation

enum DemoMode {
    static var isEnabled: Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains("-DemoMode")
            || args.contains("-DemoMode")
            || ProcessInfo.processInfo.environment["SELAH_DEMO_MODE"] == "1"
    }

    static var uiTestFreshStart: Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains("-UITestFreshStart")
            || args.contains("-UITestFreshStart")
    }
}
