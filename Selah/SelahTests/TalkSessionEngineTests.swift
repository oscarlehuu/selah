import XCTest
@testable import Selah

@MainActor
final class TalkSessionEngineTests: XCTestCase {
    func testHeartSendAppendsUserAndCompanionTurn() async {
        let stub = StubCompanion(
            talkTurns: [
                CompanionTurn(
                    source: .onDevice,
                    reply: "Bring the exhaustion to God as it is.",
                    scriptureReference: "Matthew 11:28",
                    scriptureText: "Come unto me, all ye that labour.",
                    followUps: ["I cannot keep this pace"]
                )
            ]
        )
        let engine = TalkSessionEngine(
            companion: stub,
            crisisMatcher: CrisisKeywordMatcher(keywords: ["suicide"])
        )
        engine.mode = .heart
        engine.seedIntro()

        let result = await engine.send("I’m exhausted")
        guard case .replied(let user, let assistant) = result else {
            return XCTFail("expected a companion reply")
        }
        XCTAssertEqual(user.text, "I’m exhausted")
        XCTAssertEqual(assistant.text, "Bring the exhaustion to God as it is.")
        XCTAssertEqual(assistant.scriptureReference, "Matthew 11:28")
        XCTAssertEqual(stub.talkCallCount, 1)
        XCTAssertEqual(stub.lastMode, .heart)
        XCTAssertEqual(engine.followUps, ["I cannot keep this pace"])
        XCTAssertEqual(engine.lines.filter { $0.role == .user }.count, 1)
        XCTAssertFalse(assistant.text.lowercased().contains("god is typing"))
        XCTAssertFalse(assistant.text.lowercased().contains("heavenly father"))
    }

    func testCrisisLanguageDoesNotCallCompanion() async {
        let stub = StubCompanion(talkTurns: [
            CompanionTurn(source: .onDevice, reply: "should not appear", scriptureReference: nil, scriptureText: nil, followUps: [])
        ])
        let engine = TalkSessionEngine(
            companion: stub,
            crisisMatcher: CrisisKeywordMatcher(keywords: ["suicide"])
        )
        engine.seedIntro()
        let result = await engine.send("I am thinking about suicide")
        XCTAssertEqual(result, .crisis)
        XCTAssertEqual(stub.talkCallCount, 0)
        XCTAssertTrue(engine.lines.filter { $0.role == .user }.isEmpty)
    }

    func testSuggestionsStayAvailableBeforeARealTurn() {
        let engine = TalkSessionEngine(companion: StubCompanion(talkTurns: []))
        engine.mode = .heart
        engine.seedIntro()
        XCTAssertEqual(engine.chips, TalkMode.heart.suggestions)
    }
}

@MainActor
final class LectioPrayEngineTests: XCTestCase {
    func testDraftUsesContextAndAnotherPrayerCallsAgain() async {
        let stub = StubCompanion(prayerTurns: [
            CompanionTurn(source: .onDevice, reply: "God, be my refuge.", scriptureReference: "Psalm 46:1", scriptureText: nil, followUps: []),
            CompanionTurn(source: .onDevice, reply: "God, I hide in you today.", scriptureReference: "Psalm 46:1", scriptureText: nil, followUps: [])
        ])
        let engine = LectioPrayEngine(companion: stub)
        let context = PrayerDraftContext(reflectionWord: "refuge", verse: "Psalm 46:1", mood: "heavy")
        let first = await engine.draft(context)
        let second = await engine.anotherPrayer()
        XCTAssertEqual(first.reply, "God, be my refuge.")
        XCTAssertEqual(second?.reply, "God, I hide in you today.")
        XCTAssertEqual(stub.prayerCallCount, 2)
        XCTAssertEqual(stub.lastPrayerContext?.reflectionWord, "refuge")
        XCTAssertEqual(stub.lastPrayerContext?.verse, "Psalm 46:1")
        XCTAssertEqual(stub.lastPrayerContext?.mood, "heavy")
        XCTAssertNotEqual(first.reply, second?.reply)
    }

    func testUnavailableCompanionDoesNotInventAPrayer() async {
        let stub = StubCompanion(isAvailable: false)
        let engine = LectioPrayEngine(companion: stub)
        let turn = await engine.draft(
            PrayerDraftContext(reflectionWord: "refuge", verse: "Psalm 46:1", mood: nil)
        )
        XCTAssertEqual(turn.source, .unavailable)
        XCTAssertEqual(stub.prayerCallCount, 0)
        XCTAssertFalse(turn.reply.lowercased().contains("heavenly father"))
    }
}

final class StubCompanion: CompanionGenerating, @unchecked Sendable {
    var isAvailable: Bool
    var talkTurns: [CompanionTurn]
    var prayerTurns: [CompanionTurn]
    private(set) var talkCallCount = 0
    private(set) var prayerCallCount = 0
    private(set) var lastMode: TalkMode?
    private(set) var lastPrayerContext: PrayerDraftContext?

    init(
        isAvailable: Bool = true,
        talkTurns: [CompanionTurn] = [],
        prayerTurns: [CompanionTurn] = []
    ) {
        self.isAvailable = isAvailable
        self.talkTurns = talkTurns
        self.prayerTurns = prayerTurns
    }

    func talkReply(to userMessage: String, mode: TalkMode, history: [TalkLine]) async -> CompanionTurn {
        talkCallCount += 1
        lastMode = mode
        _ = userMessage
        _ = history
        guard !talkTurns.isEmpty else {
            return .unavailable(CompanionTextService.unavailableMessage)
        }
        return talkTurns[(talkCallCount - 1) % talkTurns.count]
    }

    func prayerDraft(context: PrayerDraftContext) async -> CompanionTurn {
        prayerCallCount += 1
        lastPrayerContext = context
        guard !prayerTurns.isEmpty else {
            return .unavailable(CompanionTextService.unavailableMessage)
        }
        return prayerTurns[(prayerCallCount - 1) % prayerTurns.count]
    }
}
