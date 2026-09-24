struct FrequencyQuery: Equatable, Sendable {
    let text: String
    let datasetKey: DatasetKey
}

/// Ищет частотность слова/фразы в выбранном датасете.
/// - Parameter query: Текст для поиска и ключ датасета.
/// - Returns: `FrequencyResult?` — nil, если токен не найден.
/// - Throws: `AppError` — `.dataset(.packMissing)` если датасет не установлен,
///   `.storage` ошибки чтения SQLite.
struct LookupFrequencyUseCase: Sendable {
    private let repository: any FrequencyRepository

    init(repository: any FrequencyRepository) {
        self.repository = repository
    }

    func callAsFunction(_ query: FrequencyQuery) async throws -> FrequencyResult? {
        try await repository.lookup(query)
    }
}
