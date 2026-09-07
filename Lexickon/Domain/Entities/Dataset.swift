import Foundation

struct Dataset: Equatable, Sendable {
    let key: DatasetKey
    let language: LanguageCode
    let domain: DatasetDomain
    let title: String
    let latestVersion: DatasetVersion
    let latestVersionID: DatasetVersionID
    let sqliteSchemaVersion: Int
    let compression: DatasetCompression
    let fileSizeBytes: Int64
    let compressedSizeBytes: Int64
    let checksumSHA256: String
    let requiredPlan: AccessPlan
    let status: DatasetStatus
    let availability: DatasetAvailability

    init(
        key: DatasetKey,
        language: LanguageCode,
        domain: DatasetDomain,
        title: String,
        latestVersion: DatasetVersion,
        latestVersionID: DatasetVersionID,
        sqliteSchemaVersion: Int,
        compression: DatasetCompression,
        fileSizeBytes: Int64? = nil,
        compressedSizeBytes: Int64,
        checksumSHA256: String,
        requiredPlan: AccessPlan,
        status: DatasetStatus,
        availability: DatasetAvailability? = nil
    ) {
        self.key = key
        self.language = language
        self.domain = domain
        self.title = title
        self.latestVersion = latestVersion
        self.latestVersionID = latestVersionID
        self.sqliteSchemaVersion = sqliteSchemaVersion
        self.compression = compression
        self.fileSizeBytes = fileSizeBytes ?? compressedSizeBytes
        self.compressedSizeBytes = compressedSizeBytes
        self.checksumSHA256 = checksumSHA256
        self.requiredPlan = requiredPlan
        self.status = status
        self.availability = availability ?? Self.availability(for: status)
    }

    private static func availability(for status: DatasetStatus) -> DatasetAvailability {
        switch status {
        case .active:
            .available
        case .deprecated:
            .deprecated
        case .revoked:
            .revoked
        case .unavailable:
            .unavailable
        }
    }
}

struct DatasetManifest: Equatable, Sendable {
    let schemaVersion: Int
    let generatedAt: Date
    let datasets: [Dataset]

    var state: DatasetCatalogState {
        guard !datasets.isEmpty else { return .empty }
        return datasets.contains { $0.availability != .available }
            ? .partiallyUnavailable
            : .available
    }

    func filtered(
        language: LanguageCode? = nil,
        domain: DatasetDomain? = nil,
        availability: DatasetAvailability? = nil
    ) -> [Dataset] {
        datasets
            .filter { dataset in
                (language == nil || dataset.language == language)
                    && (domain == nil || dataset.domain == domain)
                    && (availability == nil || dataset.availability == availability)
            }
            .sorted(by: Dataset.catalogOrder)
    }
}

enum DatasetCatalogState: String, Equatable, Sendable {
    case empty
    case available
    case partiallyUnavailable
}

private extension Dataset {
    static func catalogOrder(_ lhs: Dataset, _ rhs: Dataset) -> Bool {
        let lhsKey = (
            lhs.language.rawValue.lowercased(),
            lhs.domain.rawValue.lowercased(),
            lhs.title.lowercased(),
            lhs.key.rawValue.lowercased()
        )
        let rhsKey = (
            rhs.language.rawValue.lowercased(),
            rhs.domain.rawValue.lowercased(),
            rhs.title.lowercased(),
            rhs.key.rawValue.lowercased()
        )
        if lhsKey.0 != rhsKey.0 { return lhsKey.0 < rhsKey.0 }
        if lhsKey.1 != rhsKey.1 { return lhsKey.1 < rhsKey.1 }
        if lhsKey.2 != rhsKey.2 { return lhsKey.2 < rhsKey.2 }
        return lhsKey.3 < rhsKey.3
    }
}
