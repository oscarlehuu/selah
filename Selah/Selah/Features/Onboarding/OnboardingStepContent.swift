import SwiftUI

struct OnboardingStepContent: View {
    let step: OnboardingStep
    @Binding var distance: OnboardingDistance?
    @Binding var desire: OnboardingDesire?
    @Binding var habit: OnboardingHabit?
    @Binding var mood: OnboardingMood?
    let demoResult: String
    let isGenerating: Bool
    let buildProgress: Double

    var body: some View {
        switch step {
        case .welcome: welcome
        case .hook: hook
        case .stat: stat
        case .quizDistance: distanceQuiz
        case .quizDesire: desireQuiz
        case .quizHabit: habitQuiz
        case .mirror: mirror
        case .commitment: commitment
        case .privacy: privacy
        case .demoMood: moodPicker
        case .demoResult: demo
        case .building: building
        case .planReveal: PlanRevealView(desire: desire)
        case .social: social
        case .widget: widget
        }
    }

    // MARK: — Screen 01 · Welcome (photo hero edge-to-edge from the very top)

    private var welcome: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    OnboardingHero(style: .photoWindow, fillsAvailable: true) {
                        VStack(spacing: 14) {
                            Spacer()
                            HeroMedallion()
                            Text(OnboardingCopy.welcomeTitle)
                                .font(SelahFont.display(fixedSize: 48))
                                .foregroundStyle(Color(hex: 0x4A3D28))
                            Text(OnboardingCopy.welcomeSubtitle)
                                .font(SelahFont.ui(.caption, weight: .semibold))
                                .kerning(1.6)
                                .textCase(.uppercase)
                                .foregroundStyle(Color(hex: 0x4A3D28).opacity(0.72))
                            Spacer()
                        }
                    }
                    HeroVerse(text: OnboardingCopy.welcomeVerse, ref: OnboardingCopy.welcomeVerseRef)
                }
                .frame(height: proxy.size.height - bottomSectionHeight)
                Spacer(minLength: 0)
                Text(highlightedMeaning)
                    .font(SelahFont.ui(.subheadline))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SelahColors.textMuted)
                    .padding(.horizontal, 26)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    /// Meaning line hugs the footer (just above Begin); hero takes the rest.
    private var bottomSectionHeight: CGFloat { 64 }

    /// "…It means: **stop here. Breathe. Listen to God.**" — bold close like mock v4.
    private var highlightedMeaning: AttributedString {
        var attributed = AttributedString(OnboardingCopy.welcomeMeaning)
        if let range = attributed.range(of: "stop here. Breathe. Listen to God.") {
            attributed[range].foregroundColor = SelahColors.text
            attributed[range].font = SelahFont.ui(.subheadline, weight: .semibold)
        }
        return attributed
    }

    // MARK: — Screen 02 · Hook (sky hero starts at very top, verse inside it)

    private var hook: some View {
        VStack(spacing: 0) {
            OnboardingHero(style: .sky, height: 320) {
                VStack(spacing: 7) {
                    Text("6h 41m of screen time yesterday")
                        .font(SelahFont.verse(.callout))
                        .foregroundStyle(Color(hex: 0x4A3D28))
                        .multilineTextAlignment(.center)
                    Text("Your phone already knows")
                        .font(SelahFont.ui(.caption2, weight: .semibold))
                        .textCase(.uppercase)
                        .kerning(0.8)
                        .foregroundStyle(Color(hex: 0x4A3D28).opacity(0.72))
                }
                .padding(.bottom, 26)
            }
            .ignoresSafeArea(edges: .top)
            // Mock `.ob-body { justify-content:center }` — copy centered between
            // the hero and the footer, headline at display size (wraps like mock).
            Spacer(minLength: 12)
            VStack(alignment: .leading, spacing: 13) {
                Text(OnboardingCopy.hookTitle)
                    .font(SelahFont.display(fixedSize: 30))
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(SelahColors.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text(OnboardingCopy.hookBody)
                    .font(SelahFont.ui(.body))
                    .lineSpacing(4)
                    .foregroundStyle(SelahColors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 26)
            Spacer(minLength: 26)
        }
    }

    // MARK: — Screen 03 · Stat (centered; bars live inside white stat cards)

    private var stat: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("The gap")
                .font(SelahFont.ui(.caption, weight: .semibold))
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(SelahColors.textSoft)
            Text("1 in 5")
                .font(SelahFont.display(fixedSize: 60))
                .foregroundStyle(SelahColors.primaryDeep)
            Text("Most Christians want to read the Bible daily. Few build the habit.")
                .font(SelahFont.display(.headline))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .padding(.horizontal, 34)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 12) {
                StatBarCard(label: "Want to read daily", target: 0.86, tint: SelahColors.primaryDeep)
                StatBarCard(label: "Actually do", target: 0.19, tint: SelahColors.accentDeep)
            }
            .padding(.horizontal, 26)
            // Disclaimer sits beneath the stat cards (mock v4 order), just above the foot verse.
            Text("Illustrative figures for this prototype. Replace with a cited source before ship.")
                .font(SelahFont.ui(.caption2))
                .foregroundStyle(SelahColors.textSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.bottom, 4)
    }

    // MARK: — Screens 04–06 · Quizzes

    private var distanceQuiz: some View {
        quizScreen(
            questionLabel: "Question 1 of 3",
            title: "What keeps you furthest from God right now?",
            subtitle: nil
        ) {
            ForEach(OnboardingDistance.allCases) { option in
                quizCard(option.title, option.subtitle, option.symbol, selected: distance == option) {
                    distance = option
                }
                .accessibilityIdentifier(option.accessibilityID)
            }
        }
    }

    private var desireQuiz: some View {
        quizScreen(
            questionLabel: "Question 2 of 3",
            title: "What do you want most?",
            subtitle: nil,
            columns: 2
        ) {
            ForEach(OnboardingDesire.allCases) { option in
                quizCard(option.title, nil, option.symbol, selected: desire == option, action: {
                    desire = option
                }, compact: true)
                .accessibilityIdentifier(option.accessibilityID)
            }
        }
    }

    private var habitQuiz: some View {
        quizScreen(
            questionLabel: "Question 3 of 3",
            title: "How often do you read the Bible now?",
            subtitle: "Be honest. This only shapes your plan. Nobody sees it."
        ) {
            ForEach(OnboardingHabit.allCases) { option in
                quizCard(option.title, option.subtitle, option.symbol, selected: habit == option) {
                    habit = option
                }
            }
        }
    }

    /// Mock v4 quiz layout — "Question N of 3" label + centered question over cards.
    private func quizScreen(
        questionLabel: String,
        title: String,
        subtitle: String?,
        columns: Int = 1,
        @ViewBuilder cards: () -> some View
    ) -> some View {
        // Mock `.ob-body { justify-content:center }` — the whole question block
        // floats centered between the top bar and the footer (no dead bottom gap).
        VStack(spacing: 14) {
            Spacer(minLength: 64)
            Text(questionLabel)
                .font(SelahFont.ui(.caption, weight: .semibold))
                .kerning(1.2)
                .foregroundStyle(SelahColors.textSoft)
            Text(title)
                .font(SelahFont.display(fixedSize: 26))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 22)
            if let subtitle {
                Text(subtitle)
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(SelahColors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns),
                spacing: 10
            ) {
                cards()
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            Spacer(minLength: 12)
        }
    }

    // MARK: — Screen 07 · Mirror (white quote card, left-aligned italic)

    private var mirror: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "quote.opening")
                .font(.system(size: 26))
                .foregroundStyle(SelahColors.accentDeep)
                .frame(width: 64, height: 64)
                .background(Circle().fill(SelahColors.accentSoft))
                .overlay(Circle().stroke(Color(hex: 0xC49A3C).opacity(0.08), lineWidth: 10))
                .padding(.bottom, 6)
            if let desire, let distance {
                VStack(alignment: .leading, spacing: 14) {
                    Text(mirrorRichText(desire: desire, distance: distance))
                        .font(SelahFont.verse(.title3))
                        .lineSpacing(3)
                    Text("That honesty is already a prayer. Most people never say it out loud.")
                        .font(SelahFont.ui(.body))
                        .lineSpacing(3)
                        .foregroundStyle(SelahColors.textMuted)
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(SelahColors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color(hex: 0xE8E2D8), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
                .padding(.horizontal, 26)
            }
            Spacer()
        }
    }

    /// Mirror sentence with the bold deep-blue emphasis from mock v4 `.mirror-card p b`.
    private func mirrorRichText(desire: OnboardingDesire, distance: OnboardingDistance) -> AttributedString {
        var attributed = AttributedString(OnboardingCopy.mirrorText(desire: desire, distance: distance))
        for phrase in [desire.mirrorPhrase, distance.mirrorPhrase] {
            if let range = attributed.range(of: phrase) {
                attributed[range].foregroundColor = SelahColors.primaryDeep
            }
        }
        return attributed
    }

    // MARK: — Screen 08 · Commitment

    private var commitment: some View {
        VStack(spacing: 11) {
            // Mock v4 heroSky('height:214px') above the centered commitment copy.
            OnboardingHero(style: .sky, height: 214) { EmptyView() }
                .ignoresSafeArea(edges: .top)
            Spacer()
            Text(OnboardingCopy.commitmentTitle)
                .font(SelahFont.display(.title))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 26)
            Text(OnboardingCopy.commitmentBody)
                .font(SelahFont.ui(.body))
                .lineSpacing(3)
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    // MARK: — Screen 09 · Privacy (gradient lock card + bullet list)

    private var privacy: some View {
            // Centered between top bar and footer (mock `.ob-body`).
            VStack(spacing: 0) {
                Spacer(minLength: 64)
                VStack(spacing: 14) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(SelahColors.primaryDeep)
                        .frame(width: 66, height: 66)
                        .background(Circle().fill(SelahColors.surface))
                        .shadow(color: SelahColors.primary.opacity(0.12), radius: 8)
                    Text(OnboardingCopy.privacyTitle)
                        .font(SelahFont.display(.title3))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SelahColors.text)
                    Text(OnboardingCopy.privacySubtitle)
                        .font(SelahFont.ui(.subheadline))
                        .foregroundStyle(SelahColors.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xEDF3FE), Color(hex: 0xF7F1E7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(SelahColors.primary.opacity(0.18), lineWidth: 1)
                )
                .padding(.horizontal, 22)

                VStack(alignment: .leading, spacing: 12) {
                    privacyRow("icloud.slash", bold: "On-device Apple Intelligence.", rest: " Your conversation text is never sent to a cloud AI service.")
                    privacyRow("lock.shield", bold: "Journal is encrypted", rest: " in the iOS keychain, locked with Face ID.")
                    privacyRow("trash", bold: "Auto-delete", rest: " a session the moment you close it, if you prefer.")
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                Spacer(minLength: 40)
            }
    }

    private func privacyRow(_ symbol: String, bold: String, rest: String) -> some View {
        var attributed = AttributedString(bold)
        attributed.font = SelahFont.ui(.subheadline, weight: .semibold)
        attributed.foregroundColor = SelahColors.text
        var tail = AttributedString(rest)
        tail.font = SelahFont.ui(.subheadline)
        tail.foregroundColor = SelahColors.textMuted
        return HStack(alignment: .top, spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(SelahColors.primaryDeep)
                .frame(width: 22)
            Text(attributed + tail)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: — Screen 10 · Demo mood picker (2-col grid, icon above label)

    private var moodPicker: some View {
            // Centered between top bar and footer (mock `.ob-body center`).
            VStack(spacing: 14) {
                Spacer(minLength: 64)
                // Mock v4 `.priv-banner` — "Only on this device" capsule above the title.
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Only on this device")
                        .font(SelahFont.ui(.caption, weight: .semibold))
                }
                .foregroundStyle(SelahColors.primaryDeep)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Capsule().fill(SelahColors.primarySoft))
                .overlay(Capsule().stroke(SelahColors.primary.opacity(0.22), lineWidth: 1))
                Text("How is your heart right now?")
                    .font(SelahFont.display(.title2))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SelahColors.text)
                    .padding(.horizontal, 22)
                Text("Pick one. Selah will pray with you, not at you.")
                    .font(SelahFont.ui(.subheadline))
                    .foregroundStyle(SelahColors.textMuted)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(OnboardingMood.allCases) { option in
                        moodCard(option)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                if !CompanionTextService.isOnDeviceCompanionAvailable {
                    // Quiet muted footnote — availability note, not a warning.
                    Text(CompanionTextService.unavailableMessage)
                        .font(SelahFont.ui(.footnote))
                        .foregroundStyle(SelahColors.textSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 4)
                }
                Spacer(minLength: 16)
            }
    }

    /// Mock v4 `.mood-card` — icon chip on top, label beneath, gold when selected.
    private func moodCard(_ option: OnboardingMood) -> some View {
        let selected = mood == option
        return Button {
            mood = option
        } label: {
            VStack(spacing: 8) {
                Image(systemName: option.symbol)
                    .font(.system(size: 17))
                    .foregroundStyle(selected ? Color.white : SelahColors.accentDeep)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 10).fill(selected ? SelahColors.accent : SelahColors.accentSoft))
                Text(option.title)
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SelahColors.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? SelahColors.accent : Color(hex: 0xE8E2D8), lineWidth: selected ? 1.5 : 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: — Screen 11 · Demo result (label + two white cards)

    private var demo: some View {
        let scripture = (mood ?? .heavy).scripture
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Spacer(minLength: 36)
                Text("Feeling \(mood?.title.lowercased() ?? "heavy") · generated on your iPhone")
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .foregroundStyle(SelahColors.textSoft)
                    .frame(maxWidth: .infinity)
                demoCard(label: "Scripture for you") {
                    Text("“\(scripture.text)”")
                        .font(SelahFont.verse(.callout))
                        .lineSpacing(3)
                    Text(scripture.reference.uppercased())
                        .font(SelahFont.ui(.caption2, weight: .bold))
                        .kerning(0.8)
                        .foregroundStyle(SelahColors.textSoft)
                }
                demoCard(label: "A prayer you can say") {
                    if isGenerating {
                        HStack(spacing: 10) {
                            TypingIndicator()
                            Text("Preparing a prayer")
                        }
                        .font(SelahFont.ui(.subheadline))
                        .foregroundStyle(SelahColors.textMuted)
                    } else {
                        Text(demoResult.isEmpty ? CompanionTextService.unavailableMessage : demoResult)
                            .font(SelahFont.display(fixedSize: 16))
                            .lineSpacing(5)
                            .foregroundStyle(SelahColors.text)
                    }
                }
                // Mock v4 footer disclaimer — companion is not a pastor/priest/therapist.
                Text(OnboardingCopy.companionDisclaimer)
                    .font(SelahFont.ui(.caption2))
                    .foregroundStyle(SelahColors.textSoft)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
    }

    /// Mock v4 `.typing` — three small dots blinking/lifting in a stagger.
    private struct TypingIndicator: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var animating = false

        var body: some View {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(SelahColors.textSoft)
                        .frame(width: 7, height: 7)
                        .opacity(animating ? 1 : 0.35)
                        .offset(y: animating ? -2 : 1)
                        .animation(
                            reduceMotion
                                ? nil
                                : .easeInOut(duration: 0.575)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.16),
                            value: animating
                        )
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                animating = true
            }
            .accessibilityLabel("Selah is preparing")
        }
    }

    private func demoCard<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: label.contains("Scripture") ? "book" : "hands.sparkles")
                .font(SelahFont.ui(.caption, weight: .semibold))
                .textCase(.uppercase)
                .kerning(0.8)
                .foregroundStyle(SelahColors.textSoft)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SelahColors.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE8E2D8), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: — Screen 12 · Building (progress ring + checklist)

    private var building: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(SelahColors.text.opacity(0.09), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: buildProgress)
                    .stroke(SelahColors.primaryDeep, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: buildProgress)
                Text("\(Int(buildProgress * 100))%")
                    .font(SelahFont.display(fixedSize: 28))
            }
            .frame(width: 132, height: 132)
            Text("Creating your 7-day journey…")
                .font(SelahFont.display(.title3))
                .foregroundStyle(SelahColors.text)
            VStack(alignment: .leading, spacing: 11) {
                buildStep("Reading your answers", done: buildProgress >= 0.25)
                buildStep("Choosing passages for \((desire ?? .peace).planLabel.lowercased())", done: buildProgress >= 0.5)
                buildStep("Setting a 5-minute rhythm", done: buildProgress >= 0.75)
                buildStep("Preparing your private space", done: buildProgress >= 1)
            }
            .padding(.horizontal, 46)
            Spacer()
            Spacer()
        }
    }

    private func buildStep(_ text: String, done: Bool) -> some View {
        HStack(spacing: 11) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(done ? Color.white : .clear)
                .frame(width: 20, height: 20)
                .background(Circle().fill(done ? SelahColors.primaryDeep : Color.clear))
                .overlay(Circle().stroke(done ? SelahColors.primaryDeep : Color(hex: 0xD9D2C6), lineWidth: 1.5))
            Text(text)
                .font(SelahFont.ui(.subheadline))
                .foregroundStyle(done ? SelahColors.text : SelahColors.textSoft)
        }
    }

    // MARK: — Screen 14 · Widget hook (Coming soon + lock-screen preview)

    private var widget: some View {
        VStack(spacing: 12) {
            Spacer()
            SelahChip(text: "Coming soon", style: .gold)
            Text("A verse on your Lock Screen every morning.")
                .font(SelahFont.display(.title2))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 30)
            Text("Before the feed gets you. One line, waiting.")
                .font(SelahFont.ui(.subheadline))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            lockscreenPreview
                .padding(.top, 12)
            Spacer()
        }
    }

    /// Mock v4 `.lockscreen` — gradient sky card with clock + translucent widget row.
    private var lockscreenPreview: some View {
        VStack(spacing: 4) {
            Text("Monday, 24 August")
                .font(SelahFont.ui(.caption, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.92))
            Text("6:30")
                .font(.system(size: 44, weight: .semibold))
                .kerning(-1)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.14), radius: 6, y: 2)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("SELAH")
                        .font(SelahFont.ui(.caption2, weight: .bold))
                        .kerning(0.8)
                }
                .foregroundStyle(Color.white.opacity(0.85))
                Text("“This is the day which the Lord hath made; we will rejoice.”")
                    .font(SelahFont.ui(.footnote))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.22))
            )
            .padding(.top, 12)
        }
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .frame(width: 248)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x7EA6E8), location: 0),
                            .init(color: Color(hex: 0xC9A87A), location: 0.62),
                            .init(color: Color(hex: 0xE6C68F), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .shadow(color: Color(hex: 0x2C2825).opacity(0.24), radius: 20, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lock Screen preview")
    }

    // MARK: — Screen 15 · Social proof (avatar row + review cards)

    private var social: some View {
        VStack(spacing: 12) {
            Spacer()
            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [SelahColors.primarySoft, SelahColors.accentSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay(Circle().stroke(SelahColors.surface, lineWidth: 2))
                        .rotationEffect(.degrees(Double(index) * 17))
                        .opacity(1.0 - Double(index) * 0.04)
                }
            }
            Text(OnboardingCopy.socialTitle)
                .font(SelahFont.display(.title3))
                .multilineTextAlignment(.center)
                .foregroundStyle(SelahColors.text)
                .padding(.horizontal, 26)
                .padding(.top, 4)
            ForEach(OnboardingCopy.socialQuotes, id: \.self) { quote in
                Text("“\(quote)”")
                    .font(SelahFont.ui(.subheadline))
                    .italic()
                    .lineSpacing(3)
                    .foregroundStyle(SelahColors.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SelahColors.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE8E2D8), lineWidth: 1))
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 1)
                    .padding(.horizontal, 24)
            }
            Spacer()
        }
    }

    /// Mock v4 `.quiz-card`. Single-column = horizontal row; two-column = vertical
    /// (icon above label, centered, taller) exactly like `.quiz.two .quiz-card`.
    private func quizCard(_ title: String, _ subtitle: String?, _ symbol: String, selected: Bool, action: @escaping () -> Void, compact: Bool = false) -> some View {
        Button(action: action) {
            Group {
                if compact {
                    VStack(spacing: 9) {
                        Image(systemName: symbol)
                            .font(.system(size: 16))
                            .foregroundStyle(selected ? SelahColors.primaryDeep : SelahColors.primary.opacity(0.85))
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 11).fill(SelahColors.primarySoft))
                        Text(title)
                            .font(SelahFont.ui(.subheadline, weight: .semibold))
                            .foregroundStyle(SelahColors.text)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 112)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 18)
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: symbol)
                            .font(.system(size: 16))
                            .foregroundStyle(selected ? SelahColors.primaryDeep : SelahColors.primary.opacity(0.85))
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 11).fill(SelahColors.primarySoft))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(SelahFont.ui(.subheadline, weight: .semibold))
                                .foregroundStyle(SelahColors.text)
                                .multilineTextAlignment(.leading)
                            if let subtitle {
                                Text(subtitle)
                                    .font(SelahFont.ui(.caption))
                                    .foregroundStyle(SelahColors.textMuted)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Spacer(minLength: 2)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SelahColors.primaryDeep)
                            .opacity(selected ? 1 : 0)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .frame(minHeight: 60, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: compact ? .center : .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SelahColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? SelahColors.primaryDeep : Color(hex: 0xE8E2D8), lineWidth: selected ? 1.5 : 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Stat bar inside a white card, matching mock v4 `.stat-item` + `.bar`.
struct StatBarCard: View {
    let label: String
    let target: Double
    let tint: Color

    @State private var progress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(SelahFont.ui(.subheadline, weight: .semibold))
                .foregroundStyle(SelahColors.text)
            HStack(alignment: .center) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: 0xF5EDE3))
                        Capsule()
                            .fill(tint)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 8)
                Text("\(Int((target * 100).rounded()))%")
                    .font(SelahFont.ui(.subheadline, weight: .bold))
                    .foregroundStyle(tint)
                    .monospacedDigit()
            }
            .padding(.top, 9)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SelahColors.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE8E2D8), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 1)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { progress = target }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PlanRevealView: View {
    @Environment(AppEnvironment.self) private var env
    let desire: OnboardingDesire?

    var body: some View {
        let theme = env.planRepository.theme(from: desire ?? .peace)
        let days = theme?.weekDays(week: 1) ?? []
        // Mock v4 screen 13 — left-aligned header, plan-day rows, gold "Start today" chip.
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 40)
            Text("Your week")
                .font(SelahFont.ui(.caption, weight: .semibold))
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(SelahColors.textSoft)
            Group {
                if let theme {
                    Text("7 days toward \(theme.label.lowercased())")
                        .font(SelahFont.display(.title2))
                        .foregroundStyle(SelahColors.text)
                } else {
                    Text("7 days toward peace")
                        .font(SelahFont.display(.title2))
                        .foregroundStyle(SelahColors.text)
                }
            }
            .padding(.top, 4)
            Text("Five minutes a day. One passage, one prayer, one honest moment.")
                .font(SelahFont.ui(.subheadline))
                .lineSpacing(3)
                .foregroundStyle(SelahColors.textMuted)
                .padding(.top, 6)
            VStack(spacing: 9) {
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    HStack(spacing: 13) {
                        // Real calendar: row 0 = today's actual weekday, then onward.
                        Text(Self.weekdayLabel(offset: index))
                            .font(SelahFont.ui(.caption2, weight: .bold))
                            .textCase(.uppercase)
                            .kerning(0.5)
                            .foregroundStyle(index == 0 ? SelahColors.accentDeep : SelahColors.textMuted)
                            .frame(width: 38, height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 11)
                                    .fill(index == 0 ? SelahColors.accentSoft : Color(hex: 0xF5EDE3))
                            )
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(day.book) \(day.chapter)")
                                .font(SelahFont.ui(.subheadline, weight: .semibold))
                                .foregroundStyle(SelahColors.text)
                        }
                        Spacer()
                        if index == 0 {
                            Text("Start today")
                                .font(SelahFont.ui(.caption2, weight: .semibold))
                                .foregroundStyle(SelahColors.accentDeep)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(SelahColors.accentSoft))
                                .overlay(Capsule().stroke(Color(hex: 0xC49A3C).opacity(0.28), lineWidth: 1))
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(SelahColors.textSoft)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(SelahColors.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE8E2D8), lineWidth: 1))
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 1)
                }
            }
            .padding(.top, 18)
            Spacer(minLength: 16)
        }
        .padding(.horizontal, 22)
    }

    /// "Start today" really means today — labels run from the current weekday.
    static func weekdayLabel(offset: Int, from date: Date = .now) -> String {
        let day = Calendar.current.date(byAdding: .day, value: offset, to: date) ?? date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day)
    }
}
