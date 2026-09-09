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
        await generatedTurn(
            instructions: CompanionPrompts.talkInstructions(mode: mode),
            prompt: CompanionPrompts.talkUserPrompt(message: userMessage, history: history),
            parse: CompanionTurnParser.parseTalk
        )
    }

    static func reflection(for mood: String) async -> String {
        let turn = await reflectionTurn(for: mood)
        return turn.persistedText
    }

    static func reflectionTurn(for mood: String) async -> CompanionTurn {
        await generatedTurn(
            instructions: CompanionPrompts.reflectionInstructions(),
            prompt: CompanionPrompts.reflectionUserPrompt(mood: mood),
            parse: CompanionTurnParser.parseTalk
        )
    }

    static func prayerDraft(context: PrayerDraftContext) async -> CompanionTurn {
        await generatedTurn(
            instructions: CompanionPrompts.prayerInstructions(),
            prompt: CompanionPrompts.prayerUserPrompt(context: context),
            parse: CompanionTurnParser.parsePrayer
        )
    }

    private static func generatedTurn(
        instructions: String,
        prompt: String,
        parse: (String, CompanionTurn.Source) -> CompanionTurn
    ) async -> CompanionTurn {
        guard isOnDeviceCompanionAvailable else { return .unavailable(unavailableMessage) }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch await generate(instructions: instructions, prompt: prompt) {
            case .text(let raw):
                return parse(raw, .onDevice)
            case .failed(let detail):
                if isMissingModelAssets(detail) {
                    return .unavailable(unavailableMessage)
                }
                return .failed(failedMessage, detail: detail)
            }
        }
        #endif
        return .unavailable(unavailableMessage)
    }

    private static func isMissingModelAssets(_ detail: String) -> Bool {
        let lower = detail.lowercased()
        return lower.contains("model catalog")
            || lower.contains("no underlying assets")
            || lower.contains("modelmanagererror")
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static func generate(instructions: String, prompt: String) async -> GeneratedText {
        do {
            let session = LanguageModelSession(model: SystemLanguageModel.default)
            let response = try await session.respond(to: "\(instructions)\n\n\(prompt)")
            let content = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if content.isEmpty { return .failed("empty response") }
            return .text(content)
        } catch {
            return .failed(String(describing: error))
        }
    }

    private enum GeneratedText {
        case text(String)
        case failed(String)
    }
    #endif
}
