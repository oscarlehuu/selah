import SwiftUI

struct PrayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var step = 0
    @State private var reflection = ""
    @State private var generatedPrayer = ""
    @State private var isGenerating = false
    @State private var secondsRemaining = 0
    @State private var timerTask: Task<Void, Never>?

    private let steps = ["Read", "Reflect", "Pray", "Rest"]

    var body: some View {
        SelahTabScreen("Pray") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Lectio divina")
                        .font(SelahFont.figtree(12, weight: .semibold))
                        .foregroundStyle(SelahColors.textSoft)
                    Text(steps[step])
                        .font(SelahFont.newsreader(28, weight: .semibold))
                    if secondsRemaining > 0 {
                        Text(timerLabel)
                            .font(SelahFont.figtree(14, weight: .medium))
                            .foregroundStyle(SelahColors.primaryDeep)
                    }
                    stepContent
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .selahTabScrollContent()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SelahPinnedBottomBar {
                    SelahPrimaryButton(title: step < 3 ? "Next" : "Amen") { advance() }
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
            Text(passagePreview)
                .font(SelahFont.verse(18))
        case 1:
            TextField("What is God showing you?", text: $reflection, axis: .vertical)
                .lineLimit(3...8)
                .font(SelahFont.figtree(16))
                .padding(12)
                .background(SelahColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case 2:
            if generatedPrayer.isEmpty {
                SelahPrimaryButton(title: "Generate prayer", isLoading: isGenerating) { generate() }
            } else {
                Text(generatedPrayer).font(SelahFont.verse(18))
            }
        default:
            Text("Rest in God's presence for a moment.")
                .font(SelahFont.figtree(16))
                .foregroundStyle(SelahColors.textMuted)
        }
    }

    private var passagePreview: String {
        guard let day = env.currentPlanTheme?.day(globalDay: env.planGlobalDay) else {
            return "Open your heart to today's passage."
        }
        return "\(day.book) \(day.chapter) — \(day.reflectionPrompt)"
    }

    private var durations: [Int] { env.prayQuickMode ? [90, 90, 90, 30] : [120, 120, 120, 60] }

    private func startTimer() {
        timerTask?.cancel()
        secondsRemaining = durations[step]
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
            try? env.saveJournalEntry(plaintext: reflection.isEmpty ? generatedPrayer : reflection)
        }
    }

    private func generate() {
        isGenerating = true
        Task {
            generatedPrayer = await CompanionTextService.prayerDraft(context: reflection)
            isGenerating = false
        }
    }
}
