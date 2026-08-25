import XCTest
@testable import Selah

final class SelahChromeLayoutTests: XCTestCase {
    func testSpacingTokensMatchV4() {
        XCTAssertEqual(SelahSpacing.md, 16)
        XCTAssertEqual(SelahSpacing.navbarInline, 16)
        XCTAssertEqual(SelahSpacing.navbarBottom, 8)
        XCTAssertEqual(SelahSpacing.pad, 22)
        XCTAssertEqual(SelahSpacing.lectio, 26)
        XCTAssertEqual(SelahSpacing.chatHorizontal, 18)
        XCTAssertEqual(SelahSpacing.chatTop, 6)
        XCTAssertEqual(SelahSpacing.chatBottom, 12)
        XCTAssertEqual(SelahSpacing.navbarMinHeight, 48)
    }

    func testTabChromeSlotsMatchV4() {
        XCTAssertEqual(SelahTabChrome.talk.left, .privacy)
        XCTAssertEqual(SelahTabChrome.talk.right, .clearSession)
        XCTAssertFalse(SelahTabChrome.talk.showsSettings)

        XCTAssertEqual(SelahTabChrome.pray.left, .closeToToday)
        XCTAssertEqual(SelahTabChrome.pray.right, .fiveMin)
        XCTAssertFalse(SelahTabChrome.pray.showsSettings)

        XCTAssertEqual(SelahTabChrome.journey.left, .empty)
        XCTAssertEqual(SelahTabChrome.journey.right, .settings)
        XCTAssertTrue(SelahTabChrome.journey.showsSettings)

        XCTAssertTrue(SelahTabChrome.today.hidesNavbar)
        XCTAssertTrue(SelahTabChrome.today.showsSettings)
        XCTAssertFalse(SelahTabChrome.talk.hidesNavbar)
    }
}
