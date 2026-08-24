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

    static func talkReply(to userMessage: String, mode: String) async -> String {
        guard isOnDeviceCompanionAvailable else { return unavailableMessage }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generate(
                prompt: """
                Private on-device Christian companion. Mode: \(mode).
                User said: "\(userMessage)"
                Reply in 2-4 sentences with empathy and one Scripture reference.
                You are not God, a pastor, priest, or therapist.
                """
            )
        }
        #endif
        return unavailableMessage
    }

    static func reflection(for mood: String) async -> String {
        guard isOnDeviceCompanionAvailable else { return unavailableMessage }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generate(
                prompt: """
                Write a short prayer reflection (3-4 sentences) for someone feeling \(mood).
                Warm, grace-filled. Include one KJV-style reference. Not a pastor. Not God.
                """
            )
        }
        #endif
        return unavailableMessage
    }

    static func prayerDraft(context: String) async -> String {
        guard isOnDeviceCompanionAvailable else { return unavailableMessage }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generate(
                prompt: "Write a personal prayer (4-6 lines) for: \(context). Address God directly. Grace tone."
            )
        }
        #endif
        return unavailableMessage
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static func generate(prompt: String) async -> String {
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Selah could not generate a response right now. You are still heard by God."
        }
    }
    #endif
}
