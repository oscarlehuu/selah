import XCTest
@testable import Selah

final class OnboardingFlowMappingTests: XCTestCase {
    func testPrePaywallFlowSkipsWidgetComingSoon() {
        XCTAssertEqual(OnboardingStep.prePaywall.count, 14)
        XCTAssertFalse(OnboardingStep.prePaywall.contains(.widget))
        XCTAssertFalse(OnboardingCopy.prePaywallEventNames.contains("onboarding_14_widget"))
    }

    func testPrePaywallOrderMatchesMockV4MinusWidget() {
        XCTAssertEqual(
            OnboardingStep.prePaywall.map(\.analyticsEvent),
            [
                "onboarding_01_welcome",
                "onboarding_02_hook",
                "onboarding_03_stat",
                "onboarding_04_quiz_distance",
                "onboarding_05_quiz_desire",
                "onboarding_06_quiz_habit",
                "onboarding_07_mirror",
                "onboarding_08_commitment",
                "onboarding_09_privacy",
                "onboarding_10_demo",
                "onboarding_11_demo_result",
                "onboarding_12_building",
                "onboarding_13_plan",
                "onboarding_15_social"
            ]
        )
    }

    func testQuizContinueRequiresSelection() {
        XCTAssertFalse(OnboardingStep.quizDistance.canAdvance(distance: nil, desire: nil, habit: nil, mood: nil))
        XCTAssertTrue(OnboardingStep.quizDistance.canAdvance(distance: .busy, desire: nil, habit: nil, mood: nil))
        XCTAssertFalse(OnboardingStep.quizDesire.canAdvance(distance: .busy, desire: nil, habit: nil, mood: nil))
        XCTAssertTrue(OnboardingStep.quizDesire.canAdvance(distance: .busy, desire: .peace, habit: nil, mood: nil))
        XCTAssertFalse(OnboardingStep.quizHabit.canAdvance(distance: .busy, desire: .peace, habit: nil, mood: nil))
        XCTAssertTrue(OnboardingStep.quizHabit.canAdvance(distance: .busy, desire: .peace, habit: .sometimes, mood: nil))
        XCTAssertFalse(OnboardingStep.demoMood.canAdvance(distance: .busy, desire: .peace, habit: .sometimes, mood: nil))
        XCTAssertTrue(OnboardingStep.demoMood.canAdvance(distance: .busy, desire: .peace, habit: .sometimes, mood: .heavy))
    }

    func testNonQuizStepsAdvanceWithoutAnswers() {
        XCTAssertTrue(OnboardingStep.welcome.canAdvance(distance: nil, desire: nil, habit: nil, mood: nil))
        XCTAssertTrue(OnboardingStep.social.canAdvance(distance: nil, desire: nil, habit: nil, mood: nil))
    }

    func testSkipJumpsToPaywallFromAnyPrePaywallStep() {
        for step in OnboardingStep.prePaywall {
            XCTAssertTrue(step.allowsSkipToPaywall)
        }
    }

    func testComingSoonIsNotProductCopy() {
        XCTAssertFalse(OnboardingCopy.welcomeTitle.localizedCaseInsensitiveContains("coming soon"))
        XCTAssertFalse(OnboardingCopy.socialTitle.localizedCaseInsensitiveContains("coming soon"))
        XCTAssertFalse(OnboardingCopy.notificationTitle.localizedCaseInsensitiveContains("coming soon"))
        XCTAssertFalse(OnboardingCopy.paywallBullets.joined().localizedCaseInsensitiveContains("coming soon"))
    }
}
