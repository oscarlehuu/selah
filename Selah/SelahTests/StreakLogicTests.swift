import XCTest
@testable import Selah

final class StreakLogicTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testIncrementOnNewDay() {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date(timeIntervalSince1970: 1_800_000_000))!
        let state = StreakSnapshot(
            streakDays: 2,
            longestStreak: 2,
            lastQualifyingDate: yesterday,
            graceUsedThisWeek: false,
            weekStartSunday: nil
        )
        let updated = StreakLogic.recordQualifyingActivity(state: state, today: Date(timeIntervalSince1970: 1_800_000_000), calendar: calendar)
        XCTAssertEqual(updated.streakDays, 3)
        XCTAssertEqual(updated.longestStreak, 3)
    }

    func testSameDayDoesNotDoubleCount() {
        let today = Date(timeIntervalSince1970: 1_800_000_000)
        let state = StreakSnapshot(
            streakDays: 4,
            longestStreak: 4,
            lastQualifyingDate: today,
            graceUsedThisWeek: false,
            weekStartSunday: nil
        )
        let updated = StreakLogic.recordQualifyingActivity(state: state, today: today, calendar: calendar)
        XCTAssertEqual(updated.streakDays, 4)
    }

    func testGraceAutoApplyOnSingleMiss() {
        let today = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_800_086_400))
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let state = StreakSnapshot(
            streakDays: 5,
            longestStreak: 5,
            lastQualifyingDate: twoDaysAgo,
            graceUsedThisWeek: false,
            weekStartSunday: StreakLogic.startOfWeekSunday(for: today, calendar: calendar)
        )
        let result = StreakLogic.processMissedYesterday(state: state, today: today, calendar: calendar)
        XCTAssertTrue(result.appliedGrace)
        XCTAssertFalse(result.resetStreak)
        XCTAssertEqual(result.state.streakDays, 5)
        XCTAssertTrue(result.state.graceUsedThisWeek)
    }

    func testSecondMissInWeekResetsStreak() {
        let today = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_800_172_800))
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        let state = StreakSnapshot(
            streakDays: 8,
            longestStreak: 8,
            lastQualifyingDate: threeDaysAgo,
            graceUsedThisWeek: true,
            weekStartSunday: StreakLogic.startOfWeekSunday(for: today, calendar: calendar)
        )
        let result = StreakLogic.processMissedYesterday(state: state, today: today, calendar: calendar)
        XCTAssertFalse(result.appliedGrace)
        XCTAssertTrue(result.resetStreak)
        XCTAssertEqual(result.state.streakDays, 0)
    }

    func testNoLastActivityDoesNotReset() {
        let today = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_800_000_000))
        let state = StreakSnapshot(streakDays: 0, longestStreak: 0, lastQualifyingDate: nil, graceUsedThisWeek: false, weekStartSunday: nil)
        let result = StreakLogic.processMissedYesterday(state: state, today: today, calendar: calendar)
        XCTAssertFalse(result.appliedGrace)
        XCTAssertFalse(result.resetStreak)
        XCTAssertEqual(result.state.streakDays, 0)
    }
}
