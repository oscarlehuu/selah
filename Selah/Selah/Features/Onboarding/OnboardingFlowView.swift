import SwiftUI

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

    var body: some View {
        NavigationStack {
            Group {
                if step.hidesStandardOnboardingChrome {
                    WelcomeSanctuaryView(onBegin: advance)
                } else {
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
                    .selahCanvas()
                    .safeAreaInset(edge: .bottom) {
                        if step != .building {
                            standardFooter
                        }
                    }
                }
            }
            .navigationTitle(step.hidesStandardOnboardingChrome ? "" : step.navigationTitle)
            .navigationBarTitleDisplayMode(step.hidesStandardOnboardingChrome ? .inline : .large)
            .toolbarBackground(step.hidesStandardOnboardingChrome ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                if stepIndex > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", action: goBack)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip", action: skipToPaywall)
                        .accessibilityIdentifier("onboarding.skip")
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

    private var standardFooter: some View {
        SelahFooterBar {
            if let verse = step.footVerse {
                FootVerseCaption(text: verse.text, ref: verse.ref)
            }
            SelahPrimaryButton(
                title: step.primaryCTA,
                style: step == .demoMood ? .gold : .primary,
                isLoading: isGenerating,
                action: advance
            )
            .disabled(!canAdvance || isGenerating)
            .accessibilityIdentifier("onboarding.continue")
            if step == .commitment {
                Button("I want to try", action: advance)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
            }
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
