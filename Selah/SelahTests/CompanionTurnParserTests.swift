import XCTest
@testable import Selah

final class CompanionTurnParserTests: XCTestCase {
    func testParsesLabeledTalkReplyAndScripture() {
        let raw = """
        REPLY: You can bring the tiredness to God without cleaning it up first.
        SCRIPTURE: Matthew 11:28
        SCRIPTURE_TEXT: Come unto me, all ye that labour and are heavy laden.
        FOLLOWUPS: I’m tired of pretending | I need rest
        """
        let turn = CompanionTurnParser.parseTalk(raw, source: .onDevice)
        XCTAssertEqual(turn.source, .onDevice)
        XCTAssertTrue(turn.reply.contains("tiredness"))
        XCTAssertEqual(turn.scriptureReference, "Matthew 11:28")
        XCTAssertTrue(turn.scriptureText?.contains("Come unto me") == true)
        XCTAssertEqual(turn.followUps, ["I’m tired of pretending", "I need rest"])
        XCTAssertFalse(turn.reply.lowercased().contains("god is typing"))
    }

    func testUnlabeledTalkTextStillBecomesAReply() {
        let turn = CompanionTurnParser.parseTalk(
            "Name it as it is. Psalm 62:8 is a place to start.",
            source: .onDevice
        )
        XCTAssertEqual(turn.source, .onDevice)
        XCTAssertTrue(turn.reply.contains("Name it as it is"))
        XCTAssertTrue(turn.followUps.isEmpty)
    }

    func testParsesPrayerBlock() {
        let raw = """
        PRAYER:
        God, I am tired.
        Be my refuge today.
        SCRIPTURE: Psalm 46:1
        """
        let turn = CompanionTurnParser.parsePrayer(raw, source: .onDevice)
        XCTAssertTrue(turn.reply.contains("God, I am tired"))
        XCTAssertTrue(turn.reply.contains("refuge"))
        XCTAssertFalse(turn.reply.contains("PRAYER:"))
        XCTAssertEqual(turn.scriptureReference, "Psalm 46:1")
    }

    func testUnavailableAndFailedTurnsAreNotScriptedPrayers() {
        let unavailable = CompanionTurn.unavailable(CompanionTextService.unavailableMessage)
        XCTAssertEqual(unavailable.source, .unavailable)
        XCTAssertFalse(unavailable.reply.lowercased().contains("heavenly father"))

        let failed = CompanionTurn.failed(CompanionTextService.failedMessage)
        XCTAssertEqual(failed.source, .failed)
        XCTAssertFalse(failed.reply.lowercased().contains("heavenly father"))
        XCTAssertFalse(failed.reply.lowercased().contains("amen"))
    }
}
