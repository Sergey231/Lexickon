protocol DatasetCatalogRepository: Sendable {
    func catalog() async throws -> DatasetManifest
    func availability(
        installed: [InstalledDataset],
        wanted: [WantedDataset]
    ) async throws -> DatasetSyncAvailability
    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL
}
