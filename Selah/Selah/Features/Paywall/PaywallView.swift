import SwiftUI

struct PaywallView: View {
    @Environment(AppEnvironment.self) private var env
    @Binding var showExitMonthly: Bool
    var onRestore: () -> Void

    @State private var selectedTier: SubscriptionTier = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        let emphasizeWeekly = PaywallExitPolicy.shouldEmphasizeWeekly(
            paywallPresentationCount: env.subscription.paywallPresentationCount
        )
        SelahFlowScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeroImageView(name: "selah-hero-window")
                        .frame(height: 168)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text("SELAH PREMIUM")
                        .font(SelahFont.figtree(12, weight: .semibold))
                        .foregroundStyle(SelahColors.gold)

                    Text(OnboardingCopy.paywallHeadline(distance: env.quizDistance))
                        .font(SelahFont.newsreader(28, weight: .semibold))
                        .foregroundStyle(SelahColors.text)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("5 minutes a day. Private. On your phone.")
                        .font(SelahFont.figtree(16))
                        .foregroundStyle(SelahColors.textMuted)

                    if emphasizeWeekly {
                        Text("Most people start weekly — then keep going.")
                            .font(SelahFont.figtree(14, weight: .medium))
                            .foregroundStyle(SelahColors.gold)
                    }

                    VStack(spacing: 10) {
                        ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                            PaywallTierRow(
                                tier: tier,
                                selected: selectedTier == tier,
                                emphasizeWeekly: emphasizeWeekly && tier == .weekly
                            ) { selectedTier = tier }
                        }
                    }

                    Text("Cancel anytime. No trial — you start today.")
                        .font(SelahFont.figtree(13))
                        .foregroundStyle(SelahColors.textSoft)

                    HStack(spacing: 16) {
                        if let url = URL(string: AppConfiguration.privacyPolicyURL) {
                            Link("Privacy", destination: url)
                        }
                        if let url = URL(string: AppConfiguration.termsURL) {
                            Link("Terms", destination: url)
                        }
                        Button("Restore", action: onRestore)
                    }
                    .font(SelahFont.figtree(13))
                    .foregroundStyle(SelahColors.textMuted)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(SelahFont.figtree(13))
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .selahFlowScrollContent()
        } bottom: {
            SelahPinnedBottomBar {
                VStack(spacing: 10) {
                    SelahPrimaryButton(
                        title: isPurchasing ? "Working…" : "Start Selah",
                        style: .gold,
                        isLoading: isPurchasing,
                        action: { Task { await purchase() } }
                    )
                    .disabled(isPurchasing)
                    .accessibilityIdentifier("paywall.subscribe")

                    Button("See monthly plan") {
                        selectedTier = .monthly
                        showExitMonthly = true
                    }
                    .font(SelahFont.figtree(14))
                    .foregroundStyle(SelahColors.textMuted)
                }
            }
        }
        .onAppear {
            if PaywallExitPolicy.defaultTierIsYearly(
                paywallPresentationCount: env.subscription.paywallPresentationCount
            ) {
                selectedTier = .yearly
            } else {
                selectedTier = .weekly
            }
        }
        .interactiveDismissDisabled()
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        let ok = await env.subscription.purchase(selectedTier, surface: "onboarding_paywall")
        if ok {
            AnalyticsService.track("subscribe", properties: ["tier": selectedTier.rawValue])
        } else {
            let cancelled = PaywallExitPolicy.shouldShowMonthlyExitOffer(
                paymentSheetCancelled: true,
                seeMonthlyPlanTapped: false
            )
            if cancelled { showExitMonthly = true }
            errorMessage = env.subscription.lastError ?? "Purchase didn’t finish. Try again or restore."
        }
    }
}

private struct PaywallTierRow: View {
    let tier: SubscriptionTier
    let selected: Bool
    let emphasizeWeekly: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tier.title)
                            .font(SelahFont.figtree(16, weight: .semibold))
                            .foregroundStyle(SelahColors.text)
                        if emphasizeWeekly {
                            Text("Popular")
                                .font(SelahFont.figtree(11, weight: .semibold))
                                .foregroundStyle(SelahColors.gold)
                        }
                    }
                    Text(tier.priceLabel)
                        .font(SelahFont.figtree(13))
                        .foregroundStyle(SelahColors.textMuted)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SelahColors.gold)
                }
            }
            .padding(14)
            .background(SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? SelahColors.gold : SelahColors.text.opacity(0.08), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("paywall.tier.\(tier.rawValue)")
    }
}

struct ExitMonthlyOfferView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Start with monthly")
                .font(SelahFont.newsreader(24, weight: .semibold))
            Text("$14.99 / month. Same private space. Cancel anytime.")
                .font(SelahFont.figtree(16))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
            SelahPrimaryButton(title: "Use monthly", action: onDismiss)
            Button("Keep looking", action: onDismiss)
                .font(SelahFont.figtree(14))
                .foregroundStyle(SelahColors.textMuted)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}
