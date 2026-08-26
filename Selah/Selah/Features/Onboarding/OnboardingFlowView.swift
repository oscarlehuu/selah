import SwiftUI

/// Mock v4 `.ob` canvas — soft blue radial at the top, warm gold radial at the
/// bottom, over the Sunday Light background. Gives every onboarding screen the
/// tinted "header" region instead of a flat white page.
struct OnboardingCanvas: View {
    var body: some View {
        ZStack {
            SelahColors.background
            RadialGradient(
                colors: [Color(hex: 0xC6D9F8).opacity(0.5), .clear],
                center: .init(x: 0.5, y: -0.08),
                startRadius: 0,
                endRadius: 420
            )
            RadialGradient(
                colors: [Color(hex: 0xFFE09E).opacity(0.3), .clear],
                center: .init(x: 0.5, y: 1.1),
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

struct OnboardingFlowView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var stepIndex = 0
    @State private var distance: OnboardingDistance?
    @State private var desire: OnboardingDesire?
    @State private var habit: OnboardingHabit?
    @State private var mood: OnboardingMood?
    @State private var demoResult = ""
    @State private var isGenerating = false
    @State private var buildProgress = 0.0

    private var steps: [OnboardingStep] { OnboardingStep.prePaywall }
    private var step: OnboardingStep { steps[stepIndex] }
    /// Hero-backed screens draw the top bar in light style over the photo, like `.ob-top` on-hero.
    private var heroBacked: Bool { step == .welcome || step == .hook }

    var body: some View {
        ZStack(alignment: .top) {
            OnboardingStepContent(
                step: step,
                distance: $distance,
                desire: $desire,
                habit: $habit,
                mood: $mood,
                demoResult: demoResult,
                isGenerating: isGenerating,
                buildProgress: buildProgress
            )
            .background(OnboardingCanvas())

            // Mock v4 `.ob-top` — back circle · progress line · Skip, overlaying the hero.
            OnboardingTopBar(
                showBack: stepIndex > 0,
                progress: Double(stepIndex + 1) / Double(steps.count),
                lightStyle: heroBacked,
                onBack: goBack,
                onSkip: skipToPaywall
            )

            VStack(spacing: 0) {}
        }
        .safeAreaInset(edge: .bottom) {
            if step != .building {
                SelahFooterBar {
                    if let verse = step.footVerse {
                        FootVerseCaption(text: verse.text, ref: verse.ref)
                    }
                    SelahPrimaryButton(
                        title: step.primaryCTA,
                        style: footerButtonStyle,
                        isLoading: isGenerating,
                        action: advance
                    )
                    .disabled(!canAdvance || isGenerating)
                    .accessibilityIdentifier("onboarding.continue")
                    if step == .commitment {
                        Button("I want to try", action: advance)
                            .font(SelahFont.ui(.subheadline, weight: .semibold))
                            .foregroundStyle(SelahColors.textMuted)
                    }
                    if step == .welcome {
                        Text(OnboardingCopy.welcomeDurationHint)
                            .font(SelahFont.ui(.footnote))
                            .foregroundStyle(SelahColors.textSoft)
                    }
                }
            }
        }
        .tint(SelahColors.primaryDeep)
        .selahRootChrome()
        .onAppear { track() }
        .task(id: step) {
            if step == .building {
                await runBuildThenAdvance()
            }
        }
    }

    /// Mock v4 CTA styles — gold only where the prototype uses `.btn-gold`.
    private var footerButtonStyle: SelahPrimaryButton.Style {
        switch step {
        case .welcome, .commitment, .demoMood: .gold
        default: .primary
        }
    }

    private var canAdvance: Bool {
        step.canAdvance(distance: distance, desire: desire, habit: habit, mood: mood)
    }

    private func goBack() {
        guard stepIndex > 0 else { return }
        stepIndex -= 1
        track()
    }

    private func skipToPaywall() {
        env.completeOnboarding(
            distance: distance ?? .distant,
            desire: desire ?? .peace,
            habit: habit ?? .sometimes
        )
    }

    private func advance() {
        if step == .demoMood {
            isGenerating = true
            Task {
                demoResult = await CompanionTextService.reflection(for: mood?.title ?? "heavy")
                isGenerating = false
                moveNext()
            }
            return
        }
        if step == .social {
            AnalyticsService.track("onboarding_15_social")
            env.completeOnboarding(
                distance: distance ?? .distant,
                desire: desire ?? .peace,
                habit: habit ?? .sometimes
            )
            return
        }
        moveNext()
    }

    private func moveNext() {
        guard stepIndex < steps.count - 1 else { return }
        stepIndex += 1
        track()
    }

    private func runBuildThenAdvance() async {
        buildProgress = 0
        for value in stride(from: 0.2, through: 1.0, by: 0.2) {
            try? await Task.sleep(for: .milliseconds(280))
            buildProgress = value
        }
        try? await Task.sleep(for: .milliseconds(350))
        if step == .building { moveNext() }
    }

    private func track() {
        AnalyticsService.track(step.analyticsEvent)
    }
}

/// Mock v4 `.ob-top`: circular back button, thin progress line, plain-text Skip.
struct OnboardingTopBar: View {
    let showBack: Bool
    let progress: Double
    var lightStyle: Bool
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if showBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(foreground)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(circleFill))
                }
                .accessibilityLabel("Back")
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(trackColor)
                    Capsule()
                        .fill(fillColor)
                        .frame(width: max(0, proxy.size.width * progress))
                }
            }
            .frame(height: 3)
            .animation(.easeOut(duration: 0.35), value: progress)
            Button("Skip", action: onSkip)
                .font(SelahFont.ui(.subheadline, weight: .semibold))
                .foregroundStyle(foreground.opacity(0.75))
                .accessibilityIdentifier("onboarding.skip")
        }
        .padding(.horizontal, 14)
        .padding(.top, 2)
    }

    private var foreground: Color { lightStyle ? .white : SelahColors.text }
    private var circleFill: Color { lightStyle ? Color.white.opacity(0.18) : Color.clear }
    private var trackColor: Color { lightStyle ? Color.white.opacity(0.35) : SelahColors.text.opacity(0.12) }
    private var fillColor: Color { lightStyle ? .white : SelahColors.primaryDeep }
}
