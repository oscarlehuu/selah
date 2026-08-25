import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome, hook, stat, quizDistance, quizDesire, quizHabit
    case mirror, commitment, privacy, demoMood, demoResult, building
    case planReveal, social, widget

    var id: Int { rawValue }

    static let prePaywall: [OnboardingStep] = allCases.filter { $0 != .widget }

    var allowsSkipToPaywall: Bool { Self.prePaywall.contains(self) }

    var hidesStandardOnboardingChrome: Bool { self == .welcome }

    var navigationTitle: String {
        switch self {
        case .welcome: "Welcome"
        case .hook: "A quiet gap"
        case .stat: "The gap"
        case .quizDistance: "Question 1 of 3"
        case .quizDesire: "Question 2 of 3"
        case .quizHabit: "Question 3 of 3"
        case .mirror: "For you"
        case .commitment: "This week"
        case .privacy: "Privacy"
        case .demoMood: "Live demo"
        case .demoResult: "A prayer"
        case .building: "Your plan"
        case .planReveal: "Your week"
        case .social: "Others"
        case .widget: "Lock Screen"
        }
    }

    var primaryCTA: String {
        switch self {
        case .welcome: OnboardingCopy.welcomeCTA
        case .hook: OnboardingCopy.hookCTA
        case .commitment: "Yes, I’m ready"
        case .privacy: "I understand"
        case .demoMood: "Pray with me"
        case .demoResult: "This is what I needed"
        case .social: "Continue"
        default: "Continue"
        }
    }

    var analyticsEvent: String {
        switch self {
        case .welcome: "onboarding_01_welcome"
        case .hook: "onboarding_02_hook"
        case .stat: "onboarding_03_stat"
        case .quizDistance: "onboarding_04_quiz_distance"
        case .quizDesire: "onboarding_05_quiz_desire"
        case .quizHabit: "onboarding_06_quiz_habit"
        case .mirror: "onboarding_07_mirror"
        case .commitment: "onboarding_08_commitment"
        case .privacy: "onboarding_09_privacy"
        case .demoMood: "onboarding_10_demo"
        case .demoResult: "onboarding_11_demo_result"
        case .building: "onboarding_12_building"
        case .planReveal: "onboarding_13_plan"
        case .widget: "onboarding_14_widget"
        case .social: "onboarding_15_social"
        }
    }

    var footVerse: (text: String, ref: String)? {
        switch self {
        case .stat: ("Draw nigh to God, and he will draw nigh to you.", "James 4:8")
        case .quizDistance: ("Come unto me, and I will give you rest.", "Matthew 11:28")
        case .quizDesire: ("He shall give thee the desires of thine heart.", "Psalm 37:4")
        case .quizHabit: ("His mercies are new every morning.", "Lamentations 3:23")
        case .mirror: ("The Lord is nigh unto them that are of a broken heart.", "Psalm 34:18")
        case .commitment: ("My presence shall go with thee, and I will give thee rest.", "Exodus 33:14")
        case .demoResult: ("Peace I leave with you, my peace I give unto you.", "John 14:27")
        default: nil
        }
    }

    func canAdvance(
        distance: OnboardingDistance?,
        desire: OnboardingDesire?,
        habit: OnboardingHabit?,
        mood: OnboardingMood?
    ) -> Bool {
        switch self {
        case .quizDistance: distance != nil
        case .quizDesire: desire != nil
        case .quizHabit: habit != nil
        case .demoMood: mood != nil
        default: true
        }
    }
}
