import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \JournalEntryModel.createdAt, order: .reverse) private var journalEntries: [JournalEntryModel]
    @State private var selectedEntry: JournalEntryModel?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    streakHero
                    planSection
                    journalSection
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
            .selahCanvas()
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) {
                SelahNavBar("Journey") {
                } trailing: {
                    SelahIconButton(
                        systemImage: "gearshape",
                        label: "Settings",
                        identifier: "journey.settings"
                    ) {
                        showSettings = true
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry)
            }
            .onAppear { AnalyticsService.track("journey_open") }
        }
        .background(SelahColors.background.ignoresSafeArea())
    }

    // MARK: - Streak hero (mock `.streak-hero`)

    private var streakHero: some View {
        VStack(spacing: 4) {
            Text("Days with God")
                .font(SelahFont.ui(.caption, weight: .bold))
                .textCase(.uppercase)
                .kerning(0.8)
                .foregroundStyle(SelahColors.textSoft)
            Text("\(streakDays)")
                .font(SelahFont.display(.largeTitle))
                .fontWeight(.semibold)
                .foregroundStyle(SelahColors.text)
            Text(streakCaption)
                .font(SelahFont.ui(.footnote))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)

            StreakPathView(completed: completedThisWeek, todayIndex: todayWeekdayIndex)
                .frame(height: 190)
                .padding(.top, 6)
                .accessibilityHidden(true)

            graceChip
                .padding(.top, 8)

            statGrid
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
    }

    @ViewBuilder
    private var graceChip: some View {
        if env.streakModel?.graceUsedThisWeek == false {
            Button {
                env.applyGraceDayFromUser()
            } label: {
                SelahChip(text: "Use a grace day", systemImage: "heart", style: .blue)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("journey.grace")
        } else {
            SelahChip(text: "Grace day used · welcome back", systemImage: "checkmark.circle", style: .gold)
        }
    }

    // Mock `.stat-grid` — 3 equal white tiles. "Minutes in prayer" has no
    // backing metric in the model, so only real stats are shown.
    private var statGrid: some View {
        HStack(spacing: 9) {
            StatTile(value: "\(env.streakModel?.longestStreak ?? 0)", label: "Longest streak")
            StatTile(value: "\(chaptersRead)", label: "Chapters read")
        }
    }

    // MARK: - 7-day plan (mock "Your 7-day plan" card)

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SelahSectionHead(title: "Your week")
            VStack(spacing: 0) {
                ForEach(env.currentPlanTheme?.weekDays(week: env.planWeek) ?? []) { day in
                    PlanDayRow(
                        day: day,
                        isDone: day.globalDay < env.planGlobalDay,
                        isToday: day.globalDay == env.planGlobalDay,
                        openAction: { env.openMainTab(.read) }
                    )
                }
            }
            .selahCard(padding: 4)
        }
    }

    // MARK: - Journal

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Journal")
                    .font(SelahFont.display(.headline))
                    .foregroundStyle(SelahColors.text)
                Spacer()
                SelahChip(text: "Encrypted", systemImage: "lock.fill", style: .gold)
            }
            .padding(.top, 26)

            if journalEntries.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 26))
                        .foregroundStyle(SelahColors.textSoft)
                    Text("Come sit a while")
                        .font(SelahFont.display(.title3))
                        .foregroundStyle(SelahColors.text)
                    Text("Anything you save from Talk or Pray will rest here, encrypted, only on this phone.")
                        .font(SelahFont.ui(.footnote))
                        .foregroundStyle(SelahColors.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
            } else {
                ForEach(journalEntries.prefix(12)) { entry in
                    JournalEntryRow(entry: entry) { selectedEntry = entry }
                }
            }
        }
    }

    // MARK: - Data helpers

    private var streakDays: Int { env.streakModel?.streakDays ?? 0 }

    private var chaptersRead: Int { max(0, env.planGlobalDay - 1) }

    private var streakCaption: String {
        if env.streakModel?.graceUsedThisWeek == false {
            return "You’ve shown up \(streakDays) days. A grace day is waiting if you need it."
        }
        return "You’ve shown up \(streakDays) days. Grace day used this week. No shame, keep going."
    }

    /// 0-based index of today within the M–S week row.
    private var todayWeekdayIndex: Int {
        // Calendar weekday: 1 = Sunday … 7 = Saturday. Mock row is M T W T F S S.
        let weekday = Calendar.current.component(.weekday, from: .now)
        return (weekday + 5) % 7
    }

    /// Which day dots are completed this week, derived from last qualifying date + streak.
    private var completedThisWeek: [Bool] {
        let today = todayWeekdayIndex
        var dots = [Bool](repeating: false, count: 7)
        guard streakDays > 0 else { return dots }
        var qualifiedToday = false
        if let last = env.streakModel?.lastQualifyingDate {
            qualifiedToday = Calendar.current.isDateInToday(last)
        }
        let lastDoneIndex = qualifiedToday ? today : today - 1
        guard lastDoneIndex >= 0 else { return dots }
        let count = min(streakDays, lastDoneIndex + 1)
        for i in (lastDoneIndex - count + 1)...lastDoneIndex where i >= 0 {
            dots[i] = true
        }
        return dots
    }
}

