import Foundation

struct InstalledDataset: Equatable, Sendable {
    let key: DatasetKey
    let version: DatasetVersion
    let sqliteSchemaVersion: Int
    let checksumSHA256: String
    let installedAt: Date
    let updateState: InstalledDatasetUpdateState

    init(
        key: DatasetKey,
        version: DatasetVersion,
        sqliteSchemaVersion: Int,
        checksumSHA256: String,
        installedAt: Date = Date(timeIntervalSince1970: 0),
        updateState: InstalledDatasetUpdateState = .current
    ) {
        self.key = key
        self.version = version
        self.sqliteSchemaVersion = sqliteSchemaVersion
        self.checksumSHA256 = checksumSHA256
        self.installedAt = installedAt
        self.updateState = updateState
    }
}

enum InstalledDatasetUpdateState: String, Codable, Equatable, Sendable {
    case current
    case updateAvailable
    case deprecated
    case revoked
    case forbidden
    case incompatible
    case unavailable
}
