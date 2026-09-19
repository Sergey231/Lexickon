import XCTest

final class LexickonTests: XCTestCase {
    func testNavigationPlaceholderStringsAreLocalized() {
        let keys = [
            "navigation.auth.title",
            "navigation.dataset.title",
            "navigation.main.title",
            "navigation.placeholder.subtitle"
        ]

        for key in keys {
            let value = Bundle.main.localizedString(
                forKey: key,
                value: nil,
                table: nil
            )

            XCTAssertNotEqual(value, key)
        }
    }
}
