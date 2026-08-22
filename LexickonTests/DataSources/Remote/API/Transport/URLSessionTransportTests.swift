import Foundation
import XCTest
@testable import Lexickon

final class URLSessionTransportTests: XCTestCase, @unchecked Sendable {
    func testTaskCancellationStopsURLSessionLoad() async throws {
        URLProtocolStub.registry.setHandler { _ in .pending }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let transport = URLSessionTransport(
            session: URLSession(configuration: configuration)
        )
        let request = URLRequest(url: URL(string: "https://cancel.unit.test")!)
        let task = Task {
            try await transport.data(for: request)
        }

        try await waitUntil { URLProtocolStub.registry.snapshot().started }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("The transport should propagate cancellation")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .cancelled)
        }
        try await waitUntil { URLProtocolStub.registry.snapshot().stopped }
    }

    private func waitUntil(
        _ condition: @escaping @Sendable () -> Bool
    ) async throws {
        for _ in 0..<100 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertTrue(condition())
    }
}
