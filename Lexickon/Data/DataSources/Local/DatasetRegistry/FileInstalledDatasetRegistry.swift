import Foundation

actor FileInstalledDatasetRegistry: InstalledDatasetRegistry {
    static let currentSchemaVersion = 1

    private let fileURL: URL
    private let fileManager: FileManager

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    func installedDatasets() throws -> [InstalledDataset] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw DatasetRegistryError.readFailed
        }

        let decoded = try decode(data)
        if decoded.requiresMigration {
            try write(decoded.datasets)
        }
        return decoded.datasets
    }

    func replace(with datasets: [InstalledDataset]) throws {
        try write(sanitized(datasets))
    }

    func upsert(_ dataset: InstalledDataset) throws {
        guard Self.isValid(dataset) else {
            throw DatasetRegistryError.corrupted
        }
        var datasets = try installedDatasets()
        datasets.removeAll { $0.key == dataset.key }
        datasets.append(dataset)
        try write(datasets)
    }

    func remove(key: DatasetKey) throws {
        var datasets = try installedDatasets()
        datasets.removeAll { $0.key == key }
        try write(datasets)
    }

    private func decode(_ data: Data) throws -> DecodedRegistry {
        let json: Any
        do {
            json = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw DatasetRegistryError.corrupted
        }

        let rawRecords: [Any]
        let requiresMigration: Bool
        if let object = json as? [String: Any] {
            let schemaVersion = object["schema_version"] as? Int ?? 0
            guard schemaVersion <= Self.currentSchemaVersion else {
                throw DatasetRegistryError.unsupportedSchemaVersion(schemaVersion)
            }
            guard let records = object["datasets"] as? [Any] else {
                throw DatasetRegistryError.corrupted
            }
            rawRecords = records
            requiresMigration = schemaVersion < Self.currentSchemaVersion
        } else if let records = json as? [Any] {
            rawRecords = records
            requiresMigration = true
        } else {
            throw DatasetRegistryError.corrupted
        }

        let decoder = Self.makeDecoder()
        let records = rawRecords.compactMap { value -> InstalledDataset? in
            guard JSONSerialization.isValidJSONObject(value),
                  let recordData = try? JSONSerialization.data(withJSONObject: value),
                  let record = try? decoder.decode(InstalledDatasetRecord.self, from: recordData),
                  let domain = record.domainModel,
                  Self.isValid(domain) else {
                return nil
            }
            return domain
        }

        return DecodedRegistry(
            datasets: sanitized(records),
            requiresMigration: requiresMigration
        )
    }

    private func sanitized(_ datasets: [InstalledDataset]) -> [InstalledDataset] {
        let valid = datasets.filter(Self.isValid)
        let counts = Dictionary(grouping: valid, by: \.key).mapValues(\.count)
        return valid
            .filter { counts[$0.key] == 1 }
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }

    private func write(_ datasets: [InstalledDataset]) throws {
        let envelope = InstalledDatasetRegistryEnvelope(
            schemaVersion: Self.currentSchemaVersion,
            datasets: sanitized(datasets).map(InstalledDatasetRecord.init)
        )

        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try Self.makeEncoder().encode(envelope)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw DatasetRegistryError.writeFailed
        }
    }

    private static func isValid(_ dataset: InstalledDataset) -> Bool {
        let normalizedKey = dataset.key.rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return dataset.key.rawValue == normalizedKey
            && normalizedKey.contains("-")
            && dataset.version.isSemanticVersion
            && dataset.sqliteSchemaVersion > 0
            && dataset.checksumSHA256.count == 64
            && dataset.checksumSHA256.allSatisfy(\.isHexDigit)
            && dataset.installedAt.timeIntervalSince1970.isFinite
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

private struct DecodedRegistry {
    let datasets: [InstalledDataset]
    let requiresMigration: Bool
}

private struct InstalledDatasetRegistryEnvelope: Codable {
    let schemaVersion: Int
    let datasets: [InstalledDatasetRecord]
}

private struct InstalledDatasetRecord: Codable {
    let datasetKey: String
    let dataVersion: String
    let sqliteSchemaVersion: Int
    let checksumSha256: String
    let installedAt: Date?
    let updateState: InstalledDatasetUpdateState?

    init(_ dataset: InstalledDataset) {
        datasetKey = dataset.key.rawValue
        dataVersion = dataset.version.rawValue
        sqliteSchemaVersion = dataset.sqliteSchemaVersion
        checksumSha256 = dataset.checksumSHA256
        installedAt = dataset.installedAt
        updateState = dataset.updateState
    }

    var domainModel: InstalledDataset? {
        InstalledDataset(
            key: DatasetKey(rawValue: datasetKey),
            version: DatasetVersion(rawValue: dataVersion),
            sqliteSchemaVersion: sqliteSchemaVersion,
            checksumSHA256: checksumSha256,
            installedAt: installedAt ?? Date(timeIntervalSince1970: 0),
            updateState: updateState ?? .current
        )
    }

    private enum CodingKeys: String, CodingKey {
        case datasetKey
        case dataVersion
        case version
        case sqliteSchemaVersion
        case checksumSha256
        case installedAt
        case updateState
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        datasetKey = try container.decode(String.self, forKey: .datasetKey)
        dataVersion = try container.decodeIfPresent(String.self, forKey: .dataVersion)
            ?? container.decode(String.self, forKey: .version)
        sqliteSchemaVersion = try container.decode(Int.self, forKey: .sqliteSchemaVersion)
        checksumSha256 = try container.decode(String.self, forKey: .checksumSha256)
        installedAt = try container.decodeIfPresent(Date.self, forKey: .installedAt)
        updateState = try container.decodeIfPresent(
            InstalledDatasetUpdateState.self,
            forKey: .updateState
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datasetKey, forKey: .datasetKey)
        try container.encode(dataVersion, forKey: .dataVersion)
        try container.encode(sqliteSchemaVersion, forKey: .sqliteSchemaVersion)
        try container.encode(checksumSha256, forKey: .checksumSha256)
        try container.encodeIfPresent(installedAt, forKey: .installedAt)
        try container.encodeIfPresent(updateState, forKey: .updateState)
    }
}
