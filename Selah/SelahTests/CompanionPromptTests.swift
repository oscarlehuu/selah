import XCTest
@testable import Selah

final class CompanionPromptTests: XCTestCase {
    func testTalkModesAreHeartReflectRelease() {
        XCTAssertEqual(TalkMode.allCases.map(\.title), ["Heart", "Reflect", "Release"])
        XCTAssertFalse(TalkMode.heart.suggestions.isEmpty)
        XCTAssertEqual(TalkMode.heart.suggestions.first, "I’m exhausted")
    }

    func testTalkInstructionsCarryGuardrailsAndDistinctModes() {
        let heart = CompanionPrompts.talkInstructions(mode: .heart).lowercased()
        let reflect = CompanionPrompts.talkInstructions(mode: .reflect).lowercased()
        let release = CompanionPrompts.talkInstructions(mode: .release).lowercased()

        for text in [heart, reflect, release] {
            XCTAssertTrue(text.contains("not god"))
            XCTAssertTrue(text.contains("pastor"))
            XCTAssertTrue(text.contains("priest"))
            XCTAssertTrue(text.contains("therapist"))
            XCTAssertFalse(text.contains("god is typing"))
            XCTAssertFalse(text.contains("you are god"))
            XCTAssertFalse(text.contains("i forgive you"))
        }

        XCTAssertTrue(heart.contains("heart"))
        XCTAssertTrue(heart.contains("listen"))
        XCTAssertTrue(reflect.contains("scripture"))
        XCTAssertTrue(reflect.contains("one question"))
        XCTAssertTrue(release.contains("grace"))
        XCTAssertTrue(release.contains("absolution"))
        XCTAssertNotEqual(heart, reflect)
        XCTAssertNotEqual(reflect, release)
    }

    func testTalkUserPromptIncludesHistoryAndLabeledShape() {
        let history = [
            TalkLine(role: .user, text: "I feel far from God"),
            TalkLine(role: .assistant, text: "Stay with that. What does far feel like tonight?")
        ]
        let prompt = CompanionPrompts.talkUserPrompt(
            message: "I’m exhausted",
            history: history
        )
        XCTAssertTrue(prompt.contains("I feel far from God"))
        XCTAssertTrue(prompt.contains("I’m exhausted"))
        XCTAssertTrue(prompt.contains("REPLY:"))
        XCTAssertTrue(prompt.contains("SCRIPTURE:"))
        XCTAssertTrue(prompt.contains("FOLLOWUPS:"))
    }

    func testPrayerPromptUsesMoodVerseAndWordAndIsADraftForTheUser() {
        let context = PrayerDraftContext(
            reflectionWord: "refuge",
            verse: "Psalm 46:1",
            mood: "heavy"
        )
        XCTAssertTrue(context.summary.contains("refuge"))
        XCTAssertTrue(context.summary.contains("Psalm 46:1"))
        XCTAssertTrue(context.summary.contains("heavy"))

        let prompt = CompanionPrompts.prayerUserPrompt(context: context).lowercased()
        XCTAssertTrue(prompt.contains("refuge"))
        XCTAssertTrue(prompt.contains("psalm 46:1"))
        XCTAssertTrue(prompt.contains("heavy"))
        XCTAssertTrue(prompt.contains("first person"))
        XCTAssertTrue(prompt.contains("prayer"))
        XCTAssertFalse(prompt.contains("you are god"))
        XCTAssertFalse(prompt.contains("speak as god"))

        let instructions = CompanionPrompts.prayerInstructions().lowercased()
        XCTAssertTrue(instructions.contains("not god"))
        XCTAssertTrue(instructions.contains("pastor"))
        XCTAssertFalse(instructions.contains("god is typing"))
        XCTAssertTrue(instructions.contains("my child") == false || instructions.contains("do not"))
    }

    func testSilentPrayCopyIsNotAFakePrayer() {
        let silent = CompanionTextService.silentPrayMessage.lowercased()
        XCTAssertFalse(silent.contains("heavenly father"))
        XCTAssertFalse(silent.contains("amen"))
        XCTAssertTrue(silent.contains("apple intelligence") || silent.contains("quiet"))
    }

    func testOpeningLinesAreCompanionNotGodPersona() {
        for mode in TalkMode.allCases {
            XCTAssertFalse(mode.openingLine.lowercased().contains("god is typing"))
            XCTAssertFalse(mode.openingLine.lowercased().contains("this is the lord"))
        }
    }
}
