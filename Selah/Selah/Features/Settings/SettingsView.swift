import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                SundayLightBackground()
                List {
                    Section("Subscription") {
                        Button("Restore purchases") { restore() }
                        Link("Manage subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                        if let restoreMessage { Text(restoreMessage).font(.caption) }
                    }
                    Section("Notifications") {
                        Stepper("Reminder \(formattedTime)", value: hourBinding, in: 5...21)
                            .font(SelahFont.figtree(15))
                    }
                    Section("Journal") {
                        Toggle("iCloud encrypted sync", isOn: boolBinding(\.journalCloudSyncEnabled))
                        Toggle("Require Face ID", isOn: boolBinding(\.requireFaceIDForJournal))
                    }
                    Section("Talk") {
                        Toggle("Auto-delete sessions", isOn: autoDeleteBinding)
                    }
                    Section("Legal") {
                        if let url = URL(string: AppConfiguration.privacyPolicyURL) { Link("Privacy", destination: url) }
                        if let url = URL(string: AppConfiguration.termsURL) { Link("Terms", destination: url) }
                        Text(AppConfiguration.supportEmail)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
            .onAppear { AnalyticsService.track("settings_open") }
        }
    }

    private var formattedTime: String {
        String(format: "%d:%02d", env.settings?.notificationHour ?? 6, env.settings?.notificationMinute ?? 30)
    }

    private var hourBinding: Binding<Int> {
        Binding(
            get: { env.settings?.notificationHour ?? 6 },
            set: { value in
                env.settings?.notificationHour = value
                env.settings?.notificationMinute = 30
                env.persist()
                NotificationScheduler.scheduleDaily(hour: value, minute: 30)
            }
        )
    }

    private var autoDeleteBinding: Binding<Bool> {
        Binding(
            get: { env.settings?.autoDeleteTalkSessions ?? false },
            set: { value in
                env.settings?.autoDeleteTalkSessions = value
                env.persist()
            }
        )
    }

    private func boolBinding(_ keyPath: ReferenceWritableKeyPath<AppSettingsModel, Bool>) -> Binding<Bool> {
        Binding(
            get: { env.settings?[keyPath: keyPath] ?? false },
            set: { env.settings?[keyPath: keyPath] = $0; env.persist() }
        )
    }

    private func restore() {
        Task {
            let ok = await env.subscription.restore()
            restoreMessage = ok ? "Subscription active." : "No subscription found."
        }
    }
}
