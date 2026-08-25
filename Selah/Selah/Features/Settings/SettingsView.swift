import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var restoreMessage: String?
    @State private var showCrisis = false
    @State private var showPrivacy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    Text(env.isSubscribed ? "Selah · Yearly" : "Not subscribed")
                    Button("Restore", action: restore)
                        .accessibilityIdentifier("settings.restore")
                    Link("Manage subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    if let restoreMessage { Text(restoreMessage).font(.caption) }
                }
                Section("Privacy") {
                    LabeledContent("On-device AI", value: "Always on")
                    Toggle("Auto-delete sessions", isOn: autoDeleteBinding)
                    Button("How privacy works") { showPrivacy = true }
                    Toggle("iCloud encrypted sync", isOn: boolBinding(\.journalCloudSyncEnabled))
                    Toggle("Require Face ID", isOn: boolBinding(\.requireFaceIDForJournal))
                }
                Section("Daily rhythm") {
                    Stepper(
                        "Morning verse \(formattedTime)",
                        value: hourBinding,
                        in: 5...21
                    )
                    LabeledContent("Translation", value: "KJV")
                }
                Section("Care") {
                    Button("Urgent help & hotlines") { showCrisis = true }
                    Text(OnboardingCopy.companionDisclaimer)
                        .foregroundStyle(.secondary)
                }
                Section("Legal & support") {
                    if let url = URL(string: AppConfiguration.privacyPolicyURL) {
                        Link("Privacy Policy", destination: url)
                    }
                    if let url = URL(string: AppConfiguration.termsURL) {
                        Link("Terms of Use", destination: url)
                    }
                    Link(AppConfiguration.supportEmail, destination: URL(string: "mailto:\(AppConfiguration.supportEmail)")!)
                }
            }
            .selahCanvas()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
            .sheet(isPresented: $showPrivacy) { PrivacyInfoView() }
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
