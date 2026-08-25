import SwiftUI

struct TalkView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var input = ""
    @State private var messages: [(role: String, text: String)] = []
    @State private var isSending = false
    @State private var showCrisis = false
    @State private var showPrivacy = false
    @State private var sessionId: UUID?
    @State private var confirmClear = false

    var body: some View {
        SelahTabScreen("Talk") {
            List {
                Section {
                    Picker("Mode", selection: Binding(
                        get: { env.selectedTalkMode },
                        set: { env.selectedTalkMode = $0; seedIntro(force: true) }
                    )) {
                        ForEach(TalkMode.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(privacyBanner)
                        .font(SelahFont.ui(.caption))
                        .foregroundStyle(.secondary)
                }
                Section {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                        Text(message.text)
                            .font(SelahFont.ui(message.role == "sys" ? .footnote : .body))
                            .foregroundStyle(message.role == "user" ? .primary : .secondary)
                            .frame(maxWidth: .infinity, alignment: message.role == "user" ? .trailing : .leading)
                    }
                    if isSending { ProgressView("Selah is preparing") }
                }
                if messages.count <= 3 {
                    Section("Try saying") {
                        ForEach(env.selectedTalkMode.suggestions, id: \.self) { suggestion in
                            Button(suggestion) { input = suggestion; send() }
                        }
                    }
                }
                Section {
                    Button("Need urgent help?") { showCrisis = true }
                    if !CompanionTextService.isOnDeviceCompanionAvailable {
                        Text(CompanionTextService.unavailableMessage)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text(OnboardingCopy.companionDisclaimer)
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                SelahComposerBar(text: $input, isSending: isSending, onSend: send)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showPrivacy = true
                    } label: {
                        Image(systemName: "lock.shield")
                    }
                    .accessibilityLabel("How privacy works")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        confirmClear = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Clear this session")
                }
            }
            .confirmationDialog("Clear this session?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete conversation", role: .destructive) { messages = []; seedIntro(force: true) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The conversation is deleted from this device. It was never anywhere else.")
            }
            .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
            .sheet(isPresented: $showPrivacy) { PrivacyInfoView() }
        }
        .onAppear {
            AnalyticsService.track("talk_open", properties: [
                "fm_available": CompanionTextService.isOnDeviceCompanionAvailable
            ])
            if sessionId == nil { sessionId = env.startTalkSession() }
            applyPendingContext()
            if messages.isEmpty { seedIntro(force: false) }
        }
        .onDisappear {
            if !messages.isEmpty {
                AnalyticsService.track("session_complete", properties: ["mode": env.selectedTalkMode.rawValue])
            }
            env.clearTalkSessionsIfNeeded()
        }
    }

    private var privacyBanner: String {
        let extra = env.settings?.autoDeleteTalkSessions == true ? " · auto-deletes when you leave" : ""
        return "On-device only\(extra)"
    }

    private func applyPendingContext() {
        if let mood = env.pendingTalkMood {
            messages = [
                (role: "sys", text: env.selectedTalkMode.systemPrompt),
                (role: "assistant", text: "You said you feel \(mood.title.lowercased()). We can start there. No tidy words needed.")
            ]
            env.pendingTalkMood = nil
        } else if let verse = env.pendingTalkVerse {
            env.selectedTalkMode = .reflect
            messages = [
                (role: "sys", text: "Reflect · \(verse) · nothing leaves this phone"),
                (role: "assistant", text: "Let’s stay with \(verse). Read it once more. Which word will not let you go?")
            ]
            env.pendingTalkVerse = nil
        }
    }

    private func seedIntro(force: Bool) {
        if env.isDemoMode && messages.isEmpty && !force {
            let lines = DemoSeedData.talkPreviewLines
            if lines.count >= 3 {
                messages = [(role: "user", text: lines[1]), (role: "assistant", text: lines[2])]
                return
            }
        }
        if force || messages.isEmpty {
            messages = [
                (role: "sys", text: env.selectedTalkMode.systemPrompt),
                (role: "assistant", text: env.selectedTalkMode.openingLine)
            ]
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        if env.crisisMatcher.containsCrisisLanguage(text) {
            showCrisis = true
            AnalyticsService.track("crisis_sheet_shown")
            return
        }
        messages.append((role: "user", text: text))
        if let sessionId { env.appendTalkMessage(sessionId: sessionId, role: "user", content: text) }
        input = ""
        isSending = true
        Task {
            let reply = await CompanionTextService.talkReply(to: text, mode: env.selectedTalkMode.promptHint)
            messages.append((role: "assistant", text: reply))
            if let sessionId { env.appendTalkMessage(sessionId: sessionId, role: "assistant", content: reply) }
            isSending = false
        }
    }
}

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("You deserve real support right now.")
                        .font(SelahFont.display(.title3))
                }
                Section("Hotlines") {
                    Text("US: Call or text 988")
                    Text("Australia: Lifeline 13 11 14")
                    Text("UK & Ireland: Samaritans 116 123")
                    Text("Emergency: local emergency number")
                }
            }
            .navigationTitle("Crisis resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct PrivacyInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("How privacy works") {
                    Text("Talk, journal, and prayer stay on this iPhone. The companion uses Apple Intelligence on-device when available. Nothing is uploaded to Selah.")
                }
                Section {
                    Text(OnboardingCopy.companionDisclaimer)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
