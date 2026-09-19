import Foundation
import XCTest
@testable import Lexickon

final class AuthRepositoryImplTests: XCTestCase, @unchecked Sendable {
    func testRegistrationDoesNotPersistToken() async throws {
        let store = InMemoryTokenStore()
        let session = SessionController(tokenStore: store)
        let repository = makeRepository(session: session)
        URLProtocolStub.registry.setHandler { request in
            XCTAssertEqual(request.url?.path, "/v1/auth/register")
            return .response(Self.response(for: request, statusCode: 201), Self.userProfileData)
        }

        let user = try await repository.register(
            RegistrationRequest(email: "reader@example.com", password: "password-1")
        )

        let savedTokens = await store.savedTokens
        XCTAssertEqual(user.email, "reader@example.com")
        XCTAssertEqual(user.settings.preferredLanguage, LanguageCode(rawValue: "en"))
        XCTAssertEqual(user.settings.selectedDomains, [DatasetDomain(rawValue: "core")])
        XCTAssertFalse(user.settings.offlineMode)
        XCTAssertFalse(user.settings.syncOverCellular)
        XCTAssertTrue(savedTokens.isEmpty)
    }

    func testLoginPersistsTokenAfterSuccessfulResponse() async throws {
        let store = InMemoryTokenStore()
        let session = SessionController(tokenStore: store)
        let repository = makeRepository(session: session)
        URLProtocolStub.registry.setHandler { request in
            XCTAssertEqual(request.url?.path, "/v1/auth/login")
            return .response(Self.response(for: request, statusCode: 200), Self.tokenData)
        }

        let state = try await repository.login(
            LoginRequest(email: "reader@example.com", password: "password-1")
        )

        let savedTokens = await store.savedTokens
        let bearerToken = await session.bearerToken()
        XCTAssertEqual(state, .signedIn)
        XCTAssertEqual(savedTokens, [AccessToken(rawValue: "login-token")])
        XCTAssertEqual(bearerToken, AccessToken(rawValue: "login-token"))
    }

    func testFailedLoginDoesNotDamageExistingSession() async throws {
        let existingToken = try XCTUnwrap(AccessToken(rawValue: "existing-token"))
        let store = InMemoryTokenStore(result: .success(existingToken))
        let session = SessionController(tokenStore: store)
        _ = try await session.bootstrap()
        let repository = makeRepository(session: session)
        URLProtocolStub.registry.setHandler { request in
            XCTAssertEqual(request.url?.path, "/v1/auth/login")
            return .response(Self.response(for: request, statusCode: 401), Data())
        }

        do {
            _ = try await repository.login(
                LoginRequest(email: "reader@example.com", password: "wrong-password")
            )
            XCTFail("Expected invalid credentials")
        } catch let error as AppError {
            XCTAssertEqual(error, .authorization(.invalidCredentials))
        }

        let token = await session.bearerToken()
        let state = await session.currentState()
        XCTAssertEqual(token, existingToken)
        XCTAssertEqual(state, .potentiallyValid)
    }

    func testAuthenticationStateVerifiesStoredTokenWithProfileRequest() async throws {
        let token = try XCTUnwrap(AccessToken(rawValue: "stored-token"))
        let store = InMemoryTokenStore(result: .success(token))
        let session = SessionController(tokenStore: store)
        let repository = makeRepository(session: session)
        URLProtocolStub.registry.setHandler { request in
            XCTAssertEqual(request.url?.path, "/v1/me")
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer stored-token"
            )
            return .response(Self.response(for: request, statusCode: 200), Self.userProfileData)
        }

        let state = try await repository.authenticationState()

        XCTAssertEqual(state, .signedIn)
    }

    func testUnauthorizedDuringBootstrapClearsStoredToken() async throws {
        let token = try XCTUnwrap(AccessToken(rawValue: "expired-token"))
        let store = InMemoryTokenStore(result: .success(token))
        let session = SessionController(tokenStore: store)
        let repository = makeRepository(session: session)
        URLProtocolStub.registry.setHandler { request in
            .response(Self.response(for: request, statusCode: 401), Data())
        }

        let state = try await repository.authenticationState()

        let deleteCallCount = await store.deleteCallCount
        let bearerToken = await session.bearerToken()
        XCTAssertEqual(state, .signedOut)
        XCTAssertEqual(deleteCallCount, 1)
        XCTAssertNil(bearerToken)
    }

    private func makeRepository(session: SessionController) -> AuthRepositoryImpl {
        AuthRepositoryImpl(
            apiClient: makeClient(session: session),
            session: session
        )
    }

    private func makeClient(session: SessionController) -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return APIClient(
            baseURL: URL(string: "https://api.unit.test/v1")!,
            transport: URLSessionTransport(session: URLSession(configuration: configuration)),
            session: session
        )
    }

    private static func response(
        for request: URLRequest,
        statusCode: Int
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }

    private static let tokenData = Data(#"{"access_token":"login-token"}"#.utf8)
    private static let userProfileData = Data(
        """
        {
          "id": "user-1",
          "email": "reader@example.com",
          "is_active": true,
          "created_at": "2026-08-23T11:27:37.412003Z",
          "updated_at": "2026-08-23T15:56:51.598831Z",
          "last_login_at": "2026-08-23T15:56:51.657079Z"
        }
        """.utf8
    )
}
