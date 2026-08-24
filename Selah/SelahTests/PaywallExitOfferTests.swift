import XCTest
@testable import Selah

final class PaywallExitOfferTests: XCTestCase {
    func testMonthlyExitAfterPaymentCancelled() {
        XCTAssertTrue(PaywallExitPolicy.shouldShowMonthlyExitOffer(
            paymentSheetCancelled: true,
            seeMonthlyPlanTapped: false
        ))
    }

    func testMonthlyExitAfterSeeMonthlyLink() {
        XCTAssertTrue(PaywallExitPolicy.shouldShowMonthlyExitOffer(
            paymentSheetCancelled: false,
            seeMonthlyPlanTapped: true
        ))
    }

    func testNoMonthlyExitWithoutTrigger() {
        XCTAssertFalse(PaywallExitPolicy.shouldShowMonthlyExitOffer(
            paymentSheetCancelled: false,
            seeMonthlyPlanTapped: false
        ))
    }

    func testWeeklyEmphasisOnSecondPaywallPresentation() {
        XCTAssertTrue(PaywallExitPolicy.shouldEmphasizeWeekly(paywallPresentationCount: 2))
        XCTAssertTrue(PaywallExitPolicy.shouldEmphasizeWeekly(paywallPresentationCount: 5))
    }

    func testYearlyDefaultOnFirstPaywallPresentation() {
        XCTAssertTrue(PaywallExitPolicy.defaultTierIsYearly(paywallPresentationCount: 1))
        XCTAssertFalse(PaywallExitPolicy.shouldEmphasizeWeekly(paywallPresentationCount: 1))
        XCTAssertFalse(PaywallExitPolicy.shouldEmphasizeWeekly(paywallPresentationCount: 0))
    }
}
