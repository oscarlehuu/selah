import Foundation

struct StreakSnapshot: Equatable {
    var streakDays: Int
    var longestStreak: Int
    var lastQualifyingDate: Date?
    var graceUsedThisWeek: Bool
    var weekStartSunday: Date?
}

enum StreakLogic {
    static func startOfWeekSunday(for date: Date, calendar: Calendar) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromSunday = weekday - 1
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysFromSunday, to: date) ?? date)
    }

    static func resetWeekIfNeeded(state: StreakSnapshot, today: Date, calendar: Calendar) -> StreakSnapshot {
        let weekStart = startOfWeekSunday(for: today, calendar: calendar)
        if let existing = state.weekStartSunday, calendar.isDate(existing, inSameDayAs: weekStart) {
            return state
        }
        var updated = state
        updated.weekStartSunday = weekStart
        updated.graceUsedThisWeek = false
        return updated
    }

    static func processMissedYesterday(
        state: StreakSnapshot,
        today: Date,
        calendar: Calendar
    ) -> (state: StreakSnapshot, appliedGrace: Bool, resetStreak: Bool) {
        var updated = resetWeekIfNeeded(state: state, today: today, calendar: calendar)
        guard let last = updated.lastQualifyingDate else { return (updated, false, false) }
        let todayStart = calendar.startOfDay(for: today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        if calendar.isDate(last, inSameDayAs: yesterday) || calendar.isDate(last, inSameDayAs: todayStart) {
            return (updated, false, false)
        }
        let missedYesterday = last < yesterday
        guard missedYesterday else { return (updated, false, false) }
        if !updated.graceUsedThisWeek {
            updated.graceUsedThisWeek = true
            return (updated, true, false)
        }
        updated.streakDays = 0
        return (updated, false, true)
    }

    static func recordQualifyingActivity(
        state: StreakSnapshot,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> StreakSnapshot {
        var updated = resetWeekIfNeeded(state: state, today: today, calendar: calendar)
        let dayStart = calendar.startOfDay(for: today)
        if let last = updated.lastQualifyingDate, calendar.isDate(last, inSameDayAs: dayStart) {
            return updated
        }
        updated.streakDays += 1
        updated.longestStreak = max(updated.longestStreak, updated.streakDays)
        updated.lastQualifyingDate = dayStart
        if updated.weekStartSunday == nil {
            updated.weekStartSunday = startOfWeekSunday(for: today, calendar: calendar)
        }
        return updated
    }
}
