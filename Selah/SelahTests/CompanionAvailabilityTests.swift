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

    func testTalkReplyDoesNotInventCloudFallbackWhenUnavailable() async {
        guard !CompanionAvailability.isOnDeviceCompanionAvailable else {
            throw XCTSkip("On-device model is available on this simulator")
        }
        let reply = await CompanionTextService.talkReply(to: "I feel far from God", mode: "Heart")
        XCTAssertEqual(reply, CompanionTextService.unavailableMessage)
    }
}
