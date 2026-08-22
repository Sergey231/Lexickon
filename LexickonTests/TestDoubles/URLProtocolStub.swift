import Foundation

final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    enum Result: Sendable {
        case response(URLResponse, Data)
        case failure(URLError)
        case pending
    }

    typealias Handler = @Sendable (URLRequest) -> Result

    static let registry = Registry()

    // swiftlint:disable:next static_over_final_class
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    // swiftlint:disable:next static_over_final_class
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let result = Self.registry.start(request)
        switch result {
        case let .response(response, data):
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        case .pending:
            break
        }
    }

    override func stopLoading() {
        Self.registry.stop()
    }
}

extension URLProtocolStub {
    struct Snapshot {
        let request: URLRequest?
        let started: Bool
        let stopped: Bool
    }

    final class Registry: @unchecked Sendable {
        private let lock = NSLock()
        private var handler: Handler = { _ in .pending }
        private(set) var latestRequest: URLRequest?
        private(set) var didStart = false
        private(set) var didStop = false

        func setHandler(_ handler: @escaping Handler) {
            lock.withLock {
                self.handler = handler
                latestRequest = nil
                didStart = false
                didStop = false
            }
        }

        func start(_ request: URLRequest) -> Result {
            lock.withLock {
                latestRequest = request
                didStart = true
                return handler(request)
            }
        }

        func stop() {
            lock.withLock {
                didStop = true
            }
        }

        func snapshot() -> Snapshot {
            lock.withLock {
                Snapshot(
                    request: latestRequest,
                    started: didStart,
                    stopped: didStop
                )
            }
        }
    }
}
