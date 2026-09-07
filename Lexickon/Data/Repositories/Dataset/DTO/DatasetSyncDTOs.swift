import Foundation

struct DatasetSyncRequestDTO: Encodable, Sendable {
    let clientSchemaVersion: Int
    let installed: [InstalledDatasetDTO]
    let wanted: [WantedDatasetDTO]
}

struct InstalledDatasetDTO: Encodable, Sendable {
    let datasetKey: String
    let version: String
    let sqliteSchemaVersion: Int
    let checksumSha256: String

    init(_ dataset: InstalledDataset) {
        datasetKey = dataset.key.rawValue
        version = dataset.version.rawValue
        sqliteSchemaVersion = dataset.sqliteSchemaVersion
        checksumSha256 = dataset.checksumSHA256
    }
}

struct WantedDatasetDTO: Encodable, Sendable {
    let language: String
    let domain: String

    init(_ dataset: WantedDataset) {
        language = dataset.language.rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        domain = dataset.domain.rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

struct DatasetSyncResponseDTO: Decodable, Sendable {
    let schemaVersion: Int
    let actions: [DatasetSyncActionDTO]
}

struct DatasetSyncActionDTO: Decodable, Sendable {
    let datasetKey: String
    let status: String
    let installedVersion: String?
    let latestVersion: String?
    let versionId: String?
    let sqliteSchemaVersion: Int?
    let compressedSizeBytes: Int64?
    let checksumSha256: String?
    let requiredPlan: String?

    var domainStatus: DatasetSyncStatus {
        switch status {
        case "up_to_date": .upToDate
        case "missing": .missing
        case "update_available": .updateAvailable
        case "not_allowed": .notAllowed
        case "deprecated": .deprecated
        case "revoked": .revoked
        case "incompatible": .incompatible
        case "unknown_dataset": .unknownDataset
        default: .unavailable
        }
    }
}
