import Foundation
import PostHog

enum AnalyticsService {
    private nonisolated(unsafe) static var isDemo = false

    static func configure(demoMode: Bool) {
        isDemo = demoMode
        guard !demoMode else { return }
        let config = PostHogConfig(apiKey: AppConfiguration.postHogAPIKey, host: AppConfiguration.postHogHost)
        PostHogSDK.shared.setup(config)
    }

    static func track(_ event: String, properties: [String: Any] = [:]) {
        guard !isDemo else { return }
        var props = properties
        props["is_demo"] = false
        PostHogSDK.shared.capture(event, properties: props)
    }
}
