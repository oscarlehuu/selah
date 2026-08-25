import SwiftUI

struct PrayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var engine = LectioPrayEngine()
    @State private var step = 0
    @State private var reflectionWord = ""
    @State private var useQuickDurations = false
    @State private var secondsRemaining = 0
    @State private var timerTask: Task<Void, Never>?

    private let steps = LectioStep.all

    var body: some View {
        SelahTabScreen("Pray") {
            List {
                Section {
                    ProgressView(value: Double(step + 1), total: 4)
                    Text(steps[step].headline)
                        .font(SelahFont.display(.title2))
                    Text(steps[step].guide)
                        .foregroundStyle(.secondary)
                    if secondsRemaining > 0 {
                        Text(timerLabel)
                            .font(SelahFont.ui(.footnote, weight: .medium))
                            .foregroundStyle(SelahColors.primaryDeep)
                    }
                }
                Section(steps[step].name) {
                    stepContent
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("5 min")
                        .font(SelahFont.ui(.caption, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                SelahFooterBar {
                    SelahPrimaryButton(
                        title: step < 3 ? (step == 2 ? "Continue to rest" : "Continue") : "Amen",
                        style: step < 3 ? .primary : .gold,
                        action: advance
                    )
                    .accessibilityIdentifier(step < 3 ? "pray.continue" : "pray.amen")
                    if step > 0 {
                        Button("Back") { step -= 1 }
                            .font(SelahFont.ui(.subheadline, weight: .semibold))
                    }
                }
            }
        }
        .onAppear {
            AnalyticsService.track("pray_open", properties: [
                "fm_available": CompanionTextService.isOnDeviceCompanionAvailable
            ])
            if !CompanionTextService.isOnDeviceCompanionAvailable {
                AnalyticsService.track("fm_unavailable_shown")
            }
            useQuickDurations = env.prayQuickMode
            env.prayQuickMode = false
            startTimer()
            trackStep(step)
        }
        .onDisappear { timerTask?.cancel() }
        .onChange(of: step) { _, newStep in
            trackStep(newStep)
            startTimer()
            if newStep == 2 {
                Task { await generatePrayer(force: false) }
            }
        }
    }

    private var timerLabel: String {
        String(format: "%d:%02d remaining", secondsRemaining / 60, secondsRemaining % 60)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0:
            Text("“\(passagePreview)”")
                .font(SelahFont.verse(.body))
        case 1:
            TextField("What word stood out?", text: $reflectionWord)
                .accessibilityIdentifier("pray.word")
            ForEach(["refuge", "strength", "present help"], id: \.self) { word in
                Button(word) { reflectionWord = word }
            }
        case 2:
            prayStep
        default:
            Text("Nothing left to do. Breathe with the light and let the silence be enough.")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var prayStep: some View {
        if !CompanionTextService.isOnDeviceCompanionAvailable || engine.turn?.source == .unavailable {
            Text(CompanionTextService.silentPrayMessage)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("pray.silent")
        } else if engine.isGenerating && engine.turn == nil {
            ProgressView("Preparing a prayer")
        } else if let turn = engine.turn, turn.source != .unavailable {
            Text(turn.reply)
                .font(SelahFont.verse(.body))
                .accessibilityIdentifier("pray.draft")
            if let ref = turn.scriptureReference {
                Text(ref)
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Button("Another prayer") {
                Task { await generatePrayer(force: true) }
            }
            .disabled(engine.isGenerating)
            .accessibilityIdentifier("pray.another")
        } else {
            Button("Generate prayer") {
                Task { await generatePrayer(force: true) }
            }
            .disabled(engine.isGenerating)
            .accessibilityIdentifier("pray.generate")
        }
    }

    private var passagePreview: String {
        if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
            return "\(day.book) \(day.chapter) — \(day.reflectionPrompt)"
        }
        return "God is our refuge and strength, a very present help in trouble."
    }

    private var passageReference: String {
        if let pending = env.pendingPrayVerse, !pending.isEmpty { return pending }
        if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
            return "\(day.book) \(day.chapter)"
        }
        return "Psalm 46:1"
    }

    private var durations: [Int] { useQuickDurations ? [90, 90, 90, 30] : [120, 120, 120, 60] }

    private func startTimer() {
        timerTask?.cancel()
        secondsRemaining = durations[min(step, durations.count - 1)]
        timerTask = Task {
            while secondsRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                secondsRemaining -= 1
            }
        }
    }

    private func trackStep(_ index: Int) {
        let names = ["lectio_step_read", "lectio_step_reflect", "lectio_step_pray", "lectio_step_rest"]
        AnalyticsService.track(names[index])
    }

    private func advance() {
        if step < 3 {
            step += 1
            return
        }
        AnalyticsService.track("amen_tap")
        AnalyticsService.track("lectio_complete")
        let drafted = engine.turn?.source == .onDevice ? (engine.turn?.reply ?? "") : ""
        let text = reflectionWord.isEmpty ? drafted : reflectionWord
        if !text.isEmpty { try? env.saveJournalEntry(plaintext: text) }
        step = 0
        reflectionWord = ""
        engine.reset()
        env.openMainTab(.today)
    }

    private func generatePrayer(force: Bool) async {
        if !force, engine.turn?.source == .onDevice { return }
        let context = PrayerDraftContext(
            reflectionWord: reflectionWord,
            verse: passageReference,
            mood: env.pendingPrayMood
        )
        if force {
            if await engine.anotherPrayer() == nil {
                _ = await engine.draft(context)
            }
        } else {
            _ = await engine.draft(context)
        }
    }
}
