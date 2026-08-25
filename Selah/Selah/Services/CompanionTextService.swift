import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum CompanionAvailability {
    static var isOnDeviceCompanionAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        #endif
        return false
    }
}

enum CompanionTextService {
    static var isOnDeviceCompanionAvailable: Bool {
        CompanionAvailability.isOnDeviceCompanionAvailable
    }

    static let unavailableMessage = """
    Apple Intelligence is not available on this phone yet. Selah still keeps your reading, Bible, and private journal here — nothing is sent to a cloud companion.
    """

    static let silentPrayMessage = """
    Pray in the quiet. There is no generated draft on this iPhone — that needs Apple Intelligence. Speak to God in your own words, or rest here.
    """

    static let failedMessage = "Selah could not generate a response right now. You are still heard by God."

    static func talkReply(
        to userMessage: String,
        mode: TalkMode,
        history: [TalkLine] = []
    ) async -> CompanionTurn {
        guard isOnDeviceCompanionAvailable else { return .unavailable(unavailableMessage) }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let raw = await generate(
                instructions: CompanionPrompts.talkInstructions(mode: mode),
                prompt: CompanionPrompts.talkUserPrompt(message: userMessage, history: history)
            )
            guard let raw else { return .failed(failedMessage) }
            return CompanionTurnParser.parseTalk(raw, source: .onDevice)
        }
        #endif
        return .unavailable(unavailableMessage)
    }

    static func reflection(for mood: String) async -> String {
        let turn = await reflectionTurn(for: mood)
        return turn.persistedText
    }

    static func reflectionTurn(for mood: String) async -> CompanionTurn {
        guard isOnDeviceCompanionAvailable else { return .unavailable(unavailableMessage) }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let raw = await generate(
                instructions: CompanionPrompts.reflectionInstructions(),
                prompt: CompanionPrompts.reflectionUserPrompt(mood: mood)
            )
            guard let raw else { return .failed(failedMessage) }
            return CompanionTurnParser.parseTalk(raw, source: .onDevice)
        }
        #endif
        return .unavailable(unavailableMessage)
    }

    static func prayerDraft(context: PrayerDraftContext) async -> CompanionTurn {
        guard isOnDeviceCompanionAvailable else { return .unavailable(unavailableMessage) }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let raw = await generate(
                instructions: CompanionPrompts.prayerInstructions(),
                prompt: CompanionPrompts.prayerUserPrompt(context: context)
            )
            guard let raw else { return .failed(failedMessage) }
            return CompanionTurnParser.parsePrayer(raw, source: .onDevice)
        }
        #endif
        return .unavailable(unavailableMessage)
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static func generate(instructions: String, prompt: String) async -> String? {
        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: prompt)
            let content = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return content.isEmpty ? nil : content
        } catch {
            return nil
        }
    }
    #endif
}
