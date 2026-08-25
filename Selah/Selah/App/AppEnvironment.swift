import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppEnvironment {
    let isDemoMode: Bool
    let bibleRepository: BibleRepository
    let planRepository: ReadingPlanRepository
    let votdService: VerseOfTheDayService
    let subscription: SubscriptionService
    let journalCrypto: JournalEncryptionService
    let crisisMatcher: CrisisKeywordMatcher
    let qualifyingTracker: QualifyingForegroundTracker

    var settings: AppSettingsModel?
    var streakModel: StreakStateModel?
    var graceNote: String?
    var selectedMainTab: MainTab = .today
    var prayQuickMode = false
    var pendingTalkMood: OnboardingMood?
    var pendingTalkVerse: String?
    var selectedTalkMode: TalkMode = .heart

    private let modelContext: ModelContext

    init(modelContext: ModelContext, demoMode: Bool = DemoMode.isEnabled) throws {
        let useDemo = demoMode && !DemoMode.uiTestFreshStart
        isDemoMode = useDemo
        self.modelContext = modelContext
        bibleRepository = try BibleRepository()
        planRepository = try ReadingPlanRepository()
        votdService = try VerseOfTheDayService(bible: bibleRepository)
        subscription = SubscriptionService()
        journalCrypto = JournalEncryptionService()
        crisisMatcher = CrisisKeywordMatcher()
        qualifyingTracker = QualifyingForegroundTracker()
        subscription.configure(demoMode: useDemo)
        if DemoMode.screenshotPaywall {
            subscription.isSubscribed = false
        }
        AnalyticsService.configure(demoMode: useDemo)
        qualifyingTracker.onThreshold = { [weak self] in
            Task { @MainActor in self?.recordQualifyingPrayTalkTime() }
        }
        bootstrapModels()
        if DemoMode.screenshotPaywall {
            applyPaywallScreenshotState()
        } else if useDemo {
            applyDemoSeed()
        } else if DemoMode.uiTestFreshStart {
            applyUITestFreshStart()
        } else {
            processStreakOnOpen()
        }
    }

    var isSubscribed: Bool { isDemoMode || subscription.isSubscribed }

    var onboardingComplete: Bool {
        isDemoMode || settings?.onboardingComplete == true
    }

    func shouldShowMainApp() -> Bool {
        AppGate.shouldShowMainApp(isSubscribed: isSubscribed, isDemoMode: isDemoMode)
    }

    func shouldShowPaywall() -> Bool {
        AppGate.shouldShowPaywall(
            isSubscribed: isSubscribed,
            isDemoMode: isDemoMode,
            onboardingComplete: onboardingComplete
        )
    }

    var currentPlanTheme: ReadingPlanTheme? {
        guard let key = settings?.planThemeKey else { return nil }
        return planRepository.theme(for: key)
    }

    var planGlobalDay: Int {
        guard let settings else { return 1 }
        let completed = (try? modelContext.fetch(FetchDescriptor<PlanProgressModel>())) ?? []
        return max(1, completed.filter { $0.themeKey == settings.planThemeKey && $0.completedAt != nil }.count + 1)
    }

    var planWeek: Int { ((planGlobalDay - 1) / 7) + 1 }

    var quizDistance: OnboardingDistance? {
        OnboardingDistance(rawValue: settings?.quizDistance ?? "")
    }

    var quizDesire: OnboardingDesire? {
        OnboardingDesire(rawValue: settings?.quizDesire ?? "")
    }

    func markPlanDayComplete(globalDay: Int) {
        guard let settings else { return }
        let existing = (try? modelContext.fetch(FetchDescriptor<PlanProgressModel>())) ?? []
        if existing.contains(where: { $0.themeKey == settings.planThemeKey && $0.globalDay == globalDay }) { return }
        modelContext.insert(PlanProgressModel(themeKey: settings.planThemeKey, globalDay: globalDay, completedAt: .now))
        try? modelContext.save()
        recordQualifyingActivity()
    }

    func recordQualifyingActivity() {
        applyQualifyingActivity(event: "qualifying_plan_complete")
    }

    func recordQualifyingPrayTalkTime() {
        applyQualifyingActivity(event: "qualifying_pray_talk_time")
    }

    func saveJournalEntry(plaintext: String) throws {
        let encrypted = try journalCrypto.encrypt(plaintext: plaintext)
        modelContext.insert(
            JournalEntryModel(
                encryptedPayload: encrypted.payload,
                iv: encrypted.iv,
                tag: encrypted.tag,
                previewHint: String(plaintext.prefix(20))
            )
        )
        try modelContext.save()
    }

    func decryptJournalEntry(_ entry: JournalEntryModel) throws -> String {
        try journalCrypto.decrypt(payload: entry.encryptedPayload, iv: entry.iv, tag: entry.tag)
    }

    func markNotificationPromptSeen() {
        settings?.sawNotificationPrompt = true
        try? modelContext.save()
    }

    func openMainTab(_ tab: MainTab) { selectedMainTab = tab }

    func openTalk(mood: OnboardingMood) {
        pendingTalkMood = mood
        selectedTalkMode = mood == .empty ? .reflect : .heart
        selectedMainTab = .talk
    }

    func openTalkReflect(reference: String) {
        pendingTalkVerse = reference
        selectedTalkMode = .reflect
        selectedMainTab = .talk
    }

    func persist() { try? modelContext.save() }

    func startFiveMinutePray() {
        prayQuickMode = true
        selectedMainTab = .pray
    }

    func completeOnboarding(distance: OnboardingDistance, desire: OnboardingDesire, habit: OnboardingHabit) {
        guard let settings else { return }
        settings.quizDistance = distance.rawValue
        settings.quizDesire = desire.rawValue
        settings.quizHabit = habit.rawValue
        settings.planThemeKey = desire.planKey
        settings.onboardingComplete = true
        try? modelContext.save()
    }

    func applyGraceDayFromUser() {
        guard let streakModel, !streakModel.graceUsedThisWeek else { return }
        streakModel.graceUsedThisWeek = true
        try? modelContext.save()
        AnalyticsService.track("grace_day_used")
    }

    func incrementPaywallPresentation() {
        guard let settings else { return }
        settings.paywallPresentationCount += 1
        subscription.paywallPresentationCount = settings.paywallPresentationCount
        try? modelContext.save()
    }

    func startTalkSession() -> UUID {
        let session = TalkSessionModel()
        modelContext.insert(session)
        try? modelContext.save()
        return session.id
    }

    func appendTalkMessage(sessionId: UUID, role: String, content: String) {
        modelContext.insert(TalkMessageModel(sessionId: sessionId, role: role, content: content))
        try? modelContext.save()
    }

    func talkMessages(for sessionId: UUID) -> [(role: String, text: String)] {
        let rows = (try? modelContext.fetch(FetchDescriptor<TalkMessageModel>())) ?? []
        return rows.filter { $0.sessionId == sessionId }.sorted { $0.createdAt < $1.createdAt }.map { ($0.role, $0.content) }
    }

    func clearTalkSessionsIfNeeded() {
        guard settings?.autoDeleteTalkSessions == true else { return }
        for message in (try? modelContext.fetch(FetchDescriptor<TalkMessageModel>())) ?? [] { modelContext.delete(message) }
        for session in (try? modelContext.fetch(FetchDescriptor<TalkSessionModel>())) ?? [] { modelContext.delete(session) }
        try? modelContext.save()
    }

    private func applyQualifyingActivity(event: String) {
        guard let streakModel else { return }
        let before = streakModel.snapshot
        let updated = StreakLogic.recordQualifyingActivity(state: before)
        streakModel.apply(updated)
        try? modelContext.save()
        AnalyticsService.track(event)
        if updated.streakDays != before.streakDays { AnalyticsService.track("streak_increment") }
    }

    private func bootstrapModels() {
        let settingsList = (try? modelContext.fetch(FetchDescriptor<AppSettingsModel>())) ?? []
        if let first = settingsList.first {
            settings = first
        } else {
            let model = AppSettingsModel()
            modelContext.insert(model)
            settings = model
        }
        subscription.paywallPresentationCount = settings?.paywallPresentationCount ?? 0
        let streakList = (try? modelContext.fetch(FetchDescriptor<StreakStateModel>())) ?? []
        if let first = streakList.first {
            streakModel = first
        } else {
            let model = StreakStateModel()
            modelContext.insert(model)
            streakModel = model
        }
        try? modelContext.save()
    }

    private func applyDemoSeed() {
        streakModel?.streakDays = DemoSeedData.streakDays
        streakModel?.longestStreak = DemoSeedData.longestStreak
        streakModel?.graceUsedThisWeek = false
        settings?.planThemeKey = DemoSeedData.planTheme.lowercased()
        settings?.onboardingComplete = true
        settings?.sawNotificationPrompt = true
        if let tab = DemoMode.screenshotTab {
            selectedMainTab = tab
        }
        seedDemoPlanProgress()
        seedDemoJournalEntries()
        try? modelContext.save()
    }

    private func applyPaywallScreenshotState() {
        settings?.onboardingComplete = true
        settings?.sawNotificationPrompt = false
        settings?.quizDistance = OnboardingDistance.guilt.rawValue
        settings?.quizDesire = OnboardingDesire.peace.rawValue
        subscription.isSubscribed = false
        try? modelContext.save()
    }

    private func seedDemoPlanProgress() {
        let themeKey = DemoSeedData.planTheme.lowercased()
        let completedDays = (DemoSeedData.planWeek - 1) * 7 + DemoSeedData.planDaysCompleteThisWeek
        let rows = (try? modelContext.fetch(FetchDescriptor<PlanProgressModel>())) ?? []
        for globalDay in 1...completedDays where !rows.contains(where: { $0.themeKey == themeKey && $0.globalDay == globalDay }) {
            modelContext.insert(PlanProgressModel(themeKey: themeKey, globalDay: globalDay, completedAt: .now))
        }
    }

    private func seedDemoJournalEntries() {
        let existing = (try? modelContext.fetch(FetchDescriptor<JournalEntryModel>())) ?? []
        guard existing.isEmpty else { return }
        for item in DemoSeedData.journalEntries {
            try? saveJournalEntry(plaintext: item.text)
        }
    }

    private func applyUITestFreshStart() {
        settings?.onboardingComplete = false
        settings?.sawNotificationPrompt = false
        settings?.paywallPresentationCount = 0
        subscription.paywallPresentationCount = 0
        try? modelContext.save()
    }

    private func processStreakOnOpen() {
        guard let streakModel else { return }
        let result = StreakLogic.processMissedYesterday(state: streakModel.snapshot, today: .now, calendar: .current)
        streakModel.apply(result.state)
        if result.appliedGrace {
            graceNote = "Grace covered yesterday."
            AnalyticsService.track("grace_day_applied")
        } else if result.resetStreak {
            AnalyticsService.track("streak_reset")
        }
        try? modelContext.save()
    }
}
