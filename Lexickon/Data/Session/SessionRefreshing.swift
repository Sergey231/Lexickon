protocol SessionRefreshing: Sendable {
    func refreshSession() async throws -> AccessToken
}

enum SessionRefreshError: Error, Equatable, Sendable {
    case notConfigured
}

struct RefreshNotConfigured: SessionRefreshing {
    func refreshSession() async throws -> AccessToken {
        throw SessionRefreshError.notConfigured
    }
}
