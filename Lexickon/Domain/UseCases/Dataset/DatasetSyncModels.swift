struct InstalledDataset: Equatable, Sendable {
    let key: DatasetKey
    let version: DatasetVersion
    let sqliteSchemaVersion: Int
    let checksumSHA256: String
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
    case unknownDataset
}

struct DatasetSyncAction: Equatable, Sendable {
    let key: DatasetKey
    let status: DatasetSyncStatus
    let installedVersion: DatasetVersion?
    let latestVersion: DatasetVersion?
}

struct DatasetSyncResult: Equatable, Sendable {
    let schemaVersion: Int
    let actions: [DatasetSyncAction]
}
