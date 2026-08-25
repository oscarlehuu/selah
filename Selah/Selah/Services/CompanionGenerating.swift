import Foundation

protocol CompanionGenerating: AnyObject, Sendable {
    var isAvailable: Bool { get }
    func talkReply(to userMessage: String, mode: TalkMode, history: [TalkLine]) async -> CompanionTurn
    func prayerDraft(context: PrayerDraftContext) async -> CompanionTurn
}

final class OnDeviceCompanion: CompanionGenerating, @unchecked Sendable {
    var isAvailable: Bool { CompanionTextService.isOnDeviceCompanionAvailable }

    func talkReply(to userMessage: String, mode: TalkMode, history: [TalkLine]) async -> CompanionTurn {
        await CompanionTextService.talkReply(to: userMessage, mode: mode, history: history)
    }

    func prayerDraft(context: PrayerDraftContext) async -> CompanionTurn {
        await CompanionTextService.prayerDraft(context: context)
    }
}
