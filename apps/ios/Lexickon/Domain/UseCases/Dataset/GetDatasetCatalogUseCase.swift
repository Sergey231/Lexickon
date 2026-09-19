struct GetDatasetCatalogUseCase: Sendable {
    private let repository: any DatasetCatalogRepository

    init(repository: any DatasetCatalogRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> DatasetManifest {
        try await repository.catalog()
    }
}
