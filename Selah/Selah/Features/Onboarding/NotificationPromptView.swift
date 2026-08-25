import SwiftUI
import UserNotifications

struct NotificationPromptView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(OnboardingCopy.notificationTitle, systemImage: "bell.fill")
                        .font(SelahFont.display(.title3))
                    Text(OnboardingCopy.notificationBody)
                        .foregroundStyle(.secondary)
                }
                Section("Preview") {
                    LabeledContent("Selah") {
                        Text("“Be still, and know that I am God.” · 4 min today")
                            .font(SelahFont.ui(.footnote))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .selahCanvas()
            .navigationTitle("Reminders")
            .safeAreaInset(edge: .bottom) {
                SelahFooterBar {
                    SelahPrimaryButton(title: OnboardingCopy.notificationAllowCTA, action: allow)
                    Button(OnboardingCopy.notificationSkipCTA, action: finish)
                        .font(SelahFont.ui(.subheadline, weight: .semibold))
                }
            }
        }
        .tint(SelahColors.primaryDeep)
        .onAppear { AnalyticsService.track("onboarding_17_notifications") }
    }

    private func allow() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            Task { @MainActor in
                NotificationScheduler.scheduleDaily(hour: 6, minute: 30)
                AnalyticsService.track("notification_permission_allow")
                env.markNotificationPromptSeen()
            }
        }
    }

    private func finish() {
        AnalyticsService.track("notification_permission_deny")
        env.markNotificationPromptSeen()
    }
}

enum NotificationScheduler {
    static func scheduleDaily(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Selah"
        content.body = "Pause. A quiet moment with God is waiting."
        content.sound = .default
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "selah.daily", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
