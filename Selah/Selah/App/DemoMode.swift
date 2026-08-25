import Foundation

enum DemoMode {
    private static var args: [String] { ProcessInfo.processInfo.arguments }

    static var isEnabled: Bool {
        args.contains("-DemoMode") || ProcessInfo.processInfo.environment["SELAH_DEMO_MODE"] == "1"
    }

    static var uiTestFreshStart: Bool {
        args.contains("-UITestFreshStart")
    }

    static var screenshotPaywall: Bool {
        args.contains("-ScreenshotPaywall")
    }

    static var screenshotSettings: Bool {
        args.contains("-ScreenshotSettings")
    }

    static var screenshotTab: MainTab? {
        guard let index = args.firstIndex(of: "-ScreenshotTab"),
              args.indices.contains(index + 1)
        else { return nil }
        return MainTab(rawValue: args[index + 1].lowercased())
    }
}
