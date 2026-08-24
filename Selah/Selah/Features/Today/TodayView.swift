import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showSettings = false
    @State private var votd: VerseOfTheDay?
    @State private var selectedMood: String?

    private let moods = ["Peaceful", "Anxious", "Grateful", "Weary"]

    var body: some View {
        SelahTabScreen("Today") {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeroImageView(name: "selah-hero-morning")
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    streakCard
                    if let votd { verseCard(votd) }
                    quickActions
                    planCard
                    widgetCard
                    if let note = env.graceNote {
                        Text(note)
                            .font(SelahFont.figtree(14))
                            .foregroundStyle(SelahColors.accentDeep)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .selahTabScrollContent()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(SelahColors.textMuted)
                    }
                    .accessibilityIdentifier("selah.settings.open")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .onAppear {
                AnalyticsService.track("today_open")
                AnalyticsService.track("streak_view")
            }
            .task {
                if env.isDemoMode {
                    votd = VerseOfTheDay(reference: DemoSeedData.verseReference, text: DemoSeedData.verseOfDay)
                } else {
                    votd = try? env.votdService.verse()
                }
            }
        }
    }

    private var streakCard: some View {
        SelahCard {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(env.streakModel?.streakDays ?? 0)-day streak")
                        .font(SelahFont.newsreader(22, weight: .semibold))
                    Text("Week \(env.planWeek) · \(env.currentPlanTheme?.label ?? "Peace")")
                        .font(SelahFont.figtree(14))
                        .foregroundStyle(SelahColors.textMuted)
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(SelahColors.gold)
            }
        }
    }

    private func verseCard(_ votd: VerseOfTheDay) -> some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Verse of the day")
                    .font(SelahFont.figtree(12, weight: .semibold))
                    .foregroundStyle(SelahColors.textSoft)
                Text(votd.text)
                    .font(SelahFont.verse(20))
                    .foregroundStyle(SelahColors.text)
                Text(votd.reference)
                    .font(SelahFont.figtree(13))
                    .foregroundStyle(SelahColors.textMuted)
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                AnalyticsService.track("cta_5min")
                env.startFiveMinutePray()
            } label: {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("5 minutes with God")
                        .font(SelahFont.figtree(16, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(SelahColors.text)
                .padding(16)
                .background(SelahColors.primarySoft.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moods, id: \.self) { mood in
                        Button {
                            selectedMood = mood
                            AnalyticsService.track("mood_quick", properties: ["mood": mood.lowercased()])
                            env.openMainTab(.talk)
                        } label: {
                            Text(mood)
                                .font(SelahFont.figtree(14, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedMood == mood ? SelahColors.primaryDeep : SelahColors.surface)
                                .foregroundStyle(selectedMood == mood ? Color.white : SelahColors.textMuted)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var planCard: some View {
        let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay)
        return Button { env.openMainTab(.read) } label: {
            SelahCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's reading")
                        .font(SelahFont.figtree(12, weight: .semibold))
                        .foregroundStyle(SelahColors.textSoft)
                    if let day {
                        Text("\(day.book) \(day.chapter)")
                            .font(SelahFont.newsreader(20, weight: .semibold))
                        Text(day.focus)
                            .font(SelahFont.figtree(15))
                            .foregroundStyle(SelahColors.textMuted)
                    }
                    Text("Open in Read")
                        .font(SelahFont.figtree(13, weight: .semibold))
                        .foregroundStyle(SelahColors.primaryDeep)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var widgetCard: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lock Screen verse")
                    .font(SelahFont.figtree(15, weight: .semibold))
                Text("Coming soon")
                    .font(SelahFont.figtree(12, weight: .semibold))
                    .foregroundStyle(SelahColors.accentDeep)
            }
        }
    }
}
