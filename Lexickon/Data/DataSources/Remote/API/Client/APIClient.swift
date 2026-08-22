import Foundation

struct APIClient: Sendable {
    private let baseURL: URL
    private let transport: any HTTPTransport
    private let session: any SessionAuthorizing

    init(
        baseURL: URL,
        transport: any HTTPTransport,
        session: any SessionAuthorizing
    ) {
        self.baseURL = baseURL
        self.transport = transport
        self.session = session
    }

    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await transport.data(for: urlRequest)

        return try await decode(
            Request.Response.self,
            from: data,
            response: response
        )
    }

    func makeURLRequest<Request: APIRequest>(for request: Request) async throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: normalizedPath(request.path)),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidRequest
        }
        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidRequest
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        guard !request.headers.keys.contains(where: {
            $0.caseInsensitiveCompare("Authorization") == .orderedSame
        }) else {
            throw NetworkError.invalidRequest
        }
        for (name, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }

        let body: Data?
        do {
            body = try request.encodeBody(using: Self.makeEncoder())
        } catch {
            throw NetworkError.invalidRequest
        }
        if let body {
            urlRequest.httpBody = body
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        if case .bearer = request.authorization {
            guard let token = await session.bearerToken() else {
                throw NetworkError.unauthenticated
            }
            urlRequest.setValue(
                "Bearer \(token.rawValue)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return urlRequest
    }

    private func decode<Response: Decodable & Sendable>(
        _ type: Response.Type,
        from data: Data,
        response: HTTPURLResponse
    ) async throws -> Response {
        switch response.statusCode {
        case 200..<300:
            if Response.self == EmptyResponse.self, data.isEmpty,
               let empty = EmptyResponse() as? Response {
                return empty
            }
            do {
                return try Self.makeDecoder().decode(Response.self, from: data)
            } catch {
                throw NetworkError.decoding
            }
        case 400:
            throw NetworkError.badRequest(code: errorCode(from: data))
        case 401:
            await session.didReceiveUnauthorized()
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500..<600:
            throw NetworkError.server(
                statusCode: response.statusCode,
                code: errorCode(from: data)
            )
        default:
            throw NetworkError.unexpectedStatus(
                statusCode: response.statusCode,
                code: errorCode(from: data)
            )
        }
    }

    private func errorCode(from data: Data) -> String? {
        (try? Self.makeDecoder().decode(APIErrorDTO.self, from: data))?.normalizedCode
    }

    private func normalizedPath(_ path: String) -> String {
        path.hasPrefix("/") ? String(path.dropFirst()) : path
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
