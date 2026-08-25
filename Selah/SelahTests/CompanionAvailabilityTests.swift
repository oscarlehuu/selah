import XCTest
@testable import Selah

final class CompanionAvailabilityTests: XCTestCase {
    func testUnavailableMessageIsNotAScriptedPrayer() {
        let message = CompanionTextService.unavailableMessage
        XCTAssertFalse(message.lowercased().contains("heavenly father"))
        XCTAssertFalse(message.lowercased().contains("amen"))
        XCTAssertTrue(message.localizedCaseInsensitiveContains("on this phone")
                      || message.localizedCaseInsensitiveContains("apple intelligence")
                      || message.localizedCaseInsensitiveContains("not available"))
    }

    func testTalkReplyDoesNotInventCloudFallbackWhenUnavailable() async throws {
        guard !CompanionAvailability.isOnDeviceCompanionAvailable else {
            throw XCTSkip("On-device model is available on this simulator")
        }
        let reply = await CompanionTextService.talkReply(to: "I feel far from God", mode: .heart)
        XCTAssertEqual(reply.source, .unavailable)
        XCTAssertEqual(reply.reply, CompanionTextService.unavailableMessage)
    }

    func testPrayerDraftDoesNotInventFallbackWhenUnavailable() async throws {
        guard !CompanionAvailability.isOnDeviceCompanionAvailable else {
            throw XCTSkip("On-device model is available on this simulator")
        }
        let turn = await CompanionTextService.prayerDraft(
            context: PrayerDraftContext(reflectionWord: "refuge", verse: "Psalm 46:1", mood: "heavy")
        )
        XCTAssertEqual(turn.source, .unavailable)
        XCTAssertFalse(turn.reply.lowercased().contains("heavenly father"))
    }

    func testLiveHeartReplyWhenModelAvailable() async throws {
        guard CompanionAvailability.isOnDeviceCompanionAvailable else {
            throw XCTSkip("Foundation Models unavailable on this simulator")
        }
        let turn = await CompanionTextService.talkReply(to: "I’m exhausted", mode: .heart)
        XCTAssertEqual(
            turn.source,
            .onDevice,
            turn.generationDetail ?? turn.reply
        )
        XCTAssertFalse(turn.reply.isEmpty)
        XCTAssertNotEqual(turn.reply, CompanionTextService.unavailableMessage)
        XCTAssertFalse(turn.reply.lowercased().contains("god is typing"))
        XCTAssertFalse(turn.reply.lowercased().contains("as your pastor"))
    }

    func testLivePrayerDraftWhenModelAvailable() async throws {
        guard CompanionAvailability.isOnDeviceCompanionAvailable else {
            throw XCTSkip("Foundation Models unavailable on this simulator")
        }
        let turn = await CompanionTextService.prayerDraft(
            context: PrayerDraftContext(reflectionWord: "refuge", verse: "Psalm 46:1", mood: "heavy")
        )
        XCTAssertEqual(
            turn.source,
            .onDevice,
            turn.generationDetail ?? turn.reply
        )
        XCTAssertFalse(turn.reply.isEmpty)
        XCTAssertNotEqual(turn.reply, CompanionTextService.unavailableMessage)
        XCTAssertFalse(turn.reply.lowercased().contains("god is typing"))
    }
}
