import XCTest

final class AppFlowScreenshotTests: XCTestCase {
    private let primaryCTAs = [
        "Yes, I'm ready",
        "Generate reflection",
        "Continue to Selah",
        "Continue"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingAndPaywallScreens() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(waitForPrimaryCTA(app, timeout: 20), "Onboarding did not appear")
        attachScreenshot(app, name: "flow-onboarding-01")

        for step in 2...15 {
            tapPrimaryCTA(app)
            if step == 2 || step == 8 || step == 13 {
                attachScreenshot(app, name: "flow-onboarding-\(String(format: "%02d", step))")
            }
            if !waitForPrimaryCTA(app, timeout: 4) {
                break
            }
        }

        tapPrimaryCTA(app)

        let paywall = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Start Selah'")
        ).firstMatch
        let notifications = app.buttons["Allow notifications"]

        if paywall.waitForExistence(timeout: 8) {
            attachScreenshot(app, name: "flow-paywall")
        } else if notifications.waitForExistence(timeout: 3) {
            attachScreenshot(app, name: "flow-notifications")
        } else {
            attachScreenshot(app, name: "flow-post-onboarding")
            XCTFail("Expected paywall or notification prompt after onboarding")
        }
    }

    private func waitForPrimaryCTA(_ app: XCUIApplication, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            for label in primaryCTAs {
                if app.buttons[label].exists { return true }
            }
            if app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Start Selah'")).firstMatch.exists {
                return false
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return false
    }

    private func tapPrimaryCTA(_ app: XCUIApplication) {
        for label in primaryCTAs {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: 2) {
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
