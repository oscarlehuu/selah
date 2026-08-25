import SwiftUI

struct PrayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var step = 0
    @State private var reflectionWord = ""
    @State private var generatedPrayer = ""
    @State private var isGenerating = false
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
            if env.prayQuickMode { env.prayQuickMode = false }
            startTimer()
            trackStep(step)
        }
        .onDisappear { timerTask?.cancel() }
        .onChange(of: step) { _, newStep in
            trackStep(newStep)
            startTimer()
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
            ForEach(["refuge", "strength", "present help"], id: \.self) { word in
                Button(word) { reflectionWord = word }
            }
        case 2:
            if generatedPrayer.isEmpty {
                Button("Generate prayer") { generate() }
                    .disabled(isGenerating)
                if isGenerating { ProgressView() }
            } else {
                Text(generatedPrayer).font(SelahFont.verse(.body))
                Button("Another prayer") { generate() }
            }
        default:
            Text("Nothing left to do. Breathe with the light and let the silence be enough.")
                .foregroundStyle(.secondary)
        }
    }

    private var passagePreview: String {
        if let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) {
            return "\(day.book) \(day.chapter) — \(day.reflectionPrompt)"
        }
        return "God is our refuge and strength, a very present help in trouble."
    }

    private var durations: [Int] { env.prayQuickMode ? [90, 90, 90, 30] : [120, 120, 120, 60] }

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
        } else {
            AnalyticsService.track("amen_tap")
            AnalyticsService.track("lectio_complete")
            let text = reflectionWord.isEmpty ? generatedPrayer : reflectionWord
            if !text.isEmpty { try? env.saveJournalEntry(plaintext: text) }
        }
    }

    private func generate() {
        isGenerating = true
        Task {
            generatedPrayer = await CompanionTextService.prayerDraft(context: reflectionWord)
            isGenerating = false
        }
    }
}

private struct LectioStep {
    let name: String
    let headline: String
    let guide: String

    static let all = [
        LectioStep(name: "Read", headline: "Read it slowly", guide: "Read the words once out loud, then once in silence. Don’t study it. Just let it arrive."),
        LectioStep(name: "Reflect", headline: "Where does it touch you?", guide: "One word probably stood out. Stay with that word for a moment instead of moving on."),
        LectioStep(name: "Pray", headline: "Say it back to God", guide: "Here is a prayer in your own weather. Change any word. It is yours."),
        LectioStep(name: "Rest", headline: "Now just stay", guide: "Nothing left to do. Breathe with the light and let the silence be enough.")
    ]
}
