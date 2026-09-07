struct GetDatasetCatalogUseCase: Sendable {
    private let repository: any DatasetRepository

    init(repository: any DatasetRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> DatasetManifest {
        try await repository.catalog()
    }
}

struct GetDatasetDownloadURLUseCase: Sendable {
    private let repository: any DatasetRepository

    init(repository: any DatasetRepository) {
        self.repository = repository
    }

    func callAsFunction(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL {
        try await repository.downloadURL(for: versionID)
    }
}

struct GetInstalledDatasetsUseCase: Sendable {
    private let repository: any DatasetRepository

    init(repository: any DatasetRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> [InstalledDataset] {
        try await repository.installedDatasets()
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
