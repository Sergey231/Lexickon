protocol DatasetRepository: Sendable {
    func catalog() async throws -> DatasetManifest
    func installedDatasets() async throws -> [InstalledDataset]
    func synchronize(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult
    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL
}
