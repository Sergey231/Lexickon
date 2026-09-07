import Foundation

enum NetworkError: Error, Equatable, Sendable {
    case cancelled
    case timedOut
    case offline
    case transport(code: URLError.Code)
    case invalidRequest
    case invalidResponse
    case decoding
    case unauthenticated
    case badRequest(code: String?)
    case unauthorized
    case forbidden
    case notFound
    case conflict(code: String?)
    case server(statusCode: Int, code: String?)
    case unexpectedStatus(statusCode: Int, code: String?)
}
