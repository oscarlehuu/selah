import XCTest

final class NativeChromeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingUsesMockV4TopBarNotWebChrome() {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-UITestFreshStart"]
        app.launch()

        // Mock v4 chrome: back circle + progress + Skip overlay, no UINavigationBar.
        XCTAssertTrue(
            app.buttons["onboarding.skip"].waitForExistence(timeout: 15),
            "Onboarding top bar (progress + Skip) missing"
        )
        XCTAssertTrue(
            app.buttons["onboarding.continue"].waitForExistence(timeout: 5)
                || app.buttons["Begin"].waitForExistence(timeout: 2),
            "Primary onboarding CTA missing"
        )
        XCTAssertFalse(app.webViews.firstMatch.exists, "App must not embed the HTML mock")
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
        XCTAssertFalse(app.buttons["Coming soon"].exists)
        XCTAssertFalse(app.staticTexts["Demo"].exists, "Demo chip mimics the HTML mock frame — remove it")
        XCTAssertFalse(app.buttons["Demo"].exists)
    }

    // Mock v4 chrome: system tab bar stays, but screens use the custom SelahNavBar
    // (centered display title, blur) — NO native UINavigationBar titles.
    func testMainTabsUseMockV4Chrome() {
        let app = launchDemo()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Missing UITabBar")
        for name in ["Today", "Read", "Talk", "Pray", "Journey"] {
            XCTAssertTrue(app.tabBars.buttons[name].exists, "Missing tab: \(name)")
        }

        // Note: "Coming soon" IS legitimate on Today (mock v4 `.promo` widget card).
        XCTAssertFalse(app.staticTexts["Demo"].exists, "No Demo chip on native tabs")
        XCTAssertFalse(app.webViews.firstMatch.exists)
        XCTAssertFalse(app.navigationBars["Today"].exists, "Today must not use a native nav title (mock v4)")

        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.staticTexts["Talk"].waitForExistence(timeout: 5), "Talk custom navbar title missing")
        XCTAssertFalse(app.navigationBars["Talk"].exists)

        app.tabBars.buttons["Pray"].tap()
        XCTAssertTrue(app.staticTexts["Pray"].waitForExistence(timeout: 5), "Pray custom navbar title missing")

        app.tabBars.buttons["Journey"].tap()
        XCTAssertTrue(app.staticTexts["Journey"].waitForExistence(timeout: 5), "Journey custom navbar title missing")
    }

    func testSettingsOpensAsSheetWithMockChrome() {
        let app = launchDemo()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))

        let settings = app.buttons["selah.settings.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()

        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.navigationBars["Settings"].exists, "Settings sheet uses custom header, not nav bar")
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
        XCTAssertFalse(
            app.navigationBars["Selah Premium"].exists,
            "Paywall must not add a nav title (mock v4 has hero + centered headline only)"
        )
        XCTAssertTrue(
            app.buttons["paywall.restore"].waitForExistence(timeout: 3),
            "Restore purchase must live in the footer legal row"
        )
        XCTAssertFalse(app.buttons["See monthly plan"].exists, "No 'See monthly plan' — not in mock v4")
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
    }

    private func launchDemo() -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: "com.lilgroup.selah")
        app.launchArguments = ["-DemoMode"]
        app.launch()
        return app
    }
}
