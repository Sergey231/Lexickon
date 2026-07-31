struct Dataset: Equatable, Sendable {
    let key: DatasetKey
    let language: LanguageCode
    let domain: DatasetDomain
    let title: String
    let latestVersion: DatasetVersion
    let latestVersionID: DatasetVersionID
    let sqliteSchemaVersion: Int
    let compression: DatasetCompression
    let compressedSizeBytes: Int64
    let checksumSHA256: String
    let requiredPlan: AccessPlan
    let status: DatasetStatus
}
