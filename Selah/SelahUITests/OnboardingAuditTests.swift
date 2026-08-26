import XCTest

/// Walks every onboarding step and saves a screenshot per screen for the v4 audit.
final class OnboardingAuditTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private var outDir: URL {
        URL(fileURLWithPath: "/tmp/selah-audit")
    }

    func testCaptureEveryOnboardingScreen() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.skip"].waitForExistence(timeout: 20))
        snap(app, "01-welcome")

        continueButton(app).tap()
        snap(app, "02-hook")

        continueButton(app).tap()
        snap(app, "03-stat")

        continueButton(app).tap()
        snap(app, "04-quiz-distance")
        app.staticTexts["A busy life"].tap()
        snap(app, "04b-quiz-distance-selected")
        continueButton(app).tap()

        snap(app, "05-quiz-desire")
        app.staticTexts["Peace"].tap()
        continueButton(app).tap()

        snap(app, "06-quiz-habit")
        app.staticTexts["Sometimes"].tap()
        continueButton(app).tap()

        snap(app, "07-mirror")
        continueButton(app).tap() // mirror -> commitment

        // Commitment has two CTAs; primary is gold "Yes, I'm ready".
        if app.buttons["Yes, I’m ready"].waitForExistence(timeout: 3) {
            snap(app, "08-commitment")
            app.buttons["Yes, I’m ready"].tap()
        } else {
            snap(app, "08-commitment")
            continueButton(app).tap()
        }

        snap(app, "09-privacy")
        continueButton(app).tap()

        snap(app, "10-demo-mood")
        let mood = app.staticTexts["Heavy"]
        if !mood.exists {
            _ = app.staticTexts["Anxious"].waitForExistence(timeout: 3)
        }
        (mood.exists ? mood : app.staticTexts.element(boundBy: 2)).tap()
        continueButton(app).tap()

        // Demo result may generate (slow) — wait generously then shoot.
        _ = app.buttons["This is what I needed"].waitForExistence(timeout: 45)
        snap(app, "11-demo-result")
        continueButton(app).tap()

        // Building runs automatically.
        sleep(3)
        snap(app, "12-building")
        _ = app.buttons["Continue"].waitForExistence(timeout: 15)
        snap(app, "12b-building-done")
        continueButton(app).tap()

        snap(app, "13-plan-reveal")
        continueButton(app).tap()

        snap(app, "15-social")
    }

    private func continueButton(_ app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons["onboarding.continue"]
        if identified.waitForExistence(timeout: 5), identified.isEnabled { return identified }
        for label in ["Begin", "That’s true for me", "Continue", "I understand", "Pray with me", "This is what I needed", "Yes, I’m ready"] {
            let button = app.buttons[label]
            if button.exists, button.isEnabled { return button }
        }
        XCTFail("No continue button found")
        return identified
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let shot = XCUIScreen.main.screenshot()
        try? shot.pngRepresentation.write(to: outDir.appendingPathComponent("\(name).png"))
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
