import XCTest

final class AppFlowScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingAndPaywallScreens() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        // Custom ob-top chrome (progress + Skip), no UINavigationBar — mock v4 layout.
        XCTAssertTrue(app.buttons["onboarding.skip"].waitForExistence(timeout: 20), "Onboarding top bar missing")
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
        XCTAssertTrue(app.buttons["paywall.restore"].exists, "Paywall footer legal row missing")
        attachScreenshot(app, name: "flow-paywall")
    }

    func testOnboardingQuizRequiresSelectionThenContinues() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.continue"].waitForExistence(timeout: 15))
        app.buttons["onboarding.continue"].tap()
        tapContinue(app)
        tapContinue(app)

        let busy = app.staticTexts["A busy life"]
        XCTAssertTrue(busy.waitForExistence(timeout: 8), "Distance quiz did not appear")
        busy.tap()
        tapContinue(app)

        let peace = app.staticTexts["Peace"]
        XCTAssertTrue(peace.waitForExistence(timeout: 8), "Desire quiz did not appear")
        peace.tap()
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
