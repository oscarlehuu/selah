import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \JournalEntryModel.createdAt, order: .reverse) private var journalEntries: [JournalEntryModel]
    @State private var selectedEntry: JournalEntryModel?

    var body: some View {
        SelahTabScreen("Journey") {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Week \(env.planWeek) of \(env.currentPlanTheme?.label ?? "Peace")")
                        .font(SelahFont.newsreader(22, weight: .semibold))
                    weekList
                    Text("Journal")
                        .font(SelahFont.figtree(12, weight: .semibold))
                        .foregroundStyle(SelahColors.textSoft)
                    if journalEntries.isEmpty {
                        Text("Prayer reflections you save will appear here — encrypted on your phone.")
                            .font(SelahFont.figtree(15))
                            .foregroundStyle(SelahColors.textMuted)
                    } else {
                        ForEach(journalEntries.prefix(8)) { entry in
                            Button { selectedEntry = entry } label: {
                                SelahCard {
                                    Text(entry.previewHint)
                                        .font(SelahFont.figtree(15))
                                        .foregroundStyle(SelahColors.text)
                                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(SelahFont.figtree(12))
                                        .foregroundStyle(SelahColors.textMuted)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .selahTabScrollContent()
            .onAppear { AnalyticsService.track("journey_open") }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry)
            }
        }
    }

    private var weekList: some View {
        let days = env.currentPlanTheme?.weekDays(week: env.planWeek) ?? []
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(days) { day in
                HStack {
                    Text("\(day.label) · \(day.book) \(day.chapter)")
                        .font(SelahFont.figtree(15))
                    Spacer()
                    if day.globalDay < env.planGlobalDay {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(SelahColors.primaryDeep)
                    } else if day.globalDay == env.planGlobalDay {
                        Button("Complete") {
                            env.markPlanDayComplete(globalDay: day.globalDay)
                            AnalyticsService.track("plan_day_complete")
                        }
                        .font(SelahFont.figtree(13, weight: .semibold))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
