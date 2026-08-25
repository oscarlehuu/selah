import XCTest
@testable import Selah

final class JourneyPresentationTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testWeekPathIsSundayToSaturdayPerLockedStreakSpec() {
        XCTAssertEqual(JourneyWeekPath.weekdayLabels, ["S", "M", "T", "W", "T", "F", "S"])
        XCTAssertEqual(JourneyWeekPath.weekdayLabels.count, 7)
    }

    func testWeekPathMarksCompletedDatesOnSunSatWeek() {
        let today = Date(timeIntervalSince1970: 1_777_075_200) // 2026-05-26 Tuesday UTC
        let weekStart = StreakLogic.startOfWeekSunday(for: today, calendar: calendar)
        XCTAssertEqual(calendar.component(.weekday, from: weekStart), 1)

        let sunday = weekStart
        let monday = calendar.date(byAdding: .day, value: 1, to: weekStart)!
        let days = JourneyWeekPath.days(
            completedDates: [sunday, monday],
            today: today,
            calendar: calendar
        )

        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days.map(\.label), JourneyWeekPath.weekdayLabels)
        XCTAssertTrue(days[0].isComplete)
        XCTAssertTrue(days[1].isComplete)
        XCTAssertFalse(days[2].isComplete)
        XCTAssertFalse(days[6].isComplete)
    }

    func testDemoWeekPathFillsFirstFiveDays() {
        let today = Date(timeIntervalSince1970: 1_777_075_200)
        let dates = JourneyWeekPath.demoCompletedDates(
            count: DemoSeedData.planDaysCompleteThisWeek,
            today: today,
            calendar: calendar
        )
        XCTAssertEqual(dates.count, 5)
        let days = JourneyWeekPath.days(completedDates: dates, today: today, calendar: calendar)
        XCTAssertEqual(days.filter(\.isComplete).count, 5)
        XCTAssertTrue(days.prefix(5).allSatisfy(\.isComplete))
        XCTAssertTrue(days.suffix(2).allSatisfy { !$0.isComplete })
    }

    func testPresentationExposesGraceStatsAndSevenDayPlan() {
        let today = Date(timeIntervalSince1970: 1_777_075_200)
        let plan = (1...7).map { index in
            ReadingPlanDay(
                dayIndex: index,
                globalDay: index,
                label: "Day \(index)",
                book: "Psalm",
                chapter: 40 + index,
                focus: "Be still",
                minutes: 5,
                reflectionPrompt: ""
            )
        }
        let presentation = JourneyPresentation.make(
            streakDays: 18,
            longestStreak: 24,
            graceUsedThisWeek: false,
            completedDates: JourneyWeekPath.demoCompletedDates(count: 5, today: today, calendar: calendar),
            prayerMinutes: 96,
            chaptersRead: 12,
            planDays: plan,
            planThemeLabel: "Peace",
            currentGlobalDay: 13,
            today: today,
            calendar: calendar
        )

        XCTAssertEqual(presentation.streakDays, 18)
        XCTAssertEqual(presentation.weekPath.filter(\.isComplete).count, 5)
        XCTAssertTrue(presentation.graceAvailable)
        XCTAssertEqual(presentation.graceChipTitle, JourneyCopy.graceChipAvailable)
        XCTAssertEqual(presentation.stats.map(\.label), JourneyCopy.statLabels)
        XCTAssertEqual(presentation.stats.map(\.value), ["24", "96", "12"])
        XCTAssertEqual(presentation.planDays.count, 7)
        XCTAssertEqual(presentation.planThemeLabel, "Peace")
        XCTAssertTrue(presentation.streakCaption.contains("grace day is waiting"))
    }

    func testUsedGraceChangesChipAndCaption() {
        let presentation = JourneyPresentation.make(
            streakDays: 18,
            longestStreak: 24,
            graceUsedThisWeek: true,
            completedDates: [],
            prayerMinutes: 96,
            chaptersRead: 12,
            planDays: [],
            planThemeLabel: "Peace",
            currentGlobalDay: 1
        )
        XCTAssertFalse(presentation.graceAvailable)
        XCTAssertEqual(presentation.graceChipTitle, JourneyCopy.graceChipUsed)
        XCTAssertTrue(presentation.streakCaption.contains("Grace day used this week"))
    }

    func testJourneyCopyMatchesMockV4Moments() {
        XCTAssertEqual(JourneyCopy.daysWithGod, "Days with God")
        XCTAssertEqual(JourneyCopy.planSection, "Your 7-day plan")
        XCTAssertEqual(JourneyCopy.journalSection, "Journal")
        XCTAssertEqual(JourneyCopy.emptyJournalTitle, "Come sit a while")
        XCTAssertEqual(JourneyCopy.graceConfirmTitle, "Use a grace day?")
        XCTAssertTrue(JourneyCopy.graceConfirmBody.contains("one grace day each week"))
        XCTAssertEqual(JourneyCopy.longestStreak, "Longest streak")
        XCTAssertEqual(JourneyCopy.minutesInPrayer, "Minutes in prayer")
        XCTAssertEqual(JourneyCopy.chaptersRead, "Chapters read")
    }
}
