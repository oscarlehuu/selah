import XCTest

final class DemoTabScreenshotTests: XCTestCase {
    private let tabNames = ["Today", "Read", "Talk", "Pray", "Journey"]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureAllMainTabs() throws {
        let app = launchDemoApp()

        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 15),
            "Main tab bar did not appear within 15s"
        )

        for name in tabNames {
            captureTab(app, name: name)
        }

        app.tabBars.buttons["Today"].tap()
        let settings = app.buttons["selah.settings.open"]
        if settings.waitForExistence(timeout: 3) {
            settings.tap()
            XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
            attachScreenshot(app, name: "sheet-settings")
            app.buttons["Done"].tap()
        }
    }

    private func launchDemoApp() -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()
        return app
    }

    private func captureTab(_ app: XCUIApplication, name: String) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "Missing tab: \(name)")
        tab.tap()
        attachScreenshot(app, name: "tab-\(name.lowercased())")
    }

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let settled = NSPredicate(format: "exists == true")
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            XCTAssertEqual(
                XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: settled, object: tabBar)], timeout: 2),
                .completed
            )
        }
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
