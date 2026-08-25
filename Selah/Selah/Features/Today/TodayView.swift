import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showSettings = false
    @State private var votd: VerseOfTheDay?

    var body: some View {
        SelahTabScreen("Today") {
            List {
                Section {
                    if let votd {
                        Text("“\(votd.text)”")
                            .font(SelahFont.verse(.title3))
                        Text(votd.reference)
                            .font(SelahFont.ui(.footnote, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(greeting)
                }

                Section {
                    Button {
                        AnalyticsService.track("cta_5min")
                        env.startFiveMinutePray()
                    } label: {
                        Label("5 minutes with God", systemImage: "hands.sparkles.fill")
                    }
                    .accessibilityIdentifier("today.cta.fiveMinutes")
                }

                Section("Today’s reading") {
                    Button {
                        env.openMainTab(.read)
                    } label: {
                        if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
                            LabeledContent("\(day.book) \(day.chapter)") {
                                Text("\(day.focus) · \(day.minutes) min")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("Open the Bible")
                        }
                    }
                }

                Section("How is your heart?") {
                    ForEach(OnboardingMood.allCases) { mood in
                        Button {
                            AnalyticsService.track("mood_quick", properties: ["mood": mood.rawValue])
                            env.openTalk(mood: mood)
                        } label: {
                            Label(mood.title, systemImage: mood.symbol)
                        }
                    }
                }

                Section("Private space") {
                    Button {
                        env.openMainTab(.talk)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Talk to God")
                                Text("Heart · Reflect · Release · stays on this phone")
                                    .font(SelahFont.ui(.footnote))
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                        }
                    }
                }

                if let note = env.graceNote {
                    Section {
                        Text(note).foregroundStyle(SelahColors.accent)
                    }
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
                    .accessibilityIdentifier("selah.settings.open")
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .onAppear {
                AnalyticsService.track("today_open")
                AnalyticsService.track("streak_view")
                if DemoMode.screenshotSettings {
                    showSettings = true
                }
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

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let hello = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        let days = env.streakModel?.streakDays ?? 0
        return "\(hello) · \(days)-day streak"
    }
}
