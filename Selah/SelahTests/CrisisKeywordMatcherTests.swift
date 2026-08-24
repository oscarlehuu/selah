import XCTest
@testable import Selah

final class CrisisKeywordMatcherTests: XCTestCase {
    private let matcher = CrisisKeywordMatcher(keywords: [
        "suicide", "kill myself", "end my life", "self-harm", "want to die"
    ])

    func testDetectsCrisisPhrase() {
        XCTAssertTrue(matcher.containsCrisisLanguage("I want to die tonight"))
        XCTAssertTrue(matcher.containsCrisisLanguage("Thinking about suicide"))
        XCTAssertTrue(matcher.containsCrisisLanguage("I might kill myself"))
    }

    func testIgnoresOrdinaryGriefLanguage() {
        XCTAssertFalse(matcher.containsCrisisLanguage("I feel distant from God"))
        XCTAssertFalse(matcher.containsCrisisLanguage("I missed my reading yesterday"))
        XCTAssertFalse(matcher.containsCrisisLanguage(""))
    }

    func testIsCaseInsensitive() {
        XCTAssertTrue(matcher.containsCrisisLanguage("SUICIDE"))
        XCTAssertTrue(matcher.containsCrisisLanguage("Self-Harm"))
    }
}
