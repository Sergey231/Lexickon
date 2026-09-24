/// Возвращает список установленных на устройстве датасетов.
/// - Returns: Массив `InstalledDataset` с версией, путём к SQLite, размером, датой установки.
/// - Throws: `AppError` — `.storage` ошибки чтения БД/файловой системы.
/// Используется `SynchronizeDatasetsUseCase` для diff с каталогом.
struct GetInstalledDatasetsUseCase: Sendable {
    private let repository: any InstalledDatasetRepository

    init(repository: any InstalledDatasetRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> [InstalledDataset] {
        try await repository.datasets()
    }
}