// MARK: - Streak path (mock SVG `.path`, viewBox 0 0 300 190)

private struct StreakPathView: View {
    let completed: [Bool]
    let todayIndex: Int

    private let points: [CGPoint] = [
        CGPoint(x: 22, y: 158), CGPoint(x: 62, y: 132), CGPoint(x: 100, y: 106),
        CGPoint(x: 140, y: 120), CGPoint(x: 178, y: 96), CGPoint(x: 228, y: 66),
        CGPoint(x: 278, y: 34)
    ]
    private let labels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 300
            let sy = geo.size.height / 190
            let pts = points.map { CGPoint(x: $0.x * sx, y: $0.y * sy) }
            let lastDone = completed.lastIndex(of: true)

            ZStack {
                curve(through: pts, upTo: pts.count - 1)
                    .stroke(
                        SelahColors.text.opacity(0.1),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 7])
                    )
                if let lastDone, lastDone > 0 {
                    curve(through: pts, upTo: lastDone)
                        .stroke(
                            SelahColors.accent.opacity(0.65),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                }
                ForEach(0..<7, id: \.self) { i in
                    dayDot(index: i, at: pts[i])
                }
            }
        }
    }

    /// Gentle curve through the dot positions (mock's cubic streak path).
    private func curve(through pts: [CGPoint], upTo last: Int) -> Path {
        Path { path in
            path.move(to: pts[0])
            for i in 1...last {
                let prev = pts[i - 1]
                let next = pts[i]
                let midX = (prev.x + next.x) / 2
                path.addCurve(
                    to: next,
                    control1: CGPoint(x: midX, y: prev.y),
                    control2: CGPoint(x: midX, y: next.y)
                )
            }
        }
    }

    @ViewBuilder
    private func dayDot(index i: Int, at p: CGPoint) -> some View {
        let done = completed[i]
        let isToday = i == todayIndex

        ZStack {
            Circle()
                .fill(done ? SelahColors.accent : Color.white)
                .frame(width: done ? 26 : 22, height: done ? 26 : 22)
                .overlay(
                    Circle().stroke(
                        done ? SelahColors.accentDeep : SelahColors.borderStrong,
                        lineWidth: 1.5
                    )
                )
                .overlay {
                    if isToday {
                        Circle()
                            .stroke(SelahColors.accent.opacity(0.5), lineWidth: 2)
                            .frame(width: 34, height: 34)
                    }
                }
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .position(p)
        .overlay(
            Text(labels[i])
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(done ? SelahColors.accentDeep : SelahColors.textSoft)
                .position(x: p.x, y: p.y + 30)
        )
    }
}

// MARK: - Stat tile (mock `.stat-tile`)

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(SelahFont.display(.title2))
                .fontWeight(.semibold)
                .foregroundStyle(SelahColors.text)
            Text(label)
                .font(SelahFont.ui(.caption2))
                .foregroundStyle(SelahColors.textSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background(SelahColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SelahColors.border, lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x2C2825).opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Plan day row (mock `.set-row` inside plan card)

private struct PlanDayRow: View {
    let day: ReadingPlanDay
    let isDone: Bool
    let isToday: Bool
    let openAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isDone ? "checkmark" : "book")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isDone ? SelahColors.accentDeep : SelahColors.textSoft)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(isDone ? SelahColors.accentSoft : SelahColors.backgroundWarm)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text("\(day.book) \(day.chapter)")
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
                Text(day.focus)
                    .font(SelahFont.ui(.caption))
                    .foregroundStyle(SelahColors.textSoft)
            }
            Spacer()
            if isToday {
                Button("Open", action: openAction)
                    .font(SelahFont.ui(.footnote, weight: .semibold))
                    .foregroundStyle(SelahColors.primaryDeep)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
    }
}

// MARK: - Journal entry row (mock `.journal-item` with 42pt date block)

private struct JournalEntryRow: View {
    let entry: JournalEntryModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                VStack(spacing: 0) {
                    Text(entry.createdAt.formatted(.dateTime.day()))
                        .font(SelahFont.display(.title3))
                        .fontWeight(.semibold)
                        .foregroundStyle(SelahColors.text)
                    Text(entry.createdAt.formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .kerning(0.6)
                        .foregroundStyle(SelahColors.textSoft)
                }
                .frame(width: 42)
                Text(entry.previewHint.isEmpty ? "Journal entry" : entry.previewHint)
                    .font(SelahFont.ui(.subheadline))
                    .foregroundStyle(SelahColors.text)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SelahColors.textSoft)
            }
            .selahCard(padding: 13)
        }
        .buttonStyle(.plain)
    }
}
