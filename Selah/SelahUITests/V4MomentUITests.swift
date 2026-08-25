import XCTest

final class V4MomentUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWelcomeIsFullBleedSanctuaryNotCardStack() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(
            app.otherElements["onboarding.welcome.sanctuary"].waitForExistence(timeout: 15),
            "Welcome must be a full-bleed sanctuary, not grouped white cards"
        )
        XCTAssertTrue(app.staticTexts["Selah"].exists)
        XCTAssertTrue(app.staticTexts["Pause · Reflect · Listen"].exists)
        XCTAssertTrue(app.staticTexts["Psalm 46:10 · KJV"].exists)
        XCTAssertTrue(
            app.buttons["onboarding.continue"].waitForExistence(timeout: 3)
                || app.buttons["Begin"].exists,
            "Gold Begin CTA missing"
        )
        XCTAssertFalse(app.webViews.firstMatch.exists)
    }

    func testTalkPrayJourneyCompactChrome() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))

        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Talk"].exists)
        XCTAssertTrue(app.buttons["talk.privacy"].exists)
        XCTAssertTrue(app.buttons["talk.clear"].exists)
        XCTAssertFalse(app.buttons["selah.settings.open"].exists)

        app.tabBars.buttons["Pray"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Pray"].exists)
        XCTAssertTrue(app.buttons["pray.close"].exists)
        XCTAssertTrue(app.staticTexts["Read it slowly"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["selah.settings.open"].exists)

        app.tabBars.buttons["Journey"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Journey"].exists)
        XCTAssertTrue(app.buttons["selah.settings.open"].exists)
    }

    func testJourneyShowsWeekPathGraceStatsAndPlan() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        app.tabBars.buttons["Journey"].tap()

        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Days with God"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.otherElements["journey.weekPath"].waitForExistence(timeout: 5),
            "Journey needs a native week path, not only a flat list"
        )
        XCTAssertTrue(app.buttons["journey.grace"].waitForExistence(timeout: 3) || app.staticTexts["Use a grace day"].exists)
        XCTAssertTrue(app.otherElements["journey.stats"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Longest streak"].exists)
        XCTAssertTrue(app.staticTexts["Minutes in prayer"].exists)
        XCTAssertTrue(app.staticTexts["Chapters read"].exists)
        XCTAssertTrue(app.staticTexts["Your 7-day plan"].exists)
        XCTAssertTrue(app.staticTexts["Journal"].exists)
        XCTAssertFalse(app.webViews.firstMatch.exists)
    }
}
