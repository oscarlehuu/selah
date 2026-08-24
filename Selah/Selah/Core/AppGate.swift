import Foundation

enum AppGate {
    static func shouldShowMainApp(isSubscribed: Bool, isDemoMode: Bool) -> Bool {
        isDemoMode || isSubscribed
    }

    static func shouldShowPaywall(
        isSubscribed: Bool,
        isDemoMode: Bool,
        onboardingComplete: Bool
    ) -> Bool {
        onboardingComplete && !shouldShowMainApp(isSubscribed: isSubscribed, isDemoMode: isDemoMode)
    }
}
