import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \JournalEntryModel.createdAt, order: .reverse) private var journalEntries: [JournalEntryModel]
    @State private var selectedEntry: JournalEntryModel?
    @State private var showSettings = false

    var body: some View {
        SelahTabScreen("Journey") {
            List {
                Section("Days with God") {
                    Text("\(env.streakModel?.streakDays ?? 0)")
                        .font(SelahFont.display(.largeTitle))
                    Text(streakCaption)
                        .foregroundStyle(.secondary)
                    if env.streakModel?.graceUsedThisWeek == false {
                        Button("Use a grace day") {
                            env.applyGraceDayFromUser()
                        }
                    } else {
                        Label("Grace day used · welcome back", systemImage: "checkmark.circle")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("This week") {
                    LabeledContent("Longest streak", value: "\(env.streakModel?.longestStreak ?? 0)")
                    LabeledContent("Theme", value: env.currentPlanTheme?.label ?? "Peace")
                    LabeledContent("Week", value: "\(env.planWeek)")
                }
                Section {
                    ForEach(env.currentPlanTheme?.weekDays(week: env.planWeek) ?? []) { day in
                        HStack {
                            Image(systemName: day.globalDay < env.planGlobalDay ? "checkmark.circle.fill" : "book")
                                .foregroundStyle(day.globalDay < env.planGlobalDay ? SelahColors.accent : .secondary)
                            VStack(alignment: .leading) {
                                Text("\(day.book) \(day.chapter)")
                                Text(day.focus)
                                    .font(SelahFont.ui(.footnote))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if day.globalDay == env.planGlobalDay {
                                Button("Open") { env.openMainTab(.read) }
                            }
                        }
                    }
                } header: {
                    Text("Your 7-day plan")
                }

                Section {
                    if journalEntries.isEmpty {
                        Text("Come sit a while")
                            .font(SelahFont.display(.title3))
                        Text("Anything you save from Talk or Pray will rest here, encrypted, only on this phone.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(journalEntries.prefix(12)) { entry in
                            Button {
                                selectedEntry = entry
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.previewHint.isEmpty ? "Journal entry" : entry.previewHint)
                                        .foregroundStyle(.primary)
                                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(SelahFont.ui(.caption))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Journal")
                } footer: {
                    Label("Encrypted on this iPhone", systemImage: "lock.fill")
                }
            }
            .listStyle(.insetGrouped)
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
            .onAppear { AnalyticsService.track("journey_open") }
        }
    }

    private var streakCaption: String {
        let days = env.streakModel?.streakDays ?? 0
        if env.streakModel?.graceUsedThisWeek == false {
            return "You’ve shown up \(days) days. A grace day is waiting if you need it."
        }
        return "You’ve shown up \(days) days. Grace day used this week. No shame, keep going."
    }
}
