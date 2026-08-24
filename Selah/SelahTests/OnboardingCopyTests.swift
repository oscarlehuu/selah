import XCTest
@testable import Selah

final class OnboardingCopyTests: XCTestCase {
    func testWelcomeCopyMatchesMockV3() {
        XCTAssertEqual(OnboardingCopy.welcomeTitle, "Selah")
        XCTAssertEqual(OnboardingCopy.welcomeSubtitle, "Pause · Reflect · Listen")
        XCTAssertEqual(OnboardingCopy.welcomeVerse, "Be still, and know that I am God.")
        XCTAssertEqual(OnboardingCopy.welcomeCTA, "Begin")
    }

    func testQuizDistanceHasExactlyFourOptions() {
        XCTAssertEqual(OnboardingDistance.allCases.count, 4)
        XCTAssertEqual(
            OnboardingDistance.allCases.map(\.title),
            ["A busy life", "Guilt or heaviness", "Inconsistency", "I feel distant"]
        )
    }

    func testQuizDesireHasExactlyFourOptions() {
        XCTAssertEqual(OnboardingDesire.allCases.count, 4)
        XCTAssertEqual(
            OnboardingDesire.allCases.map(\.title),
            ["Peace", "Daily consistency", "Freedom from guilt", "Know Scripture better"]
        )
    }

    func testPrePaywallScreenCountIsFifteen() {
        XCTAssertEqual(OnboardingCopy.prePaywallScreenCount, 15)
        XCTAssertEqual(OnboardingCopy.eventName(for: 1), "onboarding_01_welcome")
        XCTAssertEqual(OnboardingCopy.eventName(for: 15), "onboarding_15_social")
        XCTAssertEqual(OnboardingCopy.eventName(for: 16), "paywall_view")
        XCTAssertEqual(OnboardingCopy.eventName(for: 17), "onboarding_17_notifications")
    }

    func testPaywallHeadlineBranchesFromDistanceQuiz() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .distant),
            "Start talking to God every day"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .inconsistent),
            "Read the Bible 5 minutes a day — without quitting"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .guilt),
            "A private space to talk to God"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .busy),
            "Start talking to God every day"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: nil),
            "Your private space with God"
        )
    }

    func testDesireMapsToReadingPlanTheme() {
        XCTAssertEqual(OnboardingDesire.peace.planKey, "peace")
        XCTAssertEqual(OnboardingDesire.daily.planKey, "consistency")
        XCTAssertEqual(OnboardingDesire.free.planKey, "freedom")
        XCTAssertEqual(OnboardingDesire.know.planKey, "scripture")
    }

    func testMirrorUsesQuizAnswers() {
        let text = OnboardingCopy.mirrorText(desire: .peace, distance: .busy)
        XCTAssertTrue(text.contains("Peace"))
        XCTAssertTrue(text.contains("busy") || text.contains("Busy"))
    }
}
