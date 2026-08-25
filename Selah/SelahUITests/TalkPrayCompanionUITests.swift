import XCTest

@MainActor
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
        XCTAssertFalse(app.staticTexts["God is typing"].waitForExistence(timeout: 1))

        let exhausted = app.buttons["I’m exhausted"]
        XCTAssertTrue(exhausted.waitForExistence(timeout: 5), "Heart suggestion missing")
        saveProof(app, name: "01-talk-heart-before-send")
        exhausted.tap()

        let failed = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "could not generate")
        ).firstMatch
        let unavailable = app.staticTexts["talk.unavailable"]
        let scripture = app.staticTexts["talk.scripture"]
        XCTAssertTrue(
            failed.waitForExistence(timeout: 45)
                || unavailable.waitForExistence(timeout: 2)
                || scripture.waitForExistence(timeout: 2),
            "Talk should show a generated reply, honest failure, or unavailable copy"
        )
        XCTAssertFalse(app.staticTexts["God is typing"].exists)
        saveProof(app, name: "02-talk-heart-after-send")

        app.tabBars.buttons["Pray"].tap()
        let continueButton = app.buttons["pray.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 8))
        continueButton.tap()
        if app.buttons["refuge"].waitForExistence(timeout: 4) {
            app.buttons["refuge"].tap()
        }
        continueButton.tap()

        let silent = app.staticTexts["pray.silent"]
        let draft = app.staticTexts["pray.draft"]
        let generate = app.buttons["pray.generate"]
        let prayFailed = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "could not generate")
        ).firstMatch
        XCTAssertTrue(
            silent.waitForExistence(timeout: 45)
                || draft.waitForExistence(timeout: 2)
                || generate.waitForExistence(timeout: 2)
                || prayFailed.waitForExistence(timeout: 2),
            "Pray step should generate, offer generate, fail honestly, or show silent Lectio"
        )

        let another = app.buttons["pray.another"]
        if another.waitForExistence(timeout: 2) {
            saveProof(app, name: "03-pray-draft")
            another.tap()
            XCTAssertTrue(draft.waitForExistence(timeout: 45) || prayFailed.waitForExistence(timeout: 2))
            saveProof(app, name: "04-pray-another")
        } else {
            saveProof(app, name: "03-pray-step")
        }

        if continueButton.waitForExistence(timeout: 2) {
            continueButton.tap()
        }
        let amen = app.buttons["pray.amen"]
        if amen.waitForExistence(timeout: 4) {
            amen.tap()
            XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
            saveProof(app, name: "05-amen-today")
        }
    }

    private func saveProof(_ app: XCUIApplication, name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let folder = URL(fileURLWithPath: "/Users/a1241968/Desktop/Oscar/Bible/plans/reports/selah-talk-pray-live-sim-proof")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? shot.pngRepresentation.write(to: folder.appendingPathComponent("\(name).png"))
    }
}
