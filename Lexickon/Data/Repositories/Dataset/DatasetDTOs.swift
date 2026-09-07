import Foundation

struct DatasetManifestDTO: Decodable, Sendable {
    let schemaVersion: Int
    let generatedAt: Date
    let datasets: [DatasetManifestItemDTO]

    func domainModel(
        clientSchemaVersion: Int,
        accessiblePlans: Set<AccessPlan>
    ) -> DatasetManifest {
        DatasetManifest(
            schemaVersion: schemaVersion,
            generatedAt: generatedAt,
            datasets: datasets.map {
                $0.domainModel(
                    clientSchemaVersion: clientSchemaVersion,
                    accessiblePlans: accessiblePlans
                )
            }
        )
    }
}

struct DatasetManifestItemDTO: Decodable, Sendable {
    let datasetKey: String
    let language: String
    let domain: String
    let title: String
    let latestVersion: String
    let versionId: String
    let sqliteSchemaVersion: Int
    let compression: String
    let fileSizeBytes: Int64
    let compressedSizeBytes: Int64
    let checksumSha256: String
    let requiredPlan: String
    let status: String

    func domainModel(
        clientSchemaVersion: Int,
        accessiblePlans: Set<AccessPlan>
    ) -> Dataset {
        let normalizedKey = normalized(datasetKey)
        let normalizedLanguage = normalized(language)
        let normalizedDomain = normalized(domain)
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let remoteStatus = DatasetStatus(rawValue: normalized(status)) ?? .unavailable
        let compressionModel = DatasetCompression(rawValue: normalized(compression)) ?? .unsupported
        let plan = AccessPlan(rawValue: normalized(requiredPlan))
        let isStructurallyValid = !normalizedLanguage.isEmpty
            && !normalizedDomain.isEmpty
            && !normalizedTitle.isEmpty
            && normalizedKey == "\(normalizedDomain)-\(normalizedLanguage)"
            && DatasetVersion(rawValue: latestVersion).isSemanticVersion
            && !versionId.isEmpty
            && sqliteSchemaVersion > 0
            && fileSizeBytes > 0
            && compressedSizeBytes > 0
            && compressedSizeBytes <= fileSizeBytes
            && checksumSha256.count == 64
            && checksumSha256.allSatisfy(\.isHexDigit)
            && compressionModel != .unsupported

        let availability = availability(
            status: remoteStatus,
            isStructurallyValid: isStructurallyValid,
            isSchemaCompatible: sqliteSchemaVersion <= clientSchemaVersion,
            hasAccess: accessiblePlans.contains(plan)
        )

        return Dataset(
            key: DatasetKey(rawValue: normalizedKey),
            language: LanguageCode(rawValue: normalizedLanguage),
            domain: DatasetDomain(rawValue: normalizedDomain),
            title: normalizedTitle,
            latestVersion: DatasetVersion(rawValue: latestVersion),
            latestVersionID: DatasetVersionID(rawValue: versionId),
            sqliteSchemaVersion: sqliteSchemaVersion,
            compression: compressionModel,
            fileSizeBytes: fileSizeBytes,
            compressedSizeBytes: compressedSizeBytes,
            checksumSHA256: checksumSha256,
            requiredPlan: plan,
            status: remoteStatus,
            availability: availability
        )
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func availability(
        status: DatasetStatus,
        isStructurallyValid: Bool,
        isSchemaCompatible: Bool,
        hasAccess: Bool
    ) -> DatasetAvailability {
        switch status {
        case .revoked:
            .revoked
        case .deprecated:
            .deprecated
        case .unavailable:
            .unavailable
        case .active where !isStructurallyValid:
            .unavailable
        case .active where !isSchemaCompatible:
            .incompatible
        case .active where !hasAccess:
            .forbidden
        case .active:
            .available
        }
    }
}

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

struct DatasetDownloadURLDTO: Decodable, Sendable {
    let url: URL
    let expiresAt: Date
    let checksumSha256: String
    let compressedSizeBytes: Int64
    let compression: String

    var domainModel: DatasetDownloadURL? {
        guard checksumSha256.count == 64,
              checksumSha256.allSatisfy(\.isHexDigit),
              compressedSizeBytes > 0,
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil,
              let compression = DatasetCompression(rawValue: compression),
              compression != .unsupported else {
            return nil
        }
        return DatasetDownloadURL(
            url: url,
            expiresAt: expiresAt,
            checksumSHA256: checksumSha256,
            compressedSizeBytes: compressedSizeBytes,
            compression: compression
        )
    }
}
