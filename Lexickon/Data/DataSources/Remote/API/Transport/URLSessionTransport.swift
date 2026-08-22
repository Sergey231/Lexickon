import Foundation

struct URLSessionTransport: HTTPTransport {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            return (data, httpResponse)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch let error as URLError where error.code == .timedOut {
            throw NetworkError.timedOut
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.offline
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw NetworkError.transport(code: error.code)
        } catch {
            throw NetworkError.transport(code: .unknown)
        }
    }
}
