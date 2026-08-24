import SwiftUI

struct TalkView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var input = ""
    @State private var messages: [(role: String, text: String)] = []
    @State private var isSending = false
    @State private var showCrisis = false
    @State private var sessionId: UUID?
    @State private var mode: TalkMode = .heart

    var body: some View {
        SelahTabScreen("Talk") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    modePicker
                    disclaimer
                    if messages.isEmpty { emptyState }
                    else {
                        ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                            bubble(message)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .selahTabScrollContent()
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SelahComposerBar(text: $input, isSending: isSending, onSend: send)
            }
        }
        .onAppear {
            AnalyticsService.track("talk_open", properties: [
                "fm_available": CompanionTextService.isOnDeviceCompanionAvailable
            ])
            if sessionId == nil { sessionId = env.startTalkSession() }
            if messages.isEmpty {
                if env.isDemoMode { seedDemo() }
                else if let sessionId { messages = env.talkMessages(for: sessionId) }
            }
        }
        .onDisappear {
            if !messages.isEmpty {
                AnalyticsService.track("session_complete", properties: ["mode": mode.rawValue])
            }
            env.clearTalkSessionsIfNeeded()
        }
        .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(TalkMode.allCases, id: \.self) { item in
                Button {
                    mode = item
                } label: {
                    Text(item.title)
                        .font(SelahFont.figtree(13, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(mode == item ? SelahColors.primaryDeep : SelahColors.surface)
                        .foregroundStyle(mode == item ? Color.white : SelahColors.textMuted)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lock.fill").foregroundStyle(SelahColors.primaryDeep)
            Text("Selah is not God, a priest, or crisis care. Private on your phone.")
                .font(SelahFont.figtree(13))
                .foregroundStyle(SelahColors.textMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SelahColors.primarySoft.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mode.emptyTitle)
                .font(SelahFont.newsreader(24, weight: .semibold))
            Text(mode.emptyBody)
                .font(SelahFont.figtree(16))
                .foregroundStyle(SelahColors.textMuted)
            if !CompanionTextService.isOnDeviceCompanionAvailable {
                Text(CompanionTextService.unavailableMessage)
                    .font(SelahFont.figtree(14))
                    .foregroundStyle(SelahColors.textSoft)
            }
        }
        .padding(.top, 12)
    }

    private func bubble(_ message: (role: String, text: String)) -> some View {
        let isUser = message.role == "user"
        return Text(message.text)
            .font(SelahFont.figtree(15))
            .foregroundStyle(SelahColors.text)
            .padding(14)
            .background(isUser ? SelahColors.primarySoft : SelahColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private func seedDemo() {
        let lines = DemoSeedData.talkPreviewLines
        guard lines.count >= 3 else { return }
        messages = [(role: "user", text: lines[1]), (role: "assistant", text: lines[2])]
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
            let reply = await CompanionTextService.talkReply(to: text, mode: mode.promptHint)
            messages.append((role: "assistant", text: reply))
            if let sessionId { env.appendTalkMessage(sessionId: sessionId, role: "assistant", content: reply) }
            isSending = false
        }
    }
}

private enum TalkMode: String, CaseIterable {
    case heart, reflect, release
    var title: String {
        switch self {
        case .heart: "Heart"
        case .reflect: "Reflect"
        case .release: "Release"
        }
    }
    var emptyTitle: String {
        switch self {
        case .heart: "Share what's on your heart"
        case .reflect: "Reflect with God"
        case .release: "Release what's heavy"
        }
    }
    var emptyBody: String {
        switch self {
        case .heart: "Gratitude, longing, or joy — speak freely. Nothing leaves this device."
        case .reflect: "Wonder aloud about Scripture or what God might be saying."
        case .release: "Confess or let go of shame here. Selah is a private room, not a person."
        }
    }
    var promptHint: String {
        switch self {
        case .heart: "Respond warmly to what the user shared from the heart."
        case .reflect: "Help the user reflect on Scripture and God's presence."
        case .release: "Respond with grace as the user releases guilt or heaviness."
        }
    }
}

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("You deserve real support right now.")
                        .font(SelahFont.newsreader(22, weight: .semibold))
                    Text("US: Call or text 988")
                    Text("Australia: Lifeline 13 11 14")
                    Text("UK & Ireland: Samaritans 116 123")
                    Text("Emergency: local emergency number")
                }
                .font(SelahFont.figtree(16))
                .padding(24)
            }
            .background(SundayLightBackground())
            .navigationTitle("Crisis resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
