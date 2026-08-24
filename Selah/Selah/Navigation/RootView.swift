import SwiftUI

struct RootView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showExitMonthly = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        Group {
            if !env.onboardingComplete {
                OnboardingFlowView()
            } else if env.shouldShowPaywall() {
                PaywallView(
                    showExitMonthly: $showExitMonthly,
                    onRestore: handleRestore
                )
                .onAppear {
                    env.incrementPaywallPresentation()
                    AnalyticsService.track("paywall_view")
                    if env.subscription.paywallPresentationCount >= 2 {
                        AnalyticsService.track("paywall_relaunch_weekly_emphasis")
                    }
                }
                .sheet(isPresented: $showExitMonthly) {
                    ExitMonthlyOfferView(onDismiss: { showExitMonthly = false })
                        .onAppear { AnalyticsService.track("paywall_exit_offer_view") }
                }
            } else if env.settings?.sawNotificationPrompt != true {
                NotificationPromptView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: env.onboardingComplete)
        .alert("Restore", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }

    private func handleRestore() {
        Task {
            let ok = await env.subscription.restore()
            restoreMessage = ok ? "Your subscription is active." : "No active subscription found."
            showRestoreAlert = true
        }
    }
}
