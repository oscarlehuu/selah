import Foundation

enum PaywallExitPolicy {
    static func shouldShowMonthlyExitOffer(
        paymentSheetCancelled: Bool,
        seeMonthlyPlanTapped: Bool
    ) -> Bool {
        paymentSheetCancelled || seeMonthlyPlanTapped
    }

    static func shouldEmphasizeWeekly(paywallPresentationCount: Int) -> Bool {
        paywallPresentationCount >= 2
    }

    static func defaultTierIsYearly(paywallPresentationCount: Int) -> Bool {
        !shouldEmphasizeWeekly(paywallPresentationCount: paywallPresentationCount)
    }
}
