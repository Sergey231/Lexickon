struct GetDatasetCatalogUseCase: Sendable {
    private let repository: any DatasetRepository

    init(repository: any DatasetRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> [Dataset] {
        try await repository.catalog()
    }
}

struct SynchronizeDatasetsUseCase: Sendable {
    private let repository: any DatasetRepository

    init(repository: any DatasetRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult {
        try await repository.synchronize(request)
    }
}
