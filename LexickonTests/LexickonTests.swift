import XCTest

final class LexickonTests: XCTestCase {
    func testPlaceholderStringsAreLocalized() {
        let title = Bundle.main.localizedString(
            forKey: "placeholder.title",
            value: nil,
            table: nil
        )
        let subtitle = Bundle.main.localizedString(
            forKey: "placeholder.subtitle",
            value: nil,
            table: nil
        )

        XCTAssertNotEqual(title, "placeholder.title")
        XCTAssertNotEqual(subtitle, "placeholder.subtitle")
    }
}
