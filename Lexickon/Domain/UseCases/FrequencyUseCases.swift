struct FrequencyQuery: Equatable, Sendable {
    let text: String
    let datasetKey: DatasetKey
}

struct LookupFrequencyUseCase: Sendable {
    private let repository: any FrequencyRepository

    init(repository: any FrequencyRepository) {
        self.repository = repository
    }

    func callAsFunction(_ query: FrequencyQuery) async throws -> FrequencyResult? {
        try await repository.lookup(query)
    }
}
