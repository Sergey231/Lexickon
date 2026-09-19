import Foundation

struct DatasetDownloadURL: Equatable, Sendable {
    let url: URL
    let expiresAt: Date
    let checksumSHA256: String
    let compressedSizeBytes: Int64
    let compression: DatasetCompression
}

struct GetDatasetDownloadURLUseCase: Sendable {
    private let repository: any DatasetCatalogRepository

    init(repository: any DatasetCatalogRepository) {
        self.repository = repository
    }

    func callAsFunction(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL {
        try await repository.downloadURL(for: versionID)
    }
}
