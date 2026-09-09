import XCTest
@testable import Selah

final class AnalyticsPrivacyTests: XCTestCase {
    func testSensitiveAndUnknownEventsAreDropped() {
        for event in ["mood_quick", "crisis_sheet_shown", "mode_release", "session_complete", "$screen", "unknown"] {
            XCTAssertNil(AnalyticsService.sanitizedProperties(for: event, properties: ["mood": "anxious"]))
        }
    }

    func testFunnelEventsCannotCarrySensitiveContext() throws {
        for event in AnalyticsService.allowedEvents {
            let properties = try XCTUnwrap(AnalyticsService.sanitizedProperties(for: event, properties: [
                "mood": "anxious", "quiz_distance_branch": "guilt", "plan_theme": "peace",
                "text": "private prayer", "tier": "private content", "$screen_name": "journal"
            ]))
            XCTAssertEqual(Set(properties.keys), ["is_demo", "$geoip_disable"])
        }
        XCTAssertEqual(AnalyticsService.sanitizedProperties(for: "subscribe", properties: ["tier": "yearly"])?["tier"] as? String, "yearly")
    }
}

@MainActor
final class OnDeviceCompanionIntegrationTests: XCTestCase {
    func testRealSystemModelResponds() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Run this integration check on a compatible physical iPhone.")
        #else
        guard CompanionTextService.isOnDeviceCompanionAvailable else {
            return XCTFail("Apple Intelligence is unavailable on the physical test device.")
        }
        let turn = await CompanionTextService.talkReply(to: "Help me reflect on gratitude for a peaceful morning.", mode: .reflect)
        XCTAssertEqual(turn.source, .onDevice)
        XCTAssertFalse(turn.persistedText.isEmpty)
        print("SELAH_ON_DEVICE_PROOF: \(turn.persistedText)")
        #endif
    }
}
