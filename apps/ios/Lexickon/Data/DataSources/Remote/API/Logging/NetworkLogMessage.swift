import Foundation

enum NetworkLogMessage {
    static func request(_ request: URLRequest) -> String {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = LogRedactor.redactURL(request.url)
        let headerNames = request.allHTTPHeaderFields?.keys.sorted() ?? []
        return "API request \(method) \(url) headers=\(headerNames) body=<omitted>"
    }

    static func failure(_ error: Error, request: URLRequest) -> String {
        "\(self.request(request)) result=\(LogRedactor.redact(String(describing: error)))"
    }
}

enum LogRedactor {
    private static let sensitiveKeys = [
        "password",
        "access_token",
        "refresh_token",
        "token",
        "authorization",
        "signature",
        "x-amz-signature"
    ]

    static func redact(_ value: String) -> String {
        var result = value.replacingOccurrences(
            of: #"(?i)Bearer\s+[^\s\"&,]+"#,
            with: "Bearer <redacted>",
            options: .regularExpression
        )

        for key in sensitiveKeys {
            result = result.replacingOccurrences(
                of: #"(?i)([\"']?\#(key)[\"']?\s*[:=]\s*[\"']?)[^\s\"'&,}]+"#,
                with: "$1<redacted>",
                options: .regularExpression
            )
            result = result.replacingOccurrences(
                of: #"(?i)([?&]\#(key)=)[^&\s]+"#,
                with: "$1<redacted>",
                options: .regularExpression
            )
        }
        return result
    }

    static func redactURL(_ url: URL?) -> String {
        guard
            let url,
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
        else {
            return "<invalid-url>"
        }
        if components.query != nil {
            components.query = "<redacted>"
        }
        return components.string ?? "<invalid-url>"
    }
}
