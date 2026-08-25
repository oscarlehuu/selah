import XCTest

final class TalkPrayCompanionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTalkHeartSuggestionAndPrayDraft() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: 8))

        let exhausted = app.buttons["I’m exhausted"]
        XCTAssertTrue(exhausted.waitForExistence(timeout: 5), "Heart suggestion missing")
        exhausted.tap()

        let preparing = app.activityIndicators["Selah is preparing"]
        _ = preparing.waitForExistence(timeout: 3)
        XCTAssertFalse(app.staticTexts["God is typing"].exists)

        let unavailable = app.staticTexts["talk.unavailable"]
        let scripture = app.staticTexts["talk.scripture"]
        let assistant = app.staticTexts["talk.message.assistant"]
        let appeared = unavailable.waitForExistence(timeout: 45)
            || scripture.waitForExistence(timeout: 2)
            || assistant.waitForExistence(timeout: 2)
        XCTAssertTrue(appeared, "Talk did not show a companion reply or honest unavailable state")
        XCTAssertFalse(app.staticTexts["God is typing"].exists)

        app.tabBars.buttons["Pray"].tap()
        let continueButton = app.buttons["pray.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 8))
        continueButton.tap()
        let word = app.textFields["pray.word"]
        if word.waitForExistence(timeout: 4) {
            word.tap()
            word.typeText("refuge")
        } else {
            let refuge = app.buttons["refuge"]
            if refuge.waitForExistence(timeout: 2) { refuge.tap() }
        }
        continueButton.tap()

        let silent = app.staticTexts["pray.silent"]
        let draft = app.staticTexts["pray.draft"]
        let generate = app.buttons["pray.generate"]
        XCTAssertTrue(
            silent.waitForExistence(timeout: 45) || draft.waitForExistence(timeout: 2) || generate.waitForExistence(timeout: 2),
            "Pray step should generate, offer generate, or show silent Lectio"
        )
        XCTAssertFalse(app.staticTexts["God is typing"].exists)

        let another = app.buttons["pray.another"]
        if another.waitForExistence(timeout: 2) {
            let before = draft.label
            another.tap()
            _ = draft.waitForExistence(timeout: 45)
            XCTAssertTrue(draft.exists)
            _ = before
        }

        if continueButton.waitForExistence(timeout: 2) {
            continueButton.tap()
        }
        let amen = app.buttons["pray.amen"]
        if amen.waitForExistence(timeout: 4) {
            amen.tap()
            XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
        }
    }
}
