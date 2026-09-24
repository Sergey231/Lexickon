/// Загружает манифест доступных датасетов с сервера.
/// - Returns: `DatasetManifest` — список языков, доменов, версий, схем сжатия, планов доступа.
/// - Throws: `AppError` — `.dataset(.manifestUnavailable)`, `.authorization`,
///   `.transport`, `.cache` (если кэш невалиден).
/// Используется `SynchronizeDatasetsUseCase` и UI каталога.
struct GetDatasetCatalogUseCase: Sendable {
    private let repository: any DatasetCatalogRepository

    init(repository: any DatasetCatalogRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> DatasetManifest {
        try await repository.catalog()
    }
}
