import Foundation

enum OnboardingDistance: String, CaseIterable, Identifiable {
    case busy, guilt, inconsistent, distant

    var id: String { rawValue }

    var title: String {
        switch self {
        case .busy: "A busy life"
        case .guilt: "Guilt or heaviness"
        case .inconsistent: "Inconsistency"
        case .distant: "I feel distant"
        }
    }

    var subtitle: String {
        switch self {
        case .busy: "No room left in the day"
        case .guilt: "Hard to come as I am"
        case .inconsistent: "I start, then stop"
        case .distant: "God feels far away"
        }
    }

    var accessibilityID: String {
        switch self {
        case .busy: "onboarding.quiz.distance.busy"
        case .guilt: "onboarding.quiz.distance.guilt"
        case .inconsistent: "onboarding.quiz.distance.incons"
        case .distant: "onboarding.quiz.distance.distant"
        }
    }
}

enum OnboardingDesire: String, CaseIterable, Identifiable {
    case peace, daily, free, know

    var id: String { rawValue }

    var title: String {
        switch self {
        case .peace: "Peace"
        case .daily: "Daily consistency"
        case .free: "Freedom from guilt"
        case .know: "Know Scripture better"
        }
    }

    var planKey: String {
        switch self {
        case .peace: "peace"
        case .daily: "consistency"
        case .free: "freedom"
        case .know: "scripture"
        }
    }

    var planLabel: String {
        switch self {
        case .peace: "Peace"
        case .daily: "Consistency"
        case .free: "Freedom"
        case .know: "Scripture"
        }
    }

    var accessibilityID: String {
        "onboarding.quiz.desire.\(rawValue)"
    }
}

enum OnboardingCopy {
    static let prePaywallScreenCount = 15
    static let welcomeTitle = "Selah"
    static let welcomeSubtitle = "Pause · Reflect · Listen"
    static let welcomeVerse = "Be still, and know that I am God."
    static let welcomeCTA = "Begin"

    static func eventName(for screen: Int) -> String {
        switch screen {
        case 1: "onboarding_01_welcome"
        case 2: "onboarding_02_hook"
        case 3: "onboarding_03_stat"
        case 4: "onboarding_04_quiz_distance"
        case 5: "onboarding_05_quiz_desire"
        case 6: "onboarding_06_quiz_habit"
        case 7: "onboarding_07_mirror"
        case 8: "onboarding_08_commitment"
        case 9: "onboarding_09_privacy"
        case 10: "onboarding_10_demo"
        case 11: "onboarding_11_demo_result"
        case 12: "onboarding_12_building"
        case 13: "onboarding_13_plan"
        case 14: "onboarding_14_widget"
        case 15: "onboarding_15_social"
        case 16: "paywall_view"
        case 17: "onboarding_17_notifications"
        default: "onboarding_\(String(format: "%02d", screen))"
        }
    }

    static func paywallHeadline(distance: OnboardingDistance?) -> String {
        switch distance {
        case .distant, .busy: "Start talking to God every day"
        case .inconsistent: "Read the Bible 5 minutes a day — without quitting"
        case .guilt: "A private space to talk to God"
        case .none: "Your private space with God"
        }
    }

    static func mirrorText(desire: OnboardingDesire, distance: OnboardingDistance) -> String {
        "You want \(desire.title). And \(distance.title.lowercased()) has made it hard to find."
    }
}
