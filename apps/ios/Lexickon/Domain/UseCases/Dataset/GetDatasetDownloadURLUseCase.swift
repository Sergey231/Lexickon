import Foundation

/// Получает подписанный URL для скачивания конкретной версии датасета.
///
/// - Parameter versionID: Идентификатор версии датасета.
/// - Returns: `DatasetDownloadURL` с временным URL, сроком действия, SHA-256 хэшем,
///   сжатым размером и алгоритмом сжатия.
/// - Throws: `AppError` — `.dataset(.unknownDataset)`, `.dataset(.notAllowed)`,
///   `.authorization`, `.transport`, `.cancelled`.
///
/// Используется `SynchronizeDatasetsUseCase` перед началом скачивания.
/// Полученный URL валидируется в `DatasetDownloadURLDTO.domainModel`:
///   - схема http/https, непустой host
///   - checksum — 64 hex-символа
///   - compressedSizeBytes > 0
///   - compression ∈ {gzip, zstd, none}
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
