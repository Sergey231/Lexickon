import XCTest
@testable import Lexickon

final class SessionControllerTests: XCTestCase, @unchecked Sendable {
    func testAccessTokenRejectsWhitespaceAndControlCharacters() {
        XCTAssertNil(AccessToken(rawValue: "token with space"))
        XCTAssertNil(AccessToken(rawValue: "token\nwith-newline"))
    }

    func testRefreshPlaceholderDoesNotDependOnNetworkError() async {
        do {
            _ = try await RefreshNotConfigured().refreshSession()
            XCTFail("Refresh is not configured")
        } catch let error as SessionRefreshError {
            XCTAssertEqual(error, .notConfigured)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBootstrapWithoutTokenProducesAbsentSession() async throws {
        let store = InMemoryTokenStore(result: .success(nil))
        let session = SessionController(tokenStore: store)

        let result = try await session.bootstrap()

        XCTAssertEqual(result, .absent)
        let state = await session.currentState()
        let token = await session.bearerToken()
        XCTAssertEqual(state, .signedOut)
        XCTAssertNil(token)
    }

    func testBootstrapWithTokenProducesPotentiallyValidSession() async throws {
        let token = try XCTUnwrap(AccessToken(rawValue: "stored-token"))
        let store = InMemoryTokenStore(result: .success(token))
        let session = SessionController(tokenStore: store)

        let result = try await session.bootstrap()

        let state = await session.currentState()
        let restoredToken = await session.bearerToken()
        XCTAssertEqual(result, .potentiallyValid)
        XCTAssertEqual(state, .potentiallyValid)
        XCTAssertEqual(restoredToken, token)
    }

    func testBootstrapDeletesCorruptedTokenAndProducesInvalidSession() async throws {
        let store = InMemoryTokenStore(result: .failure(TokenStoreError.corrupted))
        let session = SessionController(tokenStore: store)

        let result = try await session.bootstrap()

        let state = await session.currentState()
        let token = await session.bearerToken()
        let deleteCallCount = await store.deleteCallCount
        XCTAssertEqual(result, .invalid)
        XCTAssertEqual(state, .invalid(.corruptedToken))
        XCTAssertNil(token)
        XCTAssertEqual(deleteCallCount, 1)
    }

    func testUnauthorizedClearsTokenAndInvalidatesSession() async throws {
        let token = try XCTUnwrap(AccessToken(rawValue: "expired-token"))
        let store = InMemoryTokenStore(result: .success(nil))
        let session = SessionController(tokenStore: store)
        try await session.establishSession(with: token)

        await session.didReceiveUnauthorized()

        let state = await session.currentState()
        let storedToken = await session.bearerToken()
        let deleteCallCount = await store.deleteCallCount
        XCTAssertEqual(state, .invalid(.unauthorized))
        XCTAssertNil(storedToken)
        XCTAssertEqual(deleteCallCount, 1)
    }
}
