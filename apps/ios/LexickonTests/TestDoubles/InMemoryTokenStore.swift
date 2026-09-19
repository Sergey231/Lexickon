@testable import Lexickon

actor InMemoryTokenStore: TokenStore {
    private var result: Result<AccessToken?, Error>
    private(set) var savedTokens: [AccessToken] = []
    private(set) var deleteCallCount = 0

    init(result: Result<AccessToken?, Error> = .success(nil)) {
        self.result = result
    }

    func loadAccessToken() async throws -> AccessToken? {
        try result.get()
    }

    func saveAccessToken(_ token: AccessToken) async throws {
        savedTokens.append(token)
        result = .success(token)
    }

    func deleteAccessToken() async throws {
        deleteCallCount += 1
        result = .success(nil)
    }
}
