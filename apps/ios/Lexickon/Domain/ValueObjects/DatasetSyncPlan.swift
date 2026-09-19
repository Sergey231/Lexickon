struct DatasetSyncAvailability: Equatable, Sendable {
    let schemaVersion: Int
    let entries: [DatasetSyncAvailabilityEntry]
}

struct DatasetSyncAvailabilityEntry: Equatable, Sendable {
    let key: DatasetKey
    let status: DatasetSyncStatus
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

struct DatasetSyncPlan: Equatable, Sendable {
    let schemaVersion: Int
    let actions: [DatasetSyncAction]
}
