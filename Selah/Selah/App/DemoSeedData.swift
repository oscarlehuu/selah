import Foundation

enum DemoSeedData {
    static let streakDays = 18
    static let longestStreak = 24
    static let planTheme = "Peace"
    static let planWeek = 2
    static let planDaysCompleteThisWeek = 5
    static let prayerMinutes = 96
    static let verseOfDay = "Be still, and know that I am God."
    static let verseReference = "Psalm 46:10 · KJV"
    static let subscriptionLabel = "Selah · Yearly"
    static let notificationTime = "6:30 AM"

    static let journalEntries: [(day: String, month: String, text: String)] = [
        ("23", "Aug", "Released the thing I keep carrying about work. Felt lighter after Psalm 55:22."),
        ("22", "Aug", "Grateful: a quiet morning, coffee, and John 15. Read before the phone today.")
    ]

    static let talkPreviewLines: [String] = [
        "Heart · say anything. Nothing leaves this phone.",
        "I've been carrying a lot this week. I don't know how to slow down.",
        "That honesty matters. What would it look like to bring one small worry to God tonight?"
    ]
}
