import XCTest

final class LexickonUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsAuthenticationRoot() {
        let app = launchApplication()

        XCTAssertTrue(app.staticTexts["auth.placeholder"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["auth.complete"].exists)
    }

    @MainActor
    func testRootFlowReplacementDoesNotAllowBackNavigation() {
        let app = launchApplication()

        XCTAssertTrue(app.buttons["auth.complete"].waitForExistence(timeout: 5))
        app.buttons["auth.complete"].tap()

        XCTAssertTrue(
            app.staticTexts["datasetSetup.placeholder"].waitForExistence(timeout: 5)
        )
        app.buttons["datasetSetup.complete"].tap()

        XCTAssertTrue(app.staticTexts["main.placeholder"].waitForExistence(timeout: 5))
        app.buttons["main.logout"].tap()

        XCTAssertTrue(app.staticTexts["auth.placeholder"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["main.placeholder"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists)

        app.swipeRight()

        XCTAssertTrue(app.staticTexts["auth.placeholder"].exists)
        XCTAssertFalse(app.staticTexts["main.placeholder"].exists)
    }

    @MainActor
    private func launchApplication() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()

        return app
    }
}
