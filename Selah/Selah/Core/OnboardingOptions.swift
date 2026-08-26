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

    var mirrorPhrase: String {
        switch self {
        case .busy: "a full life"
        case .guilt: "a heavy heart"
        case .inconsistent: "stop–start weeks"
        case .distant: "a quiet distance"
        }
    }

    var symbol: String {
        switch self {
        case .busy: "clock"
        case .guilt: "cloud.rain"
        case .inconsistent: "arrow.triangle.2.circlepath"
        case .distant: "icloud.slash"
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
        case .know: "Know Scripture"
        }
    }

    var mirrorPhrase: String {
        switch self {
        case .peace: "peace"
        case .daily: "daily consistency"
        case .free: "freedom from guilt"
        case .know: "to know Scripture"
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

    var symbol: String {
        switch self {
        case .peace: "wind"
        case .daily: "calendar"
        case .free: "heart"
        case .know: "book"
        }
    }

    var accessibilityID: String { "onboarding.quiz.desire.\(rawValue)" }
}

enum OnboardingHabit: String, CaseIterable, Identifiable {
    case never, sometimes, often, daily

    var id: String { rawValue }

    var title: String {
        switch self {
        case .never: "Never"
        case .sometimes: "Sometimes"
        case .often: "Often"
        case .daily: "Daily"
        }
    }

    var subtitle: String {
        switch self {
        case .never: "I want to start"
        case .sometimes: "A few times a month"
        case .often: "Most weeks"
        case .daily: "I want to keep it"
        }
    }

    /// Mock v4 quiz 06 icons — sparkle / calendar / bookmark / flame.
    var symbol: String {
        switch self {
        case .never: "sparkles"
        case .sometimes: "calendar"
        case .often: "bookmark"
        case .daily: "flame"
        }
    }
}

enum OnboardingMood: String, CaseIterable, Identifiable {
    case heavy, anxious, grateful, empty

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heavy: "Heavy"
        case .anxious: "Anxious"
        case .grateful: "Grateful"
        case .empty: "Empty"
        }
    }

    var symbol: String {
        switch self {
        case .heavy: "cloud.heavyrain"
        case .anxious: "wind"
        case .grateful: "sun.max"
        case .empty: "circle.dotted"
        }
    }

    /// KJV line shown on the demo-result screen (mock v4). Not an FM fallback.
    var scripture: (text: String, reference: String) {
        switch self {
        case .heavy: ("Cast your burden on the Lord, and he shall sustain you.", "Psalm 55:22")
        case .anxious: ("Be careful for nothing; but in every thing by prayer let your requests be made known unto God.", "Philippians 4:6")
        case .grateful: ("O give thanks unto the Lord; for he is good.", "Psalm 107:1")
        case .empty: ("He restoreth my soul.", "Psalm 23:3")
        }
    }
}
