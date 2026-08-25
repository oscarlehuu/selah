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
            app.otherElements["onboarding.welcome.sanctuary"].waitForExistence(timeout: 15),
            "Welcome must be a full-bleed sanctuary, not a web header"
        )
        XCTAssertTrue(
            app.buttons["onboarding.skip"].waitForExistence(timeout: 5),
            "Welcome Skip must stay as an overlay when the system nav bar is hidden"
        )
        XCTAssertTrue(
            app.buttons["onboarding.continue"].waitForExistence(timeout: 5)
                || app.buttons["Begin"].waitForExistence(timeout: 2),
            "Primary onboarding CTA missing"
        )
        XCTAssertFalse(app.navigationBars["Today"].exists)
        XCTAssertFalse(app.navigationBars["Welcome"].exists)
        XCTAssertFalse(app.webViews.firstMatch.exists, "App must not embed the HTML mock")
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
        XCTAssertFalse(app.buttons["Coming soon"].exists)
        XCTAssertFalse(app.staticTexts["Demo"].exists, "Demo chip mimics the HTML mock frame — remove it")
        XCTAssertFalse(app.buttons["Demo"].exists)
    }

    func testMainTabsUseCompactChromeNotLargeTitles() {
        let app = launchDemo()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Missing UITabBar")
        for name in ["Today", "Read", "Talk", "Pray", "Journey"] {
            XCTAssertTrue(app.tabBars.buttons[name].exists, "Missing tab: \(name)")
        }

        XCTAssertTrue(app.buttons["selah.settings.open"].waitForExistence(timeout: 5), "Today floating Settings gear missing")
        XCTAssertFalse(app.navigationBars["Today"].exists, "Today must have no navbar")
        XCTAssertFalse(app.webViews.firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Coming soon"].exists)
        XCTAssertFalse(app.staticTexts["Demo"].exists)

        app.tabBars.buttons["Read"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5), "Read needs a compact navbar")

        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Talk"].exists)
        XCTAssertTrue(app.buttons["talk.privacy"].exists)
        XCTAssertTrue(app.buttons["talk.clear"].exists)
        XCTAssertFalse(app.buttons["selah.settings.open"].exists, "Talk must not show Settings")

        app.tabBars.buttons["Pray"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Pray"].exists)
        XCTAssertTrue(app.buttons["pray.close"].exists)
        XCTAssertTrue(app.staticTexts["5 min"].exists || app.otherElements["pray.duration"].exists)
        XCTAssertFalse(app.buttons["selah.settings.open"].exists, "Pray must not show Settings")

        app.tabBars.buttons["Journey"].tap()
        XCTAssertTrue(app.otherElements["selah.navbar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Journey"].exists)
        XCTAssertTrue(app.buttons["selah.settings.open"].waitForExistence(timeout: 3), "Journey header holds Settings")
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
