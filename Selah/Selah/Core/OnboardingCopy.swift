import Foundation

enum OnboardingCopy {
    static let prePaywallScreenCount = OnboardingStep.prePaywall.count
    static let welcomeTitle = "Selah"
    static let welcomeSubtitle = "Pause · Reflect · Listen"
    static let welcomeVerse = "Be still, and know that I am God."
    static let welcomeVerseRef = "Psalm 46:10 · KJV"
    static let welcomeCTA = "Begin"
    static let welcomeDurationHint = "Takes about 2 minutes"
    static let welcomeMeaning = "Selah is a Hebrew word in the Psalms. It means: stop here. Breathe. Listen to God."
    static let hookTitle = "You have time to scroll for hours. Five minutes with God feels hard."
    static let hookBody = "It is not because you don’t love him. It is because nothing in your day makes room for him."
    static let hookCTA = "That’s true for me"
    static let commitmentTitle = "Will you make space for God this week?"
    static let commitmentBody = "Five minutes a day. Not a performance. A place to return to."
    static let privacyTitle = "Your prayers stay on this phone."
    static let privacySubtitle = "Not the cloud. Not us. Not anyone."
    static let socialTitle = "People who felt far away kept coming back"
    static let socialQuotes = [
        "Finally a place that doesn’t shame me. I said things to God I’ve never said out loud.",
        "Five minutes before work. First time I’ve kept a Bible habit past three days."
    ]
    static let notificationTitle = "A gentle reminder each morning?"
    static let notificationBody = "One verse at 6:30 AM. No badges, no nagging, no streak threats."
    static let notificationAllowCTA = "Yes, remind me"
    static let notificationSkipCTA = "Not now"
    static let paywallBullets = [
        "Private by design — Talk, reflect, confess. On-device only.",
        "5 minutes a day — Your plan, offline Bible, gentle streak.",
        "Guided prayer — Lectio Divina and prayers for the mood you’re actually in."
    ]
    static let companionDisclaimer = "Selah is a companion for prayer — not a pastor, priest, or therapist."

    static var prePaywallEventNames: [String] {
        OnboardingStep.prePaywall.map(\.analyticsEvent)
    }

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

    static func paywallHeadline(distance: OnboardingDistance?, desire: OnboardingDesire? = nil) -> String {
        if distance == .guilt || desire == .free {
            return "A private space to talk to God"
        }
        if distance == .inconsistent || desire == .daily {
            return "Read the Bible 5 minutes a day, without quitting"
        }
        if distance == .distant || desire == .peace {
            return "Start talking to God every day"
        }
        return "Your private space with God"
    }

    static func mirrorText(desire: OnboardingDesire, distance: OnboardingDistance) -> String {
        "You want \(desire.mirrorPhrase). And \(distance.mirrorPhrase) has made it hard to find."
    }
}
