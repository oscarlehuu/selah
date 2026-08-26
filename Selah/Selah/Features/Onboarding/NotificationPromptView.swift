import SwiftUI
import UserNotifications

struct NotificationPromptView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        // Mock v4 screen 17 — centered custom layout (no nav chrome, no list).
        VStack(spacing: 0) {
            Spacer()
            // 72pt rounded-square gold bell tile with soft gold ring shadow.
            Image(systemName: "bell.fill")
                .font(.system(size: 30))
                .foregroundStyle(SelahColors.accentDeep)
                .frame(width: 72, height: 72)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(SelahColors.accentSoft)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(SelahColors.accent.opacity(0.08), lineWidth: 10)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            Text(OnboardingCopy.notificationTitle)
                .font(SelahFont.display(.title3))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .padding(.top, 18)
                .padding(.horizontal, 30)
            Text(OnboardingCopy.notificationBody)
                .font(SelahFont.ui(.subheadline))
                .lineSpacing(3)
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 34)
            // Notification preview row — mock v4 white card with sunrise tile.
            HStack(alignment: .center, spacing: 12) {
                SelahIconTile(systemImage: "sunrise.fill", size: 34, radius: 9, style: .blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selah · now")
                        .font(SelahFont.ui(.footnote, weight: .bold))
                        .foregroundStyle(SelahColors.text)
                    Text("“Be still, and know that I am God.” · 4 min today")
                        .font(SelahFont.ui(.footnote))
                        .lineSpacing(2)
                        .foregroundStyle(SelahColors.textMuted)
                }
                Spacer(minLength: 0)
            }
            .selahCard()
            .padding(.top, 22)
            .padding(.horizontal, 26)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .selahCanvas()
        .safeAreaInset(edge: .bottom) {
            SelahFooterBar {
                SelahPrimaryButton(title: OnboardingCopy.notificationAllowCTA, action: allow)
                Button(OnboardingCopy.notificationSkipCTA, action: finish)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.textMuted)
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
