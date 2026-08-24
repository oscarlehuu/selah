import SwiftUI
import UserNotifications

struct NotificationPromptView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        SelahFlowScreen {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 48)
                    Text("A gentle reminder each morning?")
                        .font(SelahFont.newsreader(26, weight: .semibold))
                        .multilineTextAlignment(.center)
                    Text("Default 6:30 AM — you can change in Settings.")
                        .font(SelahFont.figtree(16))
                        .foregroundStyle(SelahColors.textMuted)
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
            }
            .selahFlowScrollContent()
        } bottom: {
            SelahPinnedBottomBar {
                VStack(spacing: 12) {
                    SelahPrimaryButton(title: "Allow notifications", action: allow)
                    Button("Not now") { finish() }
                        .font(SelahFont.figtree(15))
                        .foregroundStyle(SelahColors.textMuted)
                }
            }
        }
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
