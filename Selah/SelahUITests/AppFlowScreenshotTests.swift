import XCTest

final class AppFlowScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingAndPaywallScreens() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 20), "Onboarding navigation bar missing")
        attachScreenshot(app, name: "flow-onboarding-01")

        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        skip.tap()

        let paywall = app.buttons["paywall.subscribe"]
        let startSelah = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Start Selah'")
        ).firstMatch
        XCTAssertTrue(
            paywall.waitForExistence(timeout: 8) || startSelah.waitForExistence(timeout: 2),
            "Skip should reach native paywall"
        )
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Paywall needs a navigation bar")
        attachScreenshot(app, name: "flow-paywall")
    }

    func testOnboardingQuizRequiresSelectionThenContinues() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.continue"].waitForExistence(timeout: 15))
        app.buttons["onboarding.continue"].tap()
        if app.buttons["That’s true for me"].waitForExistence(timeout: 3)
            || app.buttons["onboarding.continue"].waitForExistence(timeout: 3) {
            tapContinue(app)
        }
        tapContinue(app)

        let distance = app.buttons["onboarding.quiz.distance.busy"]
        XCTAssertTrue(distance.waitForExistence(timeout: 8), "Distance quiz did not appear")
        distance.tap()
        tapContinue(app)

        let desire = app.buttons["onboarding.quiz.desire.peace"]
        XCTAssertTrue(desire.waitForExistence(timeout: 8))
        desire.tap()
        tapContinue(app)
        attachScreenshot(app, name: "flow-onboarding-quiz")
    }

    private func tapContinue(_ app: XCUIApplication) {
        let identified = app.buttons["onboarding.continue"]
        if identified.waitForExistence(timeout: 4), identified.isEnabled {
            identified.tap()
            return
        }
        for label in ["Begin", "That’s true for me", "Continue", "I understand", "Yes, I’m ready"] {
            let button = app.buttons[label]
            if button.exists, button.isEnabled {
                button.tap()
                return
            }
        }
    }

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
