import Foundation
import PostHog

enum AnalyticsService {
    private nonisolated(unsafe) static var isDemo = false

    // Only conversion funnel events may leave the device. Never attach quiz,
    // mood, conversation, crisis, reading-plan, or prayer context.
    static let allowedEvents = Set((1...17).map { OnboardingCopy.eventName(for: $0) } + [
        "paywall_view", "paywall_payment_sheet_cancelled",
        "paywall_relaunch_weekly_emphasis", "subscribe", "restore_tap",
        "notification_permission_allow", "notification_permission_deny"
    ])

    static func sanitizedProperties(for event: String, properties: [String: Any]) -> [String: Any]? {
        guard allowedEvents.contains(event) else { return nil }
        var safe: [String: Any] = ["is_demo": false, "$geoip_disable": true]
        if event == "subscribe", let tier = properties["tier"] as? String,
           ["weekly", "monthly", "yearly"].contains(tier) {
            safe["tier"] = tier
        }
        return safe
    }

    static func configure(demoMode: Bool) {
        isDemo = demoMode
        guard !demoMode else { return }
        let config = PostHogConfig(apiKey: AppConfiguration.postHogAPIKey, host: AppConfiguration.postHogHost)
        config.captureApplicationLifecycleEvents = false
        config.captureScreenViews = false
        config.captureElementInteractions = false
        config.enableSwizzling = false
        config.sessionReplay = false
        config.preloadFeatureFlags = false
        config.remoteConfig = false
        config.personProfiles = .never
        config.setDefaultPersonProperties = false
        config.setBeforeSend { event in
            guard let safe = sanitizedProperties(for: event.event, properties: event.properties) else { return nil }
            event.properties = safe.merging(["$process_person_profile": false]) { _, new in new }
            return event
        }
        PostHogSDK.shared.setup(config)
    }

    static func track(_ event: String, properties: [String: Any] = [:]) {
        guard !isDemo, let safe = sanitizedProperties(for: event, properties: properties) else { return }
        PostHogSDK.shared.capture(event, properties: safe)
    }
}
