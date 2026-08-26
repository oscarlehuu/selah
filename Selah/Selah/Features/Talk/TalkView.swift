import SwiftUI

struct TalkView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var engine = TalkSessionEngine()
    @State private var input = ""
    @State private var showCrisis = false
    @State private var showPrivacy = false
    @State private var sessionId: UUID?
    @State private var confirmClear = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modeSegment
                privacyBannerView
                chatScroll
                if !engine.chips.isEmpty {
                    suggestionRow
                }
                disclaimerLine
            }
            .background(talkBackground)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) {
                SelahNavBar("Talk") {
                    SelahIconButton(systemImage: "lock.shield", label: "How privacy works") {
                        showPrivacy = true
                    }
                } trailing: {
                    SelahIconButton(systemImage: "trash", label: "Clear this session") {
                        confirmClear = true
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SelahComposerBar(text: $input, isSending: engine.isSending, onSend: send)
            }
            .confirmationDialog("Clear this session?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete conversation", role: .destructive) { engine.seedIntro() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The conversation is deleted from this device. It was never anywhere else.")
            }
            .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
            .sheet(isPresented: $showPrivacy) { PrivacyInfoView() }
        }
        .background(SelahColors.background.ignoresSafeArea())
        .onAppear(perform: appeared)
        .onDisappear {
            if !engine.lines.isEmpty {
                AnalyticsService.track("session_complete", properties: ["mode": engine.mode.rawValue])
            }
            env.clearTalkSessionsIfNeeded()
        }
    }

    // MARK: - Background

    /// Mock v4 `.talk-wrap` — warm radial glow at the top over the canvas.
    private var talkBackground: some View {
        ZStack(alignment: .top) {
            SelahColors.background
            RadialGradient(
                colors: [Color(hex: 0xFFE7BB).opacity(0.5), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
            .frame(height: 340)
        }
        .ignoresSafeArea()
    }

    // MARK: - Mode segment

    /// Mock v4 `.mode-seg` — custom pills, active = white surface + shadow.
    private var modeSegment: some View {
        HStack(spacing: 4) {
            ForEach(TalkMode.allCases) { item in
                Button {
                    modeBinding.wrappedValue = item
                } label: {
                    Text(item.title)
                        .font(SelahFont.ui(.footnote, weight: .semibold))
                        .foregroundStyle(engine.mode == item ? SelahColors.text : SelahColors.textMuted)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(engine.mode == item ? SelahColors.surface : .clear)
                                .shadow(color: .black.opacity(engine.mode == item ? 0.06 : 0), radius: 4, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(SelahColors.backgroundWarm)
        )
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .accessibilityIdentifier("talk.mode")
    }

    // MARK: - Privacy banner

    /// Mock v4 `.priv-banner` — blue-soft card with lock icon.
    private var privacyBannerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
            Text(privacyBanner)
                .font(SelahFont.ui(.caption, weight: .semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(SelahColors.primaryDeep)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(SelahColors.primarySoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(SelahColors.primary.opacity(0.22), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Chat

    private var chatScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(engine.lines) { line in
                        talkRow(line)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .id(line.id)
                    }
                    if !CompanionTextService.isOnDeviceCompanionAvailable {
                        Text(CompanionTextService.unavailableMessage)
                            .font(SelahFont.ui(.caption))
                            .foregroundStyle(SelahColors.textSoft)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                            .accessibilityIdentifier("talk.unavailable")
                    }
                    if engine.isSending {
                        TalkTypingDots()
                            .id("typing")
                            .accessibilityIdentifier("talk.preparing")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .animation(.easeOut(duration: 0.38), value: engine.lines.count)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: engine.lines.count) {
                if let last = engine.lines.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func talkRow(_ line: TalkLine) -> some View {
        if line.role == .sys {
            Text(line.text)
                .font(SelahFont.ui(.caption))
                .foregroundStyle(SelahColors.textSoft)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("talk.message.sys")
        } else {
            VStack(alignment: line.role == .user ? .trailing : .leading, spacing: 6) {
                TalkBubble(text: line.text, isUser: line.role == .user)
                if line.role == .assistant, let ref = line.scriptureReference {
                    VStack(alignment: .leading, spacing: 2) {
                        if let snippet = line.scriptureText {
                            Text("“\(snippet)”")
                                .font(SelahFont.verse(.footnote))
                        }
                        Text(ref)
                            .font(SelahFont.ui(.caption2, weight: .semibold))
                    }
                    .foregroundStyle(SelahColors.primaryDeep)
                    .padding(.leading, 4)
                    .accessibilityIdentifier("talk.scripture")
                }
            }
            .frame(maxWidth: .infinity, alignment: line.role == .user ? .trailing : .leading)
            .accessibilityIdentifier(line.role == .assistant ? "talk.message.assistant" : "talk.message.\(line.role.rawValue)")
        }
    }

    // MARK: - Suggestions

    /// Mock v4 `.suggest` — white chips with soft shadow.
    private var suggestionRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(engine.chips, id: \.self) { suggestion in
                    Button {
                        input = suggestion
                        send()
                    } label: {
                        SelahChip(text: suggestion)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("talk.suggestion")
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 10)
    }

    // MARK: - Disclaimer

    /// Mock v4 `.talk-foot` — small centered soft text + quiet crisis link.
    private var disclaimerLine: some View {
        HStack(spacing: 4) {
            Text(OnboardingCopy.companionDisclaimer)
            Button("Need urgent help?") { showCrisis = true }
                .foregroundStyle(SelahColors.primaryDeep)
                .underline()
        }
        .font(SelahFont.ui(.caption2))
        .foregroundStyle(SelahColors.textSoft)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    // MARK: - Logic (unchanged)

    private var modeBinding: Binding<TalkMode> {
        Binding(
            get: { engine.mode },
            set: { next in
                engine.mode = next
                env.selectedTalkMode = next
                engine.seedIntro()
            }
        )
    }

    private var privacyBanner: String {
        let extra = env.settings?.autoDeleteTalkSessions == true ? " · auto-deletes when you leave" : ""
        return "On-device only\(extra)"
    }

    private func appeared() {
        AnalyticsService.track("talk_open", properties: [
            "fm_available": CompanionTextService.isOnDeviceCompanionAvailable
        ])
        if !CompanionTextService.isOnDeviceCompanionAvailable {
            AnalyticsService.track("fm_unavailable_shown")
        }
        engine.mode = env.selectedTalkMode
        if sessionId == nil { sessionId = env.startTalkSession() }
        applyPendingContext()
        if engine.lines.isEmpty {
            if env.isDemoMode {
                engine.seedPreview(DemoSeedData.talkPreviewLines)
            } else {
                engine.seedIntro()
            }
        }
    }

    private func applyPendingContext() {
        if let mood = env.pendingTalkMood {
            engine.seedMood(mood.title)
            env.pendingTalkMood = nil
        } else if let verse = env.pendingTalkVerse {
            engine.seedVerse(verse)
            env.selectedTalkMode = .reflect
            env.pendingTalkVerse = nil
        }
    }

    private func send() {
        let text = input
        input = ""
        Task {
            let result = await engine.send(text)
            switch result {
            case .empty:
                break
            case .crisis:
                showCrisis = true
                AnalyticsService.track("crisis_sheet_shown")
            case .replied(let user, let assistant):
                if let sessionId {
                    env.appendTalkMessage(sessionId: sessionId, role: "user", content: user.text)
                    env.appendTalkMessage(sessionId: sessionId, role: "assistant", content: assistant.persistedText)
                }
            }
        }
    }
}

/// Three bouncing dots shown while Selah prepares a reply (mock typing indicator).
private struct TalkTypingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bouncing = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(SelahColors.textSoft)
                    .frame(width: 7, height: 7)
                    .offset(y: bouncing && !reduceMotion ? -4 : 0)
                    .animation(
                        reduceMotion ? nil :
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.16),
                        value: bouncing
                    )
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 19, bottomLeadingRadius: 6,
                bottomTrailingRadius: 19, topTrailingRadius: 19,
                style: .continuous
            )
            .fill(SelahColors.surface)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { bouncing = true }
        .accessibilityLabel("Selah is preparing")
    }
}
