import XCTest

final class NativeChromeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingUsesSystemNavigationBarNotWebChrome() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        XCTAssertTrue(
            app.navigationBars.firstMatch.waitForExistence(timeout: 15),
            "Onboarding must use UINavigationBar, not a custom web header"
        )
        XCTAssertTrue(
            app.buttons["onboarding.continue"].waitForExistence(timeout: 5)
                || app.buttons["Begin"].waitForExistence(timeout: 2),
            "Primary onboarding CTA missing"
        )
        XCTAssertFalse(app.webViews.firstMatch.exists, "App must not embed the HTML mock")
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
        XCTAssertFalse(app.buttons["Coming soon"].exists)
    }

    func testMainTabsUseSystemTabBarAndLargeTitles() {
        let app = launchDemo()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Missing UITabBar")
        for name in ["Today", "Read", "Talk", "Pray", "Journey"] {
            XCTAssertTrue(app.tabBars.buttons[name].exists, "Missing tab: \(name)")
        }

        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
        XCTAssertFalse(app.buttons["Coming soon"].exists)

        app.tabBars.buttons["Read"].tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5), "Read needs a navigation bar")

        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.navigationBars["Talk"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Pray"].tap()
        XCTAssertTrue(app.navigationBars["Pray"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Journey"].tap()
        XCTAssertTrue(app.navigationBars["Journey"].waitForExistence(timeout: 5))
    }

    func testSettingsOpensAsNativeSheet() {
        let app = launchDemo()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))

        let settings = app.buttons["selah.settings.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.switches.firstMatch.exists || app.tables.firstMatch.exists || app.collectionViews.firstMatch.exists,
            "Settings should be a native Form/List sheet"
        )
        app.buttons["Done"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 3))
    }

    func testOnboardingSkipReachesNativePaywallCover() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 15), "Onboarding skip must exist before paywall")
        skip.tap()

        XCTAssertTrue(
            app.buttons["paywall.subscribe"].waitForExistence(timeout: 8)
                || app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Start Selah'")).firstMatch.waitForExistence(timeout: 3),
            "Skip should present the hard paywall"
        )
        XCTAssertTrue(
            app.navigationBars.firstMatch.exists,
            "Paywall must use a navigation bar, not a web-style header"
        )
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
    }

    private func launchDemo() -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()
        return app
    }
}
