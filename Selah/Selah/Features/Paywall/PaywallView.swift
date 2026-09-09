import SwiftUI

/// Mock v4 screen 16 — hard paywall (`paywall_view`, CSS `.pw-*` / `.tier`).
struct PaywallView: View {
    @Environment(AppEnvironment.self) private var env
    var onRestore: () -> Void

    @State private var selectedTier: SubscriptionTier
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private let tiers: [SubscriptionTier] = [.weekly, .yearly, .monthly]

    init(onRestore: @escaping () -> Void) {
        self.onRestore = onRestore
        _selectedTier = State(initialValue: .yearly)
    }

    var body: some View {
        ZStack {
            SelahColors.background.ignoresSafeArea()
            // Full-bleed layout: hero starts at absolute top (mock `.pw-hero` sits
            // under the status bar), footer flows after the tiers and anchors to
            // the bottom when content is short — never overlays the cards.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // `.pw-hero` — window photo + veil from y = 0
                        OnboardingHero(style: .photoWindow, height: 118 + proxy.safeAreaInsets.top) { EmptyView() }
                        content
                        Spacer(minLength: 8)
                        footer
                            .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 14 : 0)
                    }
                    .frame(minHeight: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
                }
                .scrollIndicators(.hidden)
                .accessibilityIdentifier("gate.paywall")
                .ignoresSafeArea()
            }
        }
        .tint(SelahColors.primaryDeep)
        .selahRootChrome()
        .interactiveDismissDisabled()
        .onAppear(perform: applyPaywallPresentationPolicy)
    }

    private func applyPaywallPresentationPolicy() {
        let count = env.subscription.paywallPresentationCount
        if PaywallExitPolicy.shouldEmphasizeWeekly(paywallPresentationCount: count) {
            selectedTier = .weekly
            AnalyticsService.track("paywall_relaunch_weekly_emphasis", properties: ["presentation": count])
        } else if PaywallExitPolicy.defaultTierIsYearly(paywallPresentationCount: count) {
            selectedTier = .yearly
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(OnboardingCopy.paywallHeadline(distance: env.quizDistance, desire: env.quizDesire))
                            .font(SelahFont.display(.title2))
                            .foregroundStyle(SelahColors.text)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        // `.pw-bullets`
                        VStack(alignment: .leading, spacing: 10) {
                            bullet(icon: "lock.fill", title: "Private by design",
                                   sub: "Talk, reflect, confess. On-device only.")
                            bullet(icon: "book.fill", title: "5 minutes a day",
                                   sub: "Your \(planThemeLabel) plan, offline Bible, gentle streak.")
                            bullet(icon: "hands.sparkles.fill", title: "Guided prayer",
                                   sub: "Lectio Divina and prayers for the mood you’re actually in.")
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 16)
                        // `.tiers` radiogroup
                        VStack(spacing: 9) {
                            ForEach(tiers, id: \.self) { tier in
                                tierCard(tier)
                            }
                        }
                        if let errorMessage {
                            Text(errorMessage)
                                .font(SelahFont.ui(.footnote))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 12)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
        }
    }

    // MARK: `.pw-bullets li`

    private func bullet(icon: String, title: String, sub: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            SelahIconTile(systemImage: icon, size: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
                Text(sub)
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(SelahColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: `.tier`

    private func tierCard(_ tier: SubscriptionTier) -> some View {
        let selected = selectedTier == tier
        return Button {
            selectedTier = tier
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(tier.title)
                        .font(SelahFont.ui(.body, weight: .bold))
                        .foregroundStyle(selected ? SelahColors.accentDeep : SelahColors.text)
                    Text(tier.detailLabel)
                        .font(SelahFont.ui(.caption))
                        .foregroundStyle(SelahColors.textSoft)
                }
                Spacer()
                // `.tier .price`
                VStack(alignment: .trailing, spacing: 0) {
                    Text(tier.shortPrice)
                        .font(SelahFont.ui(.body, weight: .bold))
                        .foregroundStyle(selected ? SelahColors.accentDeep : SelahColors.text)
                    Text(unitLabel(tier))
                        .font(SelahFont.ui(.caption2))
                        .foregroundStyle(SelahColors.textSoft)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? SelahColors.accentSoft : SelahColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? SelahColors.accent : SelahColors.border, lineWidth: 1.5)
            )
            .shadow(color: selected ? Color(hex: 0xC48A28).opacity(0.16) : .clear, radius: 7, y: 4)
            // `.tier .badge` — floating "BEST VALUE" capsule
            .overlay(alignment: .topLeading) {
                if tier == .yearly {
                    Text("Best value")
                        .font(SelahFont.ui(.caption2, weight: .bold))
                        .textCase(.uppercase)
                        .kerning(0.4)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(SelahColors.goldGradient))
                        .shadow(color: Color(hex: 0xB98A28).opacity(0.3), radius: 3, y: 2)
                        .offset(x: 14, y: -9)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .accessibilityIdentifier("paywall.tier.\(tier.rawValue)")
    }

    // MARK: `.ob-foot`

    private var footer: some View {
        SelahFooterBar {
            SelahPrimaryButton(
                title: isPurchasing ? "Working…" : "Start Selah · \(selectedTier.ctaPrice)",
                style: .gold,
                isLoading: isPurchasing,
                action: { Task { await purchase() } }
            )
            .disabled(isPurchasing)
            .accessibilityIdentifier("paywall.subscribe")
            Text("Auto-renews until cancelled. \(OnboardingCopy.companionDisclaimer) It does not replace a pastor, priest, counsellor, or sacramental confession.")
                .font(SelahFont.ui(.caption2))
                .foregroundStyle(SelahColors.textSoft)
                .multilineTextAlignment(.center)
            // `.pw-legal`
            HStack(spacing: 14) {
                Button("Restore purchase", action: onRestore)
                    .accessibilityIdentifier("paywall.restore")
                if let url = URL(string: AppConfiguration.termsURL) {
                    Link("Terms", destination: url)
                }
                if let url = URL(string: AppConfiguration.privacyPolicyURL) {
                    Link("Privacy", destination: url)
                }
            }
            .font(SelahFont.ui(.caption2))
            .foregroundStyle(SelahColors.textSoft)
            .underline()
        }
    }

    private func unitLabel(_ tier: SubscriptionTier) -> String {
        switch tier {
        case .weekly: "per week"
        case .monthly: "per month"
        case .yearly: "per year"
        }
    }

    private var planThemeLabel: String {
        env.quizDesire?.planLabel.lowercased() ?? env.currentPlanTheme?.label.lowercased() ?? "peace"
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        let ok = await env.subscription.purchase(selectedTier, surface: "onboarding_paywall")
        if !ok {
            errorMessage = env.subscription.lastError ?? "Purchase didn’t finish. Try again or restore."
        }
    }
}
