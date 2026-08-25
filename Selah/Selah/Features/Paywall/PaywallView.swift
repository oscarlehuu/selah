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
        NavigationStack {
            List {
                Section {
                    Text(OnboardingCopy.paywallHeadline(distance: env.quizDistance, desire: env.quizDesire))
                        .font(SelahFont.display(.title2))
                    Text("5 minutes a day. Private. On your phone.")
                        .foregroundStyle(.secondary)
                    if emphasizeWeekly {
                        Text("Most people start weekly — then keep going.")
                            .foregroundStyle(SelahColors.accent)
                    }
                }
                Section("Included") {
                    Label("Private by design", systemImage: "lock.fill")
                    Label("5 minutes a day", systemImage: "book.fill")
                    Label("Guided prayer", systemImage: "hands.sparkles.fill")
                }
                Section {
                    ForEach(orderedTiers(emphasizeWeekly: emphasizeWeekly), id: \.self) { tier in
                        Button {
                            selectedTier = tier
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(tier.title)
                                        if tier == .yearly {
                                            Text("Best value")
                                                .font(SelahFont.ui(.caption2, weight: .semibold))
                                                .foregroundStyle(SelahColors.accent)
                                        }
                                        if emphasizeWeekly && tier == .weekly {
                                            Text("Popular")
                                                .font(SelahFont.ui(.caption2, weight: .semibold))
                                                .foregroundStyle(SelahColors.accent)
                                        }
                                    }
                                    Text(tier.detailLabel)
                                        .font(SelahFont.ui(.footnote))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(tier.shortPrice)
                                    .font(SelahFont.ui(.body, weight: .semibold))
                                if selectedTier == tier {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(SelahColors.primaryDeep)
                                }
                            }
                        }
                        .accessibilityIdentifier("paywall.tier.\(tier.rawValue)")
                    }
                } header: {
                    Text("Choose a plan")
                } footer: {
                    Text("Auto-renews until cancelled. \(OnboardingCopy.companionDisclaimer) It does not replace a pastor, priest, counsellor, or sacramental confession.")
                }
                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Selah Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore", action: onRestore)
                        .accessibilityIdentifier("paywall.restore")
                }
            }
            .safeAreaInset(edge: .bottom) {
                SelahFooterBar {
                    SelahPrimaryButton(
                        title: isPurchasing ? "Working…" : "Start Selah · \(selectedTier.ctaPrice)",
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
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    HStack(spacing: 16) {
                        if let url = URL(string: AppConfiguration.privacyPolicyURL) {
                            Link("Privacy", destination: url)
                        }
                        if let url = URL(string: AppConfiguration.termsURL) {
                            Link("Terms", destination: url)
                        }
                    }
                    .font(SelahFont.ui(.footnote))
                }
            }
        }
        .tint(SelahColors.primaryDeep)
        .interactiveDismissDisabled()
        .onAppear {
            selectedTier = PaywallExitPolicy.defaultTierIsYearly(
                paywallPresentationCount: env.subscription.paywallPresentationCount
            ) ? .yearly : .weekly
        }
        .accessibilityIdentifier("gate.paywall")
    }

    private func orderedTiers(emphasizeWeekly: Bool) -> [SubscriptionTier] {
        emphasizeWeekly ? [.weekly, .yearly, .monthly] : [.weekly, .yearly, .monthly]
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        let ok = await env.subscription.purchase(selectedTier, surface: "onboarding_paywall")
        if ok {
            AnalyticsService.track("subscribe", properties: ["tier": selectedTier.rawValue])
        } else {
            if PaywallExitPolicy.shouldShowMonthlyExitOffer(
                paymentSheetCancelled: true,
                seeMonthlyPlanTapped: false
            ) {
                showExitMonthly = true
            }
            errorMessage = env.subscription.lastError ?? "Purchase didn’t finish. Try again or restore."
        }
    }
}

struct ExitMonthlyOfferView: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Start with monthly",
                systemImage: "calendar",
                description: Text("$14.99 / month. Same private space. Cancel anytime.")
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Keep looking", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use monthly", action: onDismiss)
                }
            }
            .navigationTitle("Monthly plan")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
