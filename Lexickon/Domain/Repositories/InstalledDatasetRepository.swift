protocol InstalledDatasetRepository: Sendable {
    func datasets() async throws -> [InstalledDataset]
    func apply(_ plan: DatasetSyncPlan) async throws
}
