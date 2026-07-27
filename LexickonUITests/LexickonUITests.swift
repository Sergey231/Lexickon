import XCTest

final class LexickonUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsPlaceholderScreen() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["placeholder.title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["placeholder.subtitle"].exists)
    }
}
