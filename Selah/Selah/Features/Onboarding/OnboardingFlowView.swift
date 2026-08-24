import SwiftUI

struct OnboardingFlowView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var step = 1
    @State private var distance: OnboardingDistance = .distant
    @State private var desire: OnboardingDesire = .peace
    @State private var habit = "sometimes"
    @State private var demoMood = "heavy"
    @State private var demoResult = ""
    @State private var isGenerating = false

    var body: some View {
        SelahFlowScreen {
            VStack(spacing: 0) {
                ProgressView(value: Double(step), total: 15)
                    .tint(SelahColors.primaryDeep)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                ScrollView {
                    content
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
                .selahFlowScrollContent()
            }
        } bottom: {
            SelahPinnedBottomBar {
                SelahPrimaryButton(
                    title: primaryCTA,
                    style: step == 1 || step == 10 ? .gold : .primary,
                    isLoading: isGenerating,
                    action: advance
                )
                .accessibilityIdentifier("onboarding.continue")
                if step == 8 {
                    Button("I want to try") { advance() }
                        .font(SelahFont.figtree(15))
                        .foregroundStyle(SelahColors.textMuted)
                }
            }
        }
        .onAppear { track() }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 1: welcome
        case 2: titleBlock("You have time to scroll for hours. Five minutes with God feels hard.", sub: "It isn’t that you don’t love him. It’s that nothing in your day makes room for him.")
        case 3: stat
        case 4: quizDistance
        case 5: quizDesire
        case 6: quizHabit
        case 7: titleBlock(OnboardingCopy.mirrorText(desire: desire, distance: distance), sub: "That honesty is already a prayer. Most people never say it out loud.")
        case 8: titleBlock("Will you make space for God this week?", sub: "Five minutes a day. Not a performance — a place to return to.")
        case 9: privacy
        case 10: demoMoodPicker
        case 11: demoResultView
        case 12: titleBlock("Creating your 7-day journey…", sub: "Passages chosen for \(desire.planLabel.lowercased()).")
        case 13: planReveal
        case 14: widget
        case 15: social
        default: EmptyView()
        }
    }

    private var primaryCTA: String {
        switch step {
        case 1: OnboardingCopy.welcomeCTA
        case 2: "That’s true for me"
        case 8: "Yes, I’m ready"
        case 9: "I understand"
        case 10: "Pray with me"
        case 11: "This is what I needed"
        case 14: "I want that"
        case 15: "Continue"
        default: "Continue"
        }
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            SkyHero()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text(OnboardingCopy.welcomeTitle)
                .font(SelahFont.newsreader(40, weight: .semibold))
            Text(OnboardingCopy.welcomeSubtitle)
                .font(SelahFont.figtree(13, weight: .semibold))
                .foregroundStyle(SelahColors.textMuted)
            Text("“\(OnboardingCopy.welcomeVerse)”")
                .font(SelahFont.verse(20))
                .multilineTextAlignment(.center)
            Text("Psalm 46:10 · KJV")
                .font(SelahFont.figtree(12, weight: .semibold))
                .foregroundStyle(SelahColors.textSoft)
            Text("Selah is a Hebrew word in the Psalms. It means: stop here. Breathe. Listen to God.")
                .font(SelahFont.figtree(16))
                .foregroundStyle(SelahColors.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var stat: some View {
        VStack(spacing: 16) {
            Text("The gap").font(SelahFont.figtree(12, weight: .semibold)).foregroundStyle(SelahColors.textSoft)
            Text("1 in 5").font(SelahFont.newsreader(56, weight: .bold))
            Text("Most Christians want to read the Bible daily. Few build the habit.")
                .font(SelahFont.figtree(16))
                .multilineTextAlignment(.center)
            statRow("Want to read daily", "86%")
            statRow("Actually do", "19%")
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(SelahFont.figtree(15, weight: .semibold))
            Spacer()
            Text(value).font(SelahFont.figtree(15, weight: .bold)).foregroundStyle(SelahColors.primaryDeep)
        }
        .padding(14)
        .background(SelahColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var quizDistance: some View {
        quiz(title: "What keeps you furthest from God right now?", options: OnboardingDistance.allCases.map(\.title), selected: distance.title) { title in
            if let match = OnboardingDistance.allCases.first(where: { $0.title == title }) { distance = match }
        }
    }

    private var quizDesire: some View {
        quiz(title: "What do you want most?", options: OnboardingDesire.allCases.map(\.title), selected: desire.title) { title in
            if let match = OnboardingDesire.allCases.first(where: { $0.title == title }) { desire = match }
        }
    }

    private var quizHabit: some View {
        quiz(title: "How often do you read the Bible now?", options: ["Never", "Sometimes", "Often", "Daily"], selected: habit.capitalized) { habit = $0.lowercased() }
    }

    private var privacy: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your prayers stay on this phone.")
                .font(SelahFont.newsreader(26, weight: .semibold))
            Text("Not the cloud. Not us. Not anyone.")
                .font(SelahFont.figtree(16))
                .foregroundStyle(SelahColors.textMuted)
            bullet("Nothing is uploaded. The companion runs on your device.")
            bullet("Journal is encrypted on this iPhone, locked with Face ID.")
            bullet("Auto-delete a session when you close it, if you prefer.")
        }
    }

    private var demoMoodPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How is your heart right now?")
                .font(SelahFont.newsreader(24, weight: .semibold))
            Text("Pick one. Selah will pray with you — not at you.")
                .font(SelahFont.figtree(15))
                .foregroundStyle(SelahColors.textMuted)
            ForEach(["peaceful", "anxious", "grateful", "heavy"], id: \.self) { mood in
                quizCard(title: mood.capitalized, selected: demoMood == mood) { demoMood = mood }
            }
            if !CompanionTextService.isOnDeviceCompanionAvailable {
                Text(CompanionTextService.unavailableMessage)
                    .font(SelahFont.figtree(14))
                    .foregroundStyle(SelahColors.textMuted)
            }
        }
    }

    private var demoResultView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feeling \(demoMood) · on this iPhone")
                .font(SelahFont.figtree(12, weight: .semibold))
                .foregroundStyle(SelahColors.textSoft)
            Text(demoResult.isEmpty ? CompanionTextService.unavailableMessage : demoResult)
                .font(SelahFont.verse(18))
            Text("Selah is a companion for prayer — not a pastor, priest, or therapist.")
                .font(SelahFont.figtree(13))
                .foregroundStyle(SelahColors.textSoft)
        }
    }

    private var planReveal: some View {
        let theme = env.planRepository.theme(from: desire)
        return VStack(alignment: .leading, spacing: 12) {
            Text("7 days toward \(desire.planLabel.lowercased())")
                .font(SelahFont.newsreader(26, weight: .semibold))
            Text("Five minutes a day. One passage, one prayer, one honest moment.")
                .font(SelahFont.figtree(15))
                .foregroundStyle(SelahColors.textMuted)
            ForEach(theme?.weekDays(week: 1) ?? []) { day in
                Text("\(day.label) · \(day.book) \(day.chapter)")
                    .font(SelahFont.figtree(15))
            }
        }
    }

    private var widget: some View {
        VStack(spacing: 16) {
            Text("A verse on your Lock Screen every morning.")
                .font(SelahFont.newsreader(24, weight: .semibold))
                .multilineTextAlignment(.center)
            Text("Coming soon")
                .font(SelahFont.figtree(12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(SelahColors.accentSoft)
                .foregroundStyle(SelahColors.accentDeep)
                .clipShape(Capsule())
            Text("“This is the day which the Lord hath made; we will rejoice.”")
                .font(SelahFont.verse(18))
                .multilineTextAlignment(.center)
        }
    }

    private var social: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("People who felt far away — a week later")
                .font(SelahFont.newsreader(24, weight: .semibold))
            Text("“Finally a place that doesn’t shame me.”")
                .font(SelahFont.verse(18))
            Text("“Five minutes before work. First time I’ve kept a Bible habit past three days.”")
                .font(SelahFont.verse(18))
        }
    }

    private func titleBlock(_ title: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(SelahFont.newsreader(26, weight: .semibold))
            Text(sub).font(SelahFont.figtree(16)).foregroundStyle(SelahColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quiz(title: String, options: [String], selected: String, onSelect: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(SelahFont.newsreader(22, weight: .semibold))
            ForEach(options, id: \.self) { option in
                quizCard(title: option, selected: selected == option) { onSelect(option) }
            }
        }
    }

    private func quizCard(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(SelahFont.figtree(16, weight: .medium)).foregroundStyle(SelahColors.text)
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(SelahColors.primaryDeep) }
            }
            .padding(14)
            .background(selected ? SelahColors.primarySoft : SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundStyle(SelahColors.primaryDeep)
            Text(text).font(SelahFont.figtree(15)).foregroundStyle(SelahColors.textMuted)
        }
    }

    private func advance() {
        if step == 10 {
            isGenerating = true
            Task {
                demoResult = await CompanionTextService.reflection(for: demoMood)
                isGenerating = false
                step += 1
                track()
            }
            return
        }
        if step == 15 {
            env.completeOnboarding(distance: distance, desire: desire, habit: habit)
            return
        }
        step += 1
        track()
    }

    private func track() {
        AnalyticsService.track(OnboardingCopy.eventName(for: step))
    }
}

struct SkyHero: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xC9DDF8), Color(hex: 0xF4E6C8), Color(hex: 0xFAF7F2)], startPoint: .top, endPoint: .bottom)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.45))
                .frame(width: 90, height: 120)
                .overlay(
                    VStack(spacing: 6) {
                        Capsule().fill(Color(hex: 0xEDBE55).opacity(0.7)).frame(width: 40, height: 8)
                        Capsule().fill(SelahColors.primaryDeep.opacity(0.25)).frame(width: 54, height: 8)
                        Capsule().fill(SelahColors.primaryDeep.opacity(0.18)).frame(width: 46, height: 8)
                    }
                )
                .offset(y: 10)
        }
    }
}
