import XCTest
@testable import Selah

final class PaywallHeadlineTests: XCTestCase {
    func testGuiltOrFreedomDesireUsesPrivateSpaceHeadline() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .guilt, desire: .peace),
            "A private space to talk to God"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .busy, desire: .free),
            "A private space to talk to God"
        )
    }

    func testInconsistencyOrDailyDesireUsesHabitHeadline() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .inconsistent, desire: .peace),
            "Read the Bible 5 minutes a day, without quitting"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .distant, desire: .daily),
            "Read the Bible 5 minutes a day, without quitting"
        )
    }

    func testDistantOrPeaceUsesTalkHeadline() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .distant, desire: .know),
            "Start talking to God every day"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .busy, desire: .peace),
            "Start talking to God every day"
        )
    }

    func testDefaultHeadlineWhenQuizSkipped() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: nil, desire: nil),
            "Your private space with God"
        )
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .busy, desire: .know),
            "Your private space with God"
        )
    }

    func testGuiltTakesPriorityOverDailyDesire() {
        XCTAssertEqual(
            OnboardingCopy.paywallHeadline(distance: .guilt, desire: .daily),
            "A private space to talk to God"
        )
    }
}
