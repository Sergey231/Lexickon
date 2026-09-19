import Foundation
import XCTest
@testable import Lexickon

final class APIClientTests: XCTestCase, @unchecked Sendable {
    func testBuildsURLHeadersAndJSONBody() async throws {
        let session = SessionSpy(token: AccessToken(rawValue: "current-token"))
        let client = makeClient(session: session)
        let request = ProbeRequest(
            method: .post,
            queryItems: [URLQueryItem(name: "page", value: "2")],
            authorization: .bearer,
            body: ProbeBody(displayName: "Reader")
        )
        URLProtocolStub.registry.setHandler { request in
            .response(Self.response(for: request, statusCode: 200), Self.successData)
        }

        let builtRequest = try await client.makeURLRequest(for: request)
        let response = try await client.send(request)
        let body = try XCTUnwrap(builtRequest.httpBody)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: String]
        )

        XCTAssertEqual(response, ProbeResponse(value: "ok"))
        XCTAssertEqual(builtRequest.url?.absoluteString, "https://api.unit.test/v1/probe?page=2")
        XCTAssertEqual(builtRequest.httpMethod, "POST")
        XCTAssertEqual(builtRequest.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(builtRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(builtRequest.value(forHTTPHeaderField: "Authorization"), "Bearer current-token")
        XCTAssertEqual(object, ["display_name": "Reader"])
    }

    func testDecodesEmptySuccessfulResponse() async throws {
        let client = makeClient()
        URLProtocolStub.registry.setHandler { request in
            .response(Self.response(for: request, statusCode: 204), Data())
        }

        let response = try await client.send(EmptyProbeRequest())

        XCTAssertEqual(response, EmptyResponse())
    }

    func testMapsHTTPFailuresWithoutRetry() async {
        let cases = [
            FailureCase(400, Self.errorData, .badRequest(code: "invalid_input")),
            FailureCase(401, Data(), .unauthorized),
            FailureCase(403, Data(), .forbidden),
            FailureCase(404, Data(), .notFound),
            FailureCase(
                503,
                Self.errorData,
                .server(statusCode: 503, code: "invalid_input")
            )
        ]

        for testCase in cases {
            let session = SessionSpy(token: AccessToken(rawValue: "token"))
            let client = makeClient(session: session)
            URLProtocolStub.registry.setHandler { request in
                .response(
                    Self.response(for: request, statusCode: testCase.statusCode),
                    testCase.data
                )
            }

            await XCTAssertThrowsNetworkError(testCase.expectedError) {
                try await client.send(ProbeRequest())
            }

            let unauthorizedCount = await session.unauthorizedCount
            XCTAssertEqual(unauthorizedCount, 0)
        }
    }

    func testBearerUnauthorizedInvalidatesSession() async {
        let session = SessionSpy(token: AccessToken(rawValue: "token"))
        let client = makeClient(session: session)
        URLProtocolStub.registry.setHandler { request in
            .response(Self.response(for: request, statusCode: 401), Data())
        }

        await XCTAssertThrowsNetworkError(.unauthorized) {
            try await client.send(ProbeRequest(authorization: .bearer))
        }

        let unauthorizedCount = await session.unauthorizedCount
        XCTAssertEqual(unauthorizedCount, 1)
    }

    func testMapsTimeout() async {
        let client = makeClient()
        URLProtocolStub.registry.setHandler { _ in
            .failure(URLError(.timedOut))
        }

        await XCTAssertThrowsNetworkError(.timedOut) {
            try await client.send(ProbeRequest())
        }
    }

    func testMapsMalformedSuccessBody() async {
        let client = makeClient()
        URLProtocolStub.registry.setHandler { request in
            .response(Self.response(for: request, statusCode: 200), Data("{".utf8))
        }

        await XCTAssertThrowsNetworkError(.decoding) {
            try await client.send(ProbeRequest())
        }
    }

    func testMapsNonHTTPResponseAsMalformedResponse() async {
        let client = makeClient()
        URLProtocolStub.registry.setHandler { request in
            let response = URLResponse(
                url: request.url!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return .response(response, Data())
        }

        await XCTAssertThrowsNetworkError(.invalidResponse) {
            try await client.send(ProbeRequest())
        }
    }

    func testMissingTokenStopsAuthorizedRequestBeforeTransport() async {
        let client = makeClient(session: SessionSpy(token: nil))
        URLProtocolStub.registry.setHandler { _ in
            XCTFail("Transport must not receive an unauthorized request")
            return .pending
        }

        await XCTAssertThrowsNetworkError(.unauthenticated) {
            try await client.send(
                ProbeRequest(authorization: .bearer)
            )
        }
        XCTAssertFalse(URLProtocolStub.registry.snapshot().started)
    }

    func testRejectsEndpointSuppliedAuthorizationHeader() async {
        let client = makeClient()
        URLProtocolStub.registry.setHandler { _ in .pending }

        await XCTAssertThrowsNetworkError(.invalidRequest) {
            try await client.send(AuthorizationHeaderRequest())
        }
        XCTAssertFalse(URLProtocolStub.registry.snapshot().started)
    }

    private func makeClient(
        session: any SessionAuthorizing = SessionSpy(token: nil)
    ) -> APIClient {
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

    private static let successData = Data(#"{"value":"ok"}"#.utf8)
    private static let errorData = Data(#"{"code":"invalid_input"}"#.utf8)
}

private struct FailureCase: Sendable {
    let statusCode: Int
    let data: Data
    let expectedError: NetworkError

    init(_ statusCode: Int, _ data: Data, _ expectedError: NetworkError) {
        self.statusCode = statusCode
        self.data = data
        self.expectedError = expectedError
    }
}

private struct ProbeRequest: APIRequest {
    typealias Response = ProbeResponse

    let method: HTTPMethod
    let path = "/probe"
    let queryItems: [URLQueryItem]
    let authorization: RequestAuthorization
    let body: ProbeBody?

    init(
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        authorization: RequestAuthorization = .none,
        body: ProbeBody? = nil
    ) {
        self.method = method
        self.queryItems = queryItems
        self.authorization = authorization
        self.body = body
    }

    func encodeBody(using encoder: JSONEncoder) throws -> Data? {
        guard let body else { return nil }
        return try encoder.encode(body)
    }
}

private struct EmptyProbeRequest: APIRequest {
    typealias Response = EmptyResponse

    let method = HTTPMethod.delete
    let path = "/probe"
}

private struct AuthorizationHeaderRequest: APIRequest {
    typealias Response = EmptyResponse

    let method = HTTPMethod.get
    let path = "/probe"
    let headers = ["authorization": "Bearer endpoint-token"]
}

private struct ProbeBody: Encodable, Sendable {
    let displayName: String
}

private struct ProbeResponse: Decodable, Equatable, Sendable {
    let value: String
}

private actor SessionSpy: SessionAuthorizing {
    let token: AccessToken?
    private(set) var unauthorizedCount = 0

    init(token: AccessToken?) {
        self.token = token
    }

    func bearerToken() -> AccessToken? {
        token
    }

    func didReceiveUnauthorized() {
        unauthorizedCount += 1
    }
}

private func XCTAssertThrowsNetworkError<T: Sendable>(
    _ expectedError: NetworkError,
    operation: () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await operation()
        XCTFail("Expected \(expectedError)", file: file, line: line)
    } catch let error as NetworkError {
        XCTAssertEqual(error, expectedError, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
}
