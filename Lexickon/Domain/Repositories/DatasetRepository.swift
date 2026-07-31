protocol DatasetRepository: Sendable {
    func catalog() async throws -> [Dataset]
    func synchronize(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult
}
