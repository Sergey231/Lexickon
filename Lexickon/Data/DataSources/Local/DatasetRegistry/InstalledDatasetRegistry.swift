import Foundation

protocol InstalledDatasetRegistry: Sendable {
    func installedDatasets() async throws -> [InstalledDataset]
    func replace(with datasets: [InstalledDataset]) async throws
    func upsert(_ dataset: InstalledDataset) async throws
    func remove(key: DatasetKey) async throws
}

enum DatasetRegistryError: Error, Equatable, Sendable {
    case readFailed
    case writeFailed
    case corrupted
    case unsupportedSchemaVersion(Int)
}
