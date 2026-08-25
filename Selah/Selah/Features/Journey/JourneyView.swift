import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \JournalEntryModel.createdAt, order: .reverse) private var journalEntries: [JournalEntryModel]
    @Query private var planProgress: [PlanProgressModel]
    @State private var selectedEntry: JournalEntryModel?
    @State private var showSettings = false
    @State private var confirmGrace = false

    var body: some View {
        let moment = presentation
        SelahTabScreen("Journey") {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    weekHero(moment)
                    planCard(moment)
                    JourneyJournalSection(entries: Array(journalEntries.prefix(12))) { entry in
                        selectedEntry = entry
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry)
            }
            .confirmationDialog(JourneyCopy.graceConfirmTitle, isPresented: $confirmGrace, titleVisibility: .visible) {
                Button(JourneyCopy.graceConfirmUse) { env.applyGraceDayFromUser() }
                Button(JourneyCopy.graceConfirmDefer, role: .cancel) {}
            } message: {
                Text(JourneyCopy.graceConfirmBody)
            }
            .onAppear { AnalyticsService.track("journey_open") }
        }
    }

    private func weekHero(_ moment: JourneyPresentation) -> some View {
        VStack(spacing: 12) {
            Text(JourneyCopy.daysWithGod)
                .font(SelahFont.ui(.caption, weight: .semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(SelahColors.textSoft)
            Text("\(moment.streakDays)")
                .font(SelahFont.display(.largeTitle))
                .foregroundStyle(SelahColors.text)
            Text(moment.streakCaption)
                .font(SelahFont.ui(.subheadline))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
            JourneyWeekPathView(days: moment.weekPath)
            graceChip(moment)
            JourneyStatsRow(tiles: moment.stats)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func graceChip(_ moment: JourneyPresentation) -> some View {
        if moment.graceAvailable {
            Button {
                confirmGrace = true
            } label: {
                Label(moment.graceChipTitle, systemImage: "heart.fill")
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SelahColors.primarySoft)
                    .foregroundStyle(SelahColors.primaryDeep)
                    .clipShape(Capsule())
            }
            .accessibilityIdentifier("journey.grace")
        } else {
            Label(moment.graceChipTitle, systemImage: "checkmark.circle.fill")
                .font(SelahFont.ui(.subheadline, weight: .semibold))
                .foregroundStyle(SelahColors.textMuted)
                .accessibilityIdentifier("journey.grace")
        }
    }

    private func planCard(_ moment: JourneyPresentation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(JourneyCopy.planSection)
                    .font(SelahFont.display(.title3))
                Spacer()
                Text(moment.planThemeLabel)
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(SelahColors.accentSoft)
                    .foregroundStyle(SelahColors.accentDeep)
                    .clipShape(Capsule())
            }
            VStack(spacing: 0) {
                ForEach(moment.planDays) { day in
                    planRow(day, currentGlobalDay: moment.currentGlobalDay)
                    if day.id != moment.planDays.last?.id {
                        Divider().opacity(0.5)
                    }
                }
            }
            .background(SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SelahColors.text.opacity(0.08), lineWidth: 1)
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("journey.plan")
    }

    private func planRow(_ day: ReadingPlanDay, currentGlobalDay: Int) -> some View {
        let done = day.globalDay < currentGlobalDay
        return HStack(spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "book")
                .foregroundStyle(done ? SelahColors.accentDeep : SelahColors.textSoft)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(day.book) \(day.chapter)")
                    .font(SelahFont.ui(.body, weight: .semibold))
                Text(day.focus)
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(SelahColors.textMuted)
            }
            Spacer()
            if day.globalDay == currentGlobalDay {
                Button("Open") { env.openMainTab(.read) }
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var presentation: JourneyPresentation {
        let themeKey = env.settings?.planThemeKey ?? "peace"
        let rows = planProgress.filter { $0.themeKey == themeKey }
        let dates: [Date]
        let minutes: Int
        if env.isDemoMode {
            dates = JourneyWeekPath.demoCompletedDates(count: DemoSeedData.planDaysCompleteThisWeek)
            minutes = DemoSeedData.prayerMinutes
        } else {
            dates = rows.compactMap(\.completedAt)
            let completed = Set(rows.map(\.globalDay))
            minutes = (env.currentPlanTheme?.days ?? []).filter { completed.contains($0.globalDay) }.reduce(0) { $0 + $1.minutes }
        }
        return JourneyPresentation.make(
            streakDays: env.streakModel?.streakDays ?? 0,
            longestStreak: env.streakModel?.longestStreak ?? 0,
            graceUsedThisWeek: env.streakModel?.graceUsedThisWeek ?? false,
            completedDates: dates,
            prayerMinutes: minutes,
            chaptersRead: rows.count,
            planDays: env.currentPlanTheme?.weekDays(week: env.planWeek) ?? [],
            planThemeLabel: env.currentPlanTheme?.label ?? "Peace",
            currentGlobalDay: env.planGlobalDay
        )
    }
}
