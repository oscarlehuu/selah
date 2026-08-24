import XCTest
@testable import Selah

final class PaywallGateTests: XCTestCase {
    func testSubscribedUserSeesMainApp() {
        XCTAssertTrue(AppGate.shouldShowMainApp(isSubscribed: true, isDemoMode: false))
    }

    func testUnsubscribedUserBlockedFromMainApp() {
        XCTAssertFalse(AppGate.shouldShowMainApp(isSubscribed: false, isDemoMode: false))
    }

    func testDemoModeBypassesPaywall() {
        XCTAssertTrue(AppGate.shouldShowMainApp(isSubscribed: false, isDemoMode: true))
    }

    func testPaywallAfterOnboardingWhenNotSubscribed() {
        XCTAssertTrue(
            AppGate.shouldShowPaywall(
                isSubscribed: false,
                isDemoMode: false,
                onboardingComplete: true
            )
        )
    }

    func testNoPaywallWhenSubscribedAfterOnboarding() {
        XCTAssertFalse(
            AppGate.shouldShowPaywall(
                isSubscribed: true,
                isDemoMode: false,
                onboardingComplete: true
            )
        )
    }

    func testNoPaywallBeforeOnboardingComplete() {
        XCTAssertFalse(
            AppGate.shouldShowPaywall(
                isSubscribed: false,
                isDemoMode: false,
                onboardingComplete: false
            )
        )
    }

    func testRelaunchUnsubscribedStillBlocked() {
        XCTAssertFalse(AppGate.shouldShowMainApp(isSubscribed: false, isDemoMode: false))
        XCTAssertTrue(
            AppGate.shouldShowPaywall(
                isSubscribed: false,
                isDemoMode: false,
                onboardingComplete: true
            )
        )
    }
}
