import XCTest

final class LexickonUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsAuthenticationRoot() {
        let app = launchApplication(resetAuth: true)

        XCTAssertTrue(app.staticTexts["auth.placeholder"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["auth.login"].exists)
        XCTAssertTrue(app.buttons["auth.registration"].exists)
    }

    @MainActor
    func testRootFlowReplacementDoesNotAllowBackNavigation() {
        let app = launchApplication(resetAuth: true)

        login(in: app, email: "reader@example.com", password: "password-1")

        XCTAssertTrue(
            app.staticTexts["datasetSetup.placeholder"].waitForExistence(timeout: 5)
        )

        XCTAssertFalse(app.staticTexts["auth.placeholder"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists)

        app.swipeRight()

        XCTAssertTrue(app.staticTexts["datasetSetup.placeholder"].exists)
        XCTAssertFalse(app.staticTexts["auth.placeholder"].exists)
    }

    @MainActor
    func testLoginValidationAndAPIErrorStates() {
        let app = launchApplication(resetAuth: true)

        XCTAssertTrue(app.buttons["auth.login"].waitForExistence(timeout: 5))
        app.buttons["auth.login"].tap()
        XCTAssertTrue(app.buttons["auth.login.submit"].waitForExistence(timeout: 5))
        app.buttons["auth.login.submit"].tap()

        XCTAssertTrue(app.staticTexts["auth.error"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["auth.error"].label, "Enter a valid email address.")

        fillCredentials(in: app, email: "wrong@example.com", password: "password-1")
        app.buttons["auth.login.submit"].tap()

        XCTAssertTrue(app.staticTexts["auth.error"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["auth.error"].label, "Email or password is incorrect.")
    }

    @MainActor
    func testRegistrationSuccessReturnsToLogin() {
        let app = launchApplication(resetAuth: true)

        XCTAssertTrue(app.buttons["auth.registration"].waitForExistence(timeout: 5))
        app.buttons["auth.registration"].tap()
        XCTAssertTrue(app.buttons["auth.registration.submit"].waitForExistence(timeout: 5))
        fillCredentials(in: app, email: "new@example.com", password: "password-1")
        app.buttons["auth.registration.submit"].tap()

        XCTAssertTrue(app.buttons["auth.login.submit"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLoginRelaunchRestoresSessionThenLogout() {
        var app = launchApplication(resetAuth: true)

        login(in: app, email: "reader@example.com", password: "password-1")
        XCTAssertTrue(
            app.staticTexts["datasetSetup.placeholder"].waitForExistence(timeout: 5)
        )

        app.terminate()
        app = launchApplication(resetAuth: false)

        XCTAssertTrue(
            app.staticTexts["datasetSetup.placeholder"].waitForExistence(timeout: 5)
        )
        dismissKeyboard(in: app)
        tapDatasetSetupComplete(in: app)
        XCTAssertTrue(app.staticTexts["main.placeholder"].waitForExistence(timeout: 5))
        app.buttons["main.logout"].tap()

        XCTAssertTrue(app.staticTexts["auth.placeholder"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func launchApplication(resetAuth: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
            "--uitest-auth-repository"
        ]
        if resetAuth {
            app.launchArguments.append("--uitest-reset-auth")
        }
        app.launch()

        return app
    }

    @MainActor
    private func login(in app: XCUIApplication, email: String, password: String) {
        XCTAssertTrue(app.buttons["auth.login"].waitForExistence(timeout: 5))
        app.buttons["auth.login"].tap()
        XCTAssertTrue(app.buttons["auth.login.submit"].waitForExistence(timeout: 5))
        fillCredentials(in: app, email: email, password: password)
        app.buttons["auth.login.submit"].tap()
    }

    @MainActor
    private func fillCredentials(in app: XCUIApplication, email: String, password: String) {
        let emailField = app.textFields["auth.email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.clearAndTypeText(email)

        let passwordField = app.textFields["auth.password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.clearAndTypeText(password)
    }

    @MainActor
    private func dismissKeyboard(in app: XCUIApplication) {
        guard app.keyboards.firstMatch.exists else { return }
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        } else {
            app.swipeDown()
        }
    }

    @MainActor
    private func tapDatasetSetupComplete(in app: XCUIApplication) {
        let button = app.buttons["datasetSetup.complete"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertTrue(button.waitUntilHittable(timeout: 5))
        button.tap()
    }
}

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)
        typeText(text)
    }

    func waitUntilHittable(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
