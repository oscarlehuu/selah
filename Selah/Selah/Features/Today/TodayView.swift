import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showSettings = false
    @State private var votd: VerseOfTheDay?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        hero
                        actions
                    }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .top)
                // Mock `top: calc(var(--sa-top) + 2px)` — overlay sits below the island.
                headerOverlay
            }
            .background(SelahColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
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

    // MARK: - Header overlay (streak chip + gear)

    private var headerOverlay: some View {
        HStack(alignment: .bottom) {
            Button {
                env.openMainTab(.journey)
            } label: {
                SelahChip(text: "\(env.streakModel?.streakDays ?? 0) days", systemImage: "flame.fill", style: .gold)
                    .shadow(color: Color(hex: 0x2C2825).opacity(0.06), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            Spacer()
            SelahIconButton(
                systemImage: "gearshape",
                label: "Settings",
                identifier: "selah.settings.open"
            ) {
                showSettings = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
    }

    // MARK: - Hero

    private var hero: some View {
        OnboardingHero(style: .photoMorning, height: 330) {
            VStack(alignment: .leading, spacing: 0) {
                Text(dateLabel)
                    .font(SelahFont.ui(.caption2, weight: .semibold))
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .foregroundStyle(Color(hex: 0x4A3D28).opacity(0.72))
                Text(greeting)
                    .font(SelahFont.display(.title2))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: 0x4A3D28))
                    .padding(.top, 3)
                verseCard
                    .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
    }

    private var verseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(votd?.text ?? "Be still, and know that I am God.")”")
                .font(SelahFont.verse(.body))
                .foregroundStyle(Color(hex: 0x3B3226))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 2) {
                Text(verseReference)
                    .font(SelahFont.ui(.caption2, weight: .bold))
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .foregroundStyle(Color(hex: 0x4A3D28).opacity(0.68))
                Spacer()
                verseIconButton("bookmark", label: "Save verse") {
                    if let votd {
                        try? env.saveJournalEntry(plaintext: "\(votd.reference) \(votd.text)")
                    }
                }
                verseIconButton("square.and.arrow.up", label: "Share verse") {}
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.62)
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x2C2825).opacity(0.09), radius: 11, y: 6)
    }

    private func verseIconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: 0x4A3D28))
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Below-hero actions

    private var actions: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                AnalyticsService.track("cta_5min")
                env.startFiveMinutePray()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "hands.sparkles.fill")
                    Text("Start today's 5 minutes")
                        .font(SelahFont.ui(.body, weight: .semibold))
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(.white)
                .background(SelahColors.goldGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .shadow(color: Color(hex: 0xB98A28).opacity(0.34), radius: 14, y: 6)
            .accessibilityIdentifier("today.cta.fiveMinutes")

            SelahSectionHead(title: "Today's plan", actionTitle: "Plan") {
                env.openMainTab(.read)
            }
            planRow

            SelahSectionHead(title: "How is your heart?")
            moodGrid

            SelahSectionHead(title: "Private space")
            talkRow

            promoCard
                .padding(.top, 12)

            if let note = env.graceNote {
                SelahChip(text: note, systemImage: "leaf.fill", style: .gold)
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    private var planRow: some View {
        Button {
            env.openMainTab(.read)
        } label: {
            if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
                rowCard(
                    icon: "book.fill",
                    iconStyle: .blue,
                    title: "\(day.book) \(day.chapter)",
                    subtitle: "\(day.focus) · \(day.minutes) min"
                )
            } else {
                rowCard(icon: "book.fill", iconStyle: .blue, title: "Open the Bible", subtitle: "Pick up where you left off")
            }
        }
        .buttonStyle(.plain)
    }

    private var talkRow: some View {
        Button {
            env.openMainTab(.talk)
        } label: {
            rowCard(
                icon: "bubble.left.and.bubble.right.fill",
                iconStyle: .gold,
                title: "Talk to God",
                subtitle: "Heart · Reflect · Release · stays on this phone"
            )
        }
        .buttonStyle(.plain)
    }

    private func rowCard(icon: String, iconStyle: SelahChip.Style, title: String, subtitle: String) -> some View {
        HStack(spacing: 13) {
            SelahIconTile(systemImage: icon, size: 42, radius: 12, style: iconStyle)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
                Text(subtitle)
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(SelahColors.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(SelahColors.textSoft)
        }
        .selahCard()
    }

    private var moodGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(OnboardingMood.allCases) { mood in
                Button {
                    AnalyticsService.track("mood_quick", properties: ["mood": mood.rawValue])
                    env.openTalk(mood: mood)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: mood.symbol)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(SelahColors.accentDeep)
                        Text(mood.title)
                            .font(SelahFont.ui(.caption2, weight: .semibold))
                            .foregroundStyle(SelahColors.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .background(SelahColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SelahColors.border, lineWidth: 1)
                    )
                    .shadow(color: Color(hex: 0x2C2825).opacity(0.06), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var promoCard: some View {
        HStack(spacing: 13) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(SelahColors.accentDeep)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(SelahColors.accent.opacity(0.16))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("Add the Lock Screen widget")
                    .font(SelahFont.ui(.footnote, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
                Text("A verse waiting before the feed gets you.")
                    .font(SelahFont.ui(.caption))
                    .foregroundStyle(SelahColors.textMuted)
            }
            Spacer()
            Text("Coming soon")
                .font(SelahFont.ui(.footnote, weight: .semibold))
                .foregroundStyle(SelahColors.text)
                .padding(.horizontal, 14)
                .frame(minHeight: 36)
                .background(SelahColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(SelahColors.borderStrong, lineWidth: 1)
                )
        }
        .padding(15)
        .background(
            LinearGradient(
                colors: [SelahColors.accentSoft, Color(hex: 0xFDFAF3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SelahColors.accent.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Copy

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        return hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · d MMMM"
        return formatter.string(from: .now)
    }

    private var verseReference: String {
        let ref = votd?.reference ?? "Psalm 46:10"
        return ref.contains("KJV") ? ref : "\(ref) · KJV"
    }
}
