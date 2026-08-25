import Foundation

enum JourneyCopy {
    static let daysWithGod = "Days with God"
    static let planSection = "Your 7-day plan"
    static let journalSection = "Journal"
    static let emptyJournalTitle = "Come sit a while"
    static let emptyJournalBody = "Anything you save from Talk or Pray will rest here, encrypted, only on this phone."
    static let graceChipAvailable = "Use a grace day"
    static let graceChipUsed = "Grace day used · welcome back"
    static let graceConfirmTitle = "Use a grace day?"
    static let graceConfirmBody = "Your streak stays. Rest is part of the rhythm — one grace day each week."
    static let graceConfirmUse = "Use it"
    static let graceConfirmDefer = "Not yet"
    static let longestStreak = "Longest streak"
    static let minutesInPrayer = "Minutes in prayer"
    static let chaptersRead = "Chapters read"
    static let encrypted = "Encrypted"

    static let statLabels = [longestStreak, minutesInPrayer, chaptersRead]

    static func caption(days: Int, graceAvailable: Bool) -> String {
        if graceAvailable {
            return "You’ve shown up \(days) days. A grace day is waiting if you need it."
        }
        return "You’ve shown up \(days) days. Grace day used this week. No shame, keep going."
    }
}

struct JourneyWeekDay: Equatable, Identifiable {
    let weekday: Int
    let label: String
    let isComplete: Bool
    var id: Int { weekday }
}

struct JourneyStatTile: Equatable, Identifiable {
    let value: String
    let label: String
    var id: String { label }
}

enum JourneyWeekPath {
    static let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    static func days(
        completedDates: [Date],
        today: Date = .now,
        calendar: Calendar = .current
    ) -> [JourneyWeekDay] {
        let weekStart = StreakLogic.startOfWeekSunday(for: today, calendar: calendar)
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
            let complete = completedDates.contains { calendar.isDate($0, inSameDayAs: day) }
            return JourneyWeekDay(weekday: offset + 1, label: weekdayLabels[offset], isComplete: complete)
        }
    }

    static func demoCompletedDates(
        count: Int,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> [Date] {
        let weekStart = StreakLogic.startOfWeekSunday(for: today, calendar: calendar)
        return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
}

struct JourneyPresentation {
    let streakDays: Int
    let streakCaption: String
    let graceAvailable: Bool
    let graceChipTitle: String
    let weekPath: [JourneyWeekDay]
    let stats: [JourneyStatTile]
    let planDays: [ReadingPlanDay]
    let planThemeLabel: String
    let currentGlobalDay: Int

    static func make(
        streakDays: Int,
        longestStreak: Int,
        graceUsedThisWeek: Bool,
        completedDates: [Date],
        prayerMinutes: Int,
        chaptersRead: Int,
        planDays: [ReadingPlanDay],
        planThemeLabel: String,
        currentGlobalDay: Int,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> JourneyPresentation {
        let graceAvailable = !graceUsedThisWeek
        return JourneyPresentation(
            streakDays: streakDays,
            streakCaption: JourneyCopy.caption(days: streakDays, graceAvailable: graceAvailable),
            graceAvailable: graceAvailable,
            graceChipTitle: graceAvailable ? JourneyCopy.graceChipAvailable : JourneyCopy.graceChipUsed,
            weekPath: JourneyWeekPath.days(completedDates: completedDates, today: today, calendar: calendar),
            stats: [
                JourneyStatTile(value: "\(longestStreak)", label: JourneyCopy.longestStreak),
                JourneyStatTile(value: "\(prayerMinutes)", label: JourneyCopy.minutesInPrayer),
                JourneyStatTile(value: "\(chaptersRead)", label: JourneyCopy.chaptersRead)
            ],
            planDays: planDays,
            planThemeLabel: planThemeLabel,
            currentGlobalDay: currentGlobalDay
        )
    }
}
