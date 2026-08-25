import XCTest
@testable import Selah

final class OnboardingCopyTests: XCTestCase {
    func testWelcomeCopyMatchesMockV4() {
        XCTAssertEqual(OnboardingCopy.welcomeTitle, "Selah")
        XCTAssertEqual(OnboardingCopy.welcomeSubtitle, "Pause · Reflect · Listen")
        XCTAssertEqual(OnboardingCopy.welcomeVerse, "Be still, and know that I am God.")
        XCTAssertEqual(OnboardingCopy.welcomeVerseRef, "Psalm 46:10 · KJV")
        XCTAssertEqual(OnboardingCopy.welcomeCTA, "Begin")
        XCTAssertEqual(OnboardingCopy.welcomeDurationHint, "Takes about 2 minutes")
        XCTAssertTrue(OnboardingCopy.welcomeMeaning.contains("stop here"))
        XCTAssertTrue(OnboardingCopy.welcomeMeaning.contains("Breathe"))
    }

    func testHookCopyMatchesMockV4() {
        XCTAssertEqual(
            OnboardingCopy.hookTitle,
            "You have time to scroll for hours. Five minutes with God feels hard."
        )
        XCTAssertEqual(
            OnboardingCopy.hookBody,
            "It is not because you don’t love him. It is because nothing in your day makes room for him."
        )
        XCTAssertEqual(OnboardingCopy.hookCTA, "That’s true for me")
    }

    func testQuizDistanceHasExactlyFourOptions() {
        XCTAssertEqual(OnboardingDistance.allCases.count, 4)
        XCTAssertEqual(
            OnboardingDistance.allCases.map(\.title),
            ["A busy life", "Guilt or heaviness", "Inconsistency", "I feel distant"]
        )
        XCTAssertEqual(
            OnboardingDistance.allCases.map(\.mirrorPhrase),
            ["a full life", "a heavy heart", "stop–start weeks", "a quiet distance"]
        )
    }

    func testQuizDesireHasExactlyFourOptionsFromV4() {
        XCTAssertEqual(OnboardingDesire.allCases.count, 4)
        XCTAssertEqual(
            OnboardingDesire.allCases.map(\.title),
            ["Peace", "Daily consistency", "Freedom from guilt", "Know Scripture"]
        )
        XCTAssertEqual(OnboardingDesire.know.mirrorPhrase, "to know Scripture")
    }

    func testHabitHasFourV4Options() {
        XCTAssertEqual(OnboardingHabit.allCases.count, 4)
        XCTAssertEqual(OnboardingHabit.allCases.map(\.title), ["Never", "Sometimes", "Often", "Daily"])
        XCTAssertEqual(OnboardingHabit.sometimes.subtitle, "A few times a month")
    }

    func testDemoMoodsMatchMockV4() {
        XCTAssertEqual(OnboardingMood.allCases.map(\.title), ["Heavy", "Anxious", "Grateful", "Empty"])
        XCTAssertEqual(OnboardingMood.heavy.scripture.reference, "Psalm 55:22")
        XCTAssertEqual(OnboardingMood.empty.scripture.reference, "Psalm 23:3")
        XCTAssertEqual(OnboardingMood.grateful.scripture.text, "O give thanks unto the Lord; for he is good.")
    }

    func testPrePaywallScreenCountSkipsWidget() {
        XCTAssertEqual(OnboardingCopy.prePaywallScreenCount, 14)
        XCTAssertEqual(OnboardingCopy.eventName(for: 1), "onboarding_01_welcome")
        XCTAssertEqual(OnboardingCopy.eventName(for: 16), "paywall_view")
        XCTAssertEqual(OnboardingCopy.eventName(for: 17), "onboarding_17_notifications")
        XCTAssertEqual(OnboardingStep.social.analyticsEvent, "onboarding_15_social")
    }

    func testCommitmentAndPrivacyCopy() {
        XCTAssertEqual(OnboardingCopy.commitmentTitle, "Will you make space for God this week?")
        XCTAssertEqual(
            OnboardingCopy.commitmentBody,
            "Five minutes a day. Not a performance. A place to return to."
        )
        XCTAssertEqual(OnboardingCopy.privacyTitle, "Your prayers stay on this phone.")
        XCTAssertEqual(OnboardingCopy.privacySubtitle, "Not the cloud. Not us. Not anyone.")
    }

    func testSocialAndNotificationCopyMatchV4() {
        XCTAssertEqual(OnboardingCopy.socialTitle, "People who felt far away kept coming back")
        XCTAssertTrue(OnboardingCopy.socialQuotes[0].contains("doesn’t shame me"))
        XCTAssertEqual(OnboardingCopy.notificationTitle, "A gentle reminder each morning?")
        XCTAssertEqual(OnboardingCopy.notificationAllowCTA, "Yes, remind me")
        XCTAssertEqual(OnboardingCopy.notificationSkipCTA, "Not now")
    }

    func testDesireMapsToReadingPlanTheme() {
        XCTAssertEqual(OnboardingDesire.peace.planKey, "peace")
        XCTAssertEqual(OnboardingDesire.daily.planKey, "consistency")
        XCTAssertEqual(OnboardingDesire.free.planKey, "freedom")
        XCTAssertEqual(OnboardingDesire.know.planKey, "scripture")
    }

    func testMirrorUsesV4Phrases() {
        let text = OnboardingCopy.mirrorText(desire: .peace, distance: .busy)
        XCTAssertEqual(text, "You want peace. And a full life has made it hard to find.")
    }
}
