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
        SelahTabScreen("Talk") {
            List {
                Section {
                    Picker("Mode", selection: modeBinding) {
                        ForEach(TalkMode.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("talk.mode")
                    Text(privacyBanner)
                        .font(SelahFont.ui(.caption))
                        .foregroundStyle(.secondary)
                }
                Section {
                    ForEach(engine.lines) { line in
                        talkRow(line)
                    }
                    if engine.isSending {
                        ProgressView("Selah is preparing")
                            .accessibilityIdentifier("talk.preparing")
                    }
                }
                if !engine.chips.isEmpty {
                    Section("Try saying") {
                        ForEach(engine.chips, id: \.self) { suggestion in
                            Button(suggestion) {
                                input = suggestion
                                send()
                            }
                            .accessibilityIdentifier("talk.suggestion")
                        }
                    }
                }
                Section {
                    Button("Need urgent help?") { showCrisis = true }
                    if !CompanionTextService.isOnDeviceCompanionAvailable {
                        Text(CompanionTextService.unavailableMessage)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("talk.unavailable")
                    }
                } footer: {
                    Text(OnboardingCopy.companionDisclaimer)
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                SelahComposerBar(text: $input, isSending: engine.isSending, onSend: send)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showPrivacy = true } label: {
                        Image(systemName: "lock.shield")
                    }
                    .accessibilityLabel("How privacy works")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { confirmClear = true } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Clear this session")
                }
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
        .onAppear(perform: appeared)
        .onDisappear {
            if !engine.lines.isEmpty {
                AnalyticsService.track("session_complete", properties: ["mode": engine.mode.rawValue])
            }
            env.clearTalkSessionsIfNeeded()
        }
    }

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

    @ViewBuilder
    private func talkRow(_ line: TalkLine) -> some View {
        VStack(alignment: line.role == .user ? .trailing : .leading, spacing: 6) {
            Text(line.text)
                .font(SelahFont.ui(line.role == .sys ? .footnote : .body))
                .foregroundStyle(line.role == .user ? .primary : .secondary)
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
                .accessibilityIdentifier("talk.scripture")
            }
        }
        .frame(maxWidth: .infinity, alignment: line.role == .user ? .trailing : .leading)
        .accessibilityIdentifier(line.role == .assistant ? "talk.message.assistant" : "talk.message.\(line.role.rawValue)")
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
