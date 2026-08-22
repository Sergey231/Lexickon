import Foundation
import XCTest
@testable import Lexickon

final class LogRedactorTests: XCTestCase {
    func testRedactsPasswordAccessTokenBearerAndSignedURLSecrets() {
        let secrets = [
            "super-secret-password",
            "access-secret",
            "bearer-secret",
            "signed-secret"
        ]
        let input = """
        {"password":"super-secret-password","access_token":"access-secret"} \
        Authorization: Bearer bearer-secret \
        https://storage.example/file?X-Amz-Signature=signed-secret&expires=123
        """

        let message = LogRedactor.redact(input)

        for secret in secrets {
            XCTAssertFalse(message.contains(secret))
        }
        XCTAssertTrue(message.contains("<redacted>"))
    }

    func testRequestMessageOmitsBodyAndAuthorizationValue() throws {
        var request = URLRequest(
            url: try XCTUnwrap(
                URL(string: "https://storage.example/file?token=signed-secret")
            )
        )
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"password":"body-secret"}"#.utf8)
        request.setValue("Bearer header-secret", forHTTPHeaderField: "Authorization")

        let message = NetworkLogMessage.request(request)

        XCTAssertFalse(message.contains("signed-secret"))
        XCTAssertFalse(message.contains("body-secret"))
        XCTAssertFalse(message.contains("header-secret"))
        XCTAssertTrue(message.contains("body=<omitted>"))
    }

    func testTokenDescriptionCannotRevealRawValue() throws {
        let token = try XCTUnwrap(AccessToken(rawValue: "description-secret"))

        XCTAssertEqual(String(describing: token), "<redacted>")
        XCTAssertEqual(String(reflecting: token), "<redacted>")
    }
}
