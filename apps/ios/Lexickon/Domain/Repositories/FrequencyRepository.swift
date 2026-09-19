protocol FrequencyRepository: Sendable {
    func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult?
}
