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

struct WantedDataset: Equatable, Sendable {
    let language: LanguageCode
    let domain: DatasetDomain
}

struct DatasetSyncRequest: Equatable, Sendable {
    let clientSchemaVersion: Int
    let installed: [InstalledDataset]
    let wanted: [WantedDataset]
}

enum DatasetSyncStatus: String, Equatable, Sendable {
    case upToDate
    case missing
    case updateAvailable
    case notAllowed
    case deprecated
    case revoked
    case incompatible
    case unavailable
    case unknownDataset
}

enum DatasetSyncDecision: String, Equatable, Sendable {
    case install
    case keep
    case update
    case revoke
    case incompatible
    case forbidden
    case deprecated
    case unavailable
}

struct DatasetSyncAction: Equatable, Sendable {
    let key: DatasetKey
    let status: DatasetSyncStatus
    let installedVersion: DatasetVersion?
    let latestVersion: DatasetVersion?
    let latestVersionID: DatasetVersionID?
    let sqliteSchemaVersion: Int?
    let compressedSizeBytes: Int64?
    let checksumSHA256: String?
    let requiredPlan: AccessPlan?

    var decision: DatasetSyncDecision {
        switch status {
        case .missing:
            .install
        case .upToDate:
            .keep
        case .updateAvailable:
            .update
        case .revoked:
            .revoke
        case .incompatible:
            .incompatible
        case .notAllowed:
            .forbidden
        case .deprecated:
            .deprecated
        case .unavailable, .unknownDataset:
            .unavailable
        }
    }

    init(
        key: DatasetKey,
        status: DatasetSyncStatus,
        installedVersion: DatasetVersion?,
        latestVersion: DatasetVersion?,
        latestVersionID: DatasetVersionID? = nil,
        sqliteSchemaVersion: Int? = nil,
        compressedSizeBytes: Int64? = nil,
        checksumSHA256: String? = nil,
        requiredPlan: AccessPlan? = nil
    ) {
        self.key = key
        self.status = status
        self.installedVersion = installedVersion
        self.latestVersion = latestVersion
        self.latestVersionID = latestVersionID
        self.sqliteSchemaVersion = sqliteSchemaVersion
        self.compressedSizeBytes = compressedSizeBytes
        self.checksumSHA256 = checksumSHA256
        self.requiredPlan = requiredPlan
    }
}

struct DatasetSyncResult: Equatable, Sendable {
    let schemaVersion: Int
    let actions: [DatasetSyncAction]
}

struct DatasetDownloadURL: Equatable, Sendable {
    let url: URL
    let expiresAt: Date
    let checksumSHA256: String
    let compressedSizeBytes: Int64
    let compression: DatasetCompression
}
