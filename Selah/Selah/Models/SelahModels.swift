import Foundation
import SwiftData

@Model
final class StreakStateModel {
    var streakDays: Int
    var longestStreak: Int
    var lastQualifyingDate: Date?
    var graceUsedThisWeek: Bool
    var weekStartSunday: Date?

    init(
        streakDays: Int = 0,
        longestStreak: Int = 0,
        lastQualifyingDate: Date? = nil,
        graceUsedThisWeek: Bool = false,
        weekStartSunday: Date? = nil
    ) {
        self.streakDays = streakDays
        self.longestStreak = longestStreak
        self.lastQualifyingDate = lastQualifyingDate
        self.graceUsedThisWeek = graceUsedThisWeek
        self.weekStartSunday = weekStartSunday
    }

    var snapshot: StreakSnapshot {
        StreakSnapshot(
            streakDays: streakDays,
            longestStreak: longestStreak,
            lastQualifyingDate: lastQualifyingDate,
            graceUsedThisWeek: graceUsedThisWeek,
            weekStartSunday: weekStartSunday
        )
    }

    func apply(_ snapshot: StreakSnapshot) {
        streakDays = snapshot.streakDays
        longestStreak = snapshot.longestStreak
        lastQualifyingDate = snapshot.lastQualifyingDate
        graceUsedThisWeek = snapshot.graceUsedThisWeek
        weekStartSunday = snapshot.weekStartSunday
    }
}

@Model
final class PlanProgressModel {
    var themeKey: String
    var globalDay: Int
    var completedAt: Date?

    init(themeKey: String, globalDay: Int, completedAt: Date? = nil) {
        self.themeKey = themeKey
        self.globalDay = globalDay
        self.completedAt = completedAt
    }
}

@Model
final class JournalEntryModel {
    var id: UUID
    var createdAt: Date
    var encryptedPayload: Data
    var iv: Data
    var tag: Data
    var previewHint: String

    init(id: UUID = UUID(), createdAt: Date = .now, encryptedPayload: Data, iv: Data, tag: Data, previewHint: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.encryptedPayload = encryptedPayload
        self.iv = iv
        self.tag = tag
        self.previewHint = previewHint
    }
}

@Model
final class TalkSessionModel {
    var id: UUID
    var startedAt: Date
    var mode: String

    init(id: UUID = UUID(), startedAt: Date = .now, mode: String = "talk") {
        self.id = id
        self.startedAt = startedAt
        self.mode = mode
    }
}

@Model
final class TalkMessageModel {
    var id: UUID
    var sessionId: UUID
    var role: String
    var content: String
    var createdAt: Date

    init(id: UUID = UUID(), sessionId: UUID, role: String, content: String, createdAt: Date = .now) {
        self.id = id
        self.sessionId = sessionId
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}

@Model
final class AppSettingsModel {
    var notificationHour: Int
    var notificationMinute: Int
    var autoDeleteTalkSessions: Bool
    var journalCloudSyncEnabled: Bool
    var requireFaceIDForJournal: Bool
    var onboardingComplete: Bool
    var sawNotificationPrompt: Bool
    var paywallPresentationCount: Int
    var quizDistance: String?
    var quizDesire: String?
    var quizHabit: String?
    var planThemeKey: String

    init(
        notificationHour: Int = 6,
        notificationMinute: Int = 30,
        autoDeleteTalkSessions: Bool = false,
        journalCloudSyncEnabled: Bool = true,
        requireFaceIDForJournal: Bool = true,
        onboardingComplete: Bool = false,
        sawNotificationPrompt: Bool = false,
        paywallPresentationCount: Int = 0,
        quizDistance: String? = nil,
        quizDesire: String? = nil,
        quizHabit: String? = nil,
        planThemeKey: String = "peace"
    ) {
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.autoDeleteTalkSessions = autoDeleteTalkSessions
        self.journalCloudSyncEnabled = journalCloudSyncEnabled
        self.requireFaceIDForJournal = requireFaceIDForJournal
        self.onboardingComplete = onboardingComplete
        self.sawNotificationPrompt = sawNotificationPrompt
        self.paywallPresentationCount = paywallPresentationCount
        self.quizDistance = quizDistance
        self.quizDesire = quizDesire
        self.quizHabit = quizHabit
        self.planThemeKey = planThemeKey
    }
}
