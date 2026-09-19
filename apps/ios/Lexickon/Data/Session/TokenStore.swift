protocol TokenStore: Sendable {
    func loadAccessToken() async throws -> AccessToken?
    func saveAccessToken(_ token: AccessToken) async throws
    func deleteAccessToken() async throws
}

enum TokenStoreError: Error, Equatable, Sendable {
    case readFailed(status: Int32)
    case writeFailed(status: Int32)
    case deleteFailed(status: Int32)
    case corrupted
}
