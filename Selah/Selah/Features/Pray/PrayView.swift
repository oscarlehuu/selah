import SwiftUI

struct PrayView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var engine = LectioPrayEngine()
    @State private var step = 0
    @State private var reflectionWord = ""
    @State private var useQuickDurations = false
    @State private var secondsRemaining = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var showAmenBurst = false

    private let steps = LectioStep.all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepsIndicator
                ScrollView {
                    VStack(spacing: 10) {
                        if step == 0 {
                            PrayBreathCircle(label: "Slow down")
                        }
                        Text(steps[step].headline)
                            .font(SelahFont.display(.title2))
                            .foregroundStyle(SelahColors.text)
                        Text(steps[step].guide)
                            .font(SelahFont.ui(.subheadline))
                            .foregroundStyle(SelahColors.textMuted)
                        if secondsRemaining > 0 {
                            Text(timerLabel)
                                .font(SelahFont.ui(.footnote, weight: .medium))
                                .foregroundStyle(SelahColors.primaryDeep)
                        }
                        stepContent
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 26)
                    .padding(.bottom, 24)
                }
            }
            .background(prayBackground)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) {
                SelahNavBar("Pray") {
                    EmptyView()
                } trailing: {
                    SelahChip(text: timerChipLabel, systemImage: "clock")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
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
                            .foregroundStyle(SelahColors.textMuted)
                    }
                }
            }
            .overlay {
                if showAmenBurst {
                    PrayAmenBurst()
                        .transition(.opacity)
                }
            }
        }
        .background(SelahColors.background.ignoresSafeArea())
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

    // MARK: - Background

    /// Mock v4 `.lectio` — warm gold radial glow at the top over the canvas.
    private var prayBackground: some View {
        ZStack(alignment: .top) {
            SelahColors.background
            RadialGradient(
                colors: [Color(hex: 0xFFE4B2).opacity(0.6), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 340
            )
            .frame(height: 360)
        }
        .ignoresSafeArea()
    }

    // MARK: - Steps indicator

    /// Mock v4 `.steps` — small bars with tiny uppercase labels.
    private var stepsIndicator: some View {
        HStack(spacing: 6) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(index))
                        .frame(width: 26, height: 3)
                    Text(item.name)
                        .font(SelahFont.ui(.caption2, weight: .bold))
                        .textCase(.uppercase)
                        .kerning(0.6)
                        .foregroundStyle(index == step ? SelahColors.primaryDeep : SelahColors.textSoft)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
        .padding(.bottom, 18)
        .accessibilityLabel("Lectio Divina progress, step \(step + 1) of \(steps.count)")
    }

    private func barColor(_ index: Int) -> Color {
        if index < step { return SelahColors.primaryDeep }
        if index == step { return SelahColors.gold }
        return SelahColors.borderStrong
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0:
            VStack(alignment: .leading, spacing: 10) {
                Text("“\(passagePreview)”")
                    .font(SelahFont.verse(.body))
                    .foregroundStyle(SelahColors.text)
                Text(passageReference)
                    .font(SelahFont.ui(.caption2, weight: .bold))
                    .textCase(.uppercase)
                    .kerning(0.6)
                    .foregroundStyle(SelahColors.textSoft)
            }
            .multilineTextAlignment(.leading)
            .selahCard(padding: 22)
            .padding(.top, 8)
        case 1:
            VStack(spacing: 14) {
                TextField("What word stood out?", text: $reflectionWord)
                    .font(SelahFont.ui(.body))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SelahColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SelahColors.borderStrong, lineWidth: 1)
                    )
                    .accessibilityIdentifier("pray.word")
                HStack(spacing: 8) {
                    ForEach(["refuge", "strength", "present help"], id: \.self) { word in
                        Button {
                            reflectionWord = word
                        } label: {
                            SelahChip(text: word, style: reflectionWord == word ? .gold : .neutral)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 10)
        case 2:
            prayStep
        default:
            PrayBreathCircle(label: "Stay here")
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var prayStep: some View {
        if !CompanionTextService.isOnDeviceCompanionAvailable || engine.turn?.source == .unavailable {
            Text(CompanionTextService.silentPrayMessage)
                .font(SelahFont.ui(.subheadline))
                .foregroundStyle(SelahColors.textSoft)
                .accessibilityIdentifier("pray.silent")
        } else if engine.isGenerating && engine.turn == nil {
            ProgressView("Preparing a prayer")
                .font(SelahFont.ui(.footnote))
                .foregroundStyle(SelahColors.textSoft)
                .padding(.top, 10)
        } else if let turn = engine.turn, turn.source != .unavailable {
            VStack(alignment: .leading, spacing: 10) {
                Text(turn.reply)
                    .font(SelahFont.verse(.body))
                    .foregroundStyle(SelahColors.text)
                    .accessibilityIdentifier("pray.draft")
                if let ref = turn.scriptureReference {
                    Text(ref)
                        .font(SelahFont.ui(.caption, weight: .semibold))
                        .foregroundStyle(SelahColors.textSoft)
                }
            }
            .multilineTextAlignment(.leading)
            .selahCard(padding: 22)
            .padding(.top, 8)
            Button {
                Task { await generatePrayer(force: true) }
            } label: {
                Label("Another prayer", systemImage: "arrow.clockwise")
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.textMuted)
            }
            .disabled(engine.isGenerating)
            .padding(.top, 6)
            .accessibilityIdentifier("pray.another")
        } else {
            Button {
                Task { await generatePrayer(force: true) }
            } label: {
                Text("Generate prayer")
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.primaryDeep)
            }
            .disabled(engine.isGenerating)
            .padding(.top, 8)
            .accessibilityIdentifier("pray.generate")
        }
    }

    // MARK: - Logic (unchanged)

    private var timerLabel: String {
        String(format: "%d:%02d remaining", secondsRemaining / 60, secondsRemaining % 60)
    }

    private var timerChipLabel: String {
        secondsRemaining > 0
            ? String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
            : "5 min"
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
        if reduceMotion {
            completeAmen()
        } else {
            withAnimation(.easeOut(duration: 0.2)) { showAmenBurst = true }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                withAnimation(.easeOut(duration: 0.2)) { showAmenBurst = false }
                completeAmen()
            }
        }
    }

    private func completeAmen() {
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

/// Mock v4 `.breath` — slow gold breathing circle with an uppercase whisper label.
private struct PrayBreathCircle: View {
    let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: 0xFFECC4).opacity(0.95),
                            Color(hex: 0xFFE09E).opacity(0.35),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            Text(label)
                .font(SelahFont.ui(.caption2, weight: .semibold))
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(SelahColors.accentDeep)
        }
        .scaleEffect(breathing && !reduceMotion ? 1.08 : 1)
        .opacity(breathing && !reduceMotion ? 1 : 0.85)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 5).repeatForever(autoreverses: true),
            value: breathing
        )
        .onAppear { breathing = true }
        .padding(.vertical, 8)
        .accessibilityHidden(true)
    }
}

/// Mock v4 `.amen-burst` — brief gold radial glow overlay on Amen.
private struct PrayAmenBurst: View {
    var body: some View {
        RadialGradient(
            colors: [
                Color(hex: 0xFFF0CD).opacity(0.96),
                SelahColors.background.opacity(0.98)
            ],
            center: .init(x: 0.5, y: 0.55),
            startRadius: 0,
            endRadius: 320
        )
        .ignoresSafeArea()
        .overlay {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0xFFE8B4).opacity(0.9), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
