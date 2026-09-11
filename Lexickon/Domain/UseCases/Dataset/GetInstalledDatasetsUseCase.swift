struct GetInstalledDatasetsUseCase: Sendable {
    private let repository: any InstalledDatasetRepository

    init(repository: any InstalledDatasetRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> [InstalledDataset] {
        try await repository.datasets()
    }
}
