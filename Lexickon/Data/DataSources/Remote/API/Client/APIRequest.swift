import Foundation

protocol APIRequest: Sendable {
    associatedtype Response: Decodable & Sendable

    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var authorization: RequestAuthorization { get }

    func encodeBody(using encoder: JSONEncoder) throws -> Data?
}

extension APIRequest {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var authorization: RequestAuthorization { .none }

    func encodeBody(using encoder: JSONEncoder) throws -> Data? {
        nil
    }
}

enum RequestAuthorization: Sendable {
    case none
    case bearer
}

struct EmptyResponse: Decodable, Equatable, Sendable {}
