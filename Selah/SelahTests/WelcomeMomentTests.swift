import XCTest
@testable import Selah

final class WelcomeMomentTests: XCTestCase {
    func testWelcomeIsFullBleedSanctuaryNotGroupedForm() {
        XCTAssertTrue(OnboardingStep.welcome.hidesStandardOnboardingChrome)
        XCTAssertFalse(OnboardingStep.hook.hidesStandardOnboardingChrome)
        XCTAssertEqual(OnboardingStep.welcome.primaryCTA, "Begin")
    }

    func testWelcomeHeroIsChurchWindowPhoto() {
        XCTAssertEqual(SelahHero.windowResource, "selah-hero-window")
        XCTAssertNotNil(
            SelahHero.windowImage,
            "Welcome sanctuary requires selah-hero-window in the app bundle"
        )
    }

    func testWelcomeMomentsMatchMockV4Copy() {
        XCTAssertEqual(OnboardingCopy.welcomeTitle, "Selah")
        XCTAssertEqual(OnboardingCopy.welcomeSubtitle, "Pause · Reflect · Listen")
        XCTAssertEqual(OnboardingCopy.welcomeVerse, "Be still, and know that I am God.")
        XCTAssertEqual(OnboardingCopy.welcomeVerseRef, "Psalm 46:10 · KJV")
        XCTAssertEqual(OnboardingCopy.welcomeCTA, "Begin")
        XCTAssertEqual(OnboardingCopy.welcomeDurationHint, "Takes about 2 minutes")
        XCTAssertTrue(OnboardingCopy.welcomeMeaning.contains("stop here"))
    }
}
