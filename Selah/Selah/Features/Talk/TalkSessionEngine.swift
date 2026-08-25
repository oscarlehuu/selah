import Foundation
import Observation

enum TalkSendResult: Equatable {
    case empty
    case crisis
    case replied(user: TalkLine, assistant: TalkLine)
}

@Observable
@MainActor
final class TalkSessionEngine {
    var lines: [TalkLine] = []
    var followUps: [String] = []
    var isSending = false
    var mode: TalkMode = .heart

    private let companion: any CompanionGenerating
    private let crisisMatcher: CrisisKeywordMatcher

    init(
        companion: any CompanionGenerating = OnDeviceCompanion(),
        crisisMatcher: CrisisKeywordMatcher = CrisisKeywordMatcher()
    ) {
        self.companion = companion
        self.crisisMatcher = crisisMatcher
    }

    var chips: [String] {
        if !followUps.isEmpty { return followUps }
        let userCount = lines.filter { $0.role == .user }.count
        return userCount < 2 ? mode.suggestions : []
    }

    func seedIntro() {
        lines = [
            TalkLine(role: .sys, text: mode.systemPrompt),
            TalkLine(role: .assistant, text: mode.openingLine)
        ]
        followUps = []
    }

    func seedPreview(_ preview: [String]) {
        guard preview.count >= 3 else {
            seedIntro()
            return
        }
        lines = [
            TalkLine(role: .user, text: preview[1]),
            TalkLine(role: .assistant, text: preview[2])
        ]
        followUps = []
    }

    func seedMood(_ title: String) {
        lines = [
            TalkLine(role: .sys, text: mode.systemPrompt),
            TalkLine(role: .assistant, text: "You said you feel \(title.lowercased()). We can start there. No tidy words needed.")
        ]
        followUps = []
    }

    func seedVerse(_ verse: String) {
        mode = .reflect
        lines = [
            TalkLine(role: .sys, text: "Reflect · \(verse) · nothing leaves this phone"),
            TalkLine(role: .assistant, text: "Let’s stay with \(verse). Read it once more. Which word will not let you go?")
        ]
        followUps = []
    }

    func send(_ raw: String) async -> TalkSendResult {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return .empty }
        if crisisMatcher.containsCrisisLanguage(text) { return .crisis }

        let user = TalkLine(role: .user, text: text)
        let history = lines
        let mode = self.mode
        let companion = self.companion
        lines.append(user)
        isSending = true
        let turn = await companion.talkReply(to: text, mode: mode, history: history)
        isSending = false
        let assistant = TalkLine(
            role: .assistant,
            text: turn.reply,
            scriptureReference: turn.scriptureReference,
            scriptureText: turn.scriptureText
        )
        lines.append(assistant)
        followUps = turn.followUps
        return .replied(user: user, assistant: assistant)
    }
}
