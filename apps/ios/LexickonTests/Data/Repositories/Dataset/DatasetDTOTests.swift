import Foundation
import XCTest
@testable import Lexickon

final class DatasetDTOTests: XCTestCase {
    func testManifestMapsMetadataAndAvailability() throws {
        let dto = try decodeManifest(
            items: [
                item(key: "core-en", schemaVersion: 1, plan: "free"),
                item(key: "medicine-en", domain: "medicine", schemaVersion: 1, plan: "pro"),
                item(key: "future-en", domain: "future", schemaVersion: 2, plan: "free"),
                item(key: "retired-en", domain: "retired", schemaVersion: 1, status: "revoked")
            ]
        )

        let manifest = dto.domainModel(
            clientSchemaVersion: 1,
            accessiblePlans: [AccessPlan(rawValue: "free")]
        )

        XCTAssertEqual(manifest.state, .partiallyUnavailable)
        XCTAssertEqual(manifest.datasets.map(\.availability), [
            .available, .forbidden, .incompatible, .revoked
        ])
        XCTAssertEqual(manifest.datasets[0].fileSizeBytes, 200)
        XCTAssertEqual(manifest.datasets[0].compressedSizeBytes, 100)
        XCTAssertEqual(manifest.datasets[0].latestVersionID, DatasetVersionID(rawValue: "version-1"))
    }

    func testInvalidManifestItemIsPreservedAsUnavailable() throws {
        let invalid = item(key: "core-en")
            .replacingOccurrences(of: String(repeating: "a", count: 64), with: "broken")
        let dto = try decodeManifest(items: [invalid])

        let manifest = dto.domainModel(
            clientSchemaVersion: 1,
            accessiblePlans: [AccessPlan(rawValue: "free")]
        )

        XCTAssertEqual(manifest.datasets.count, 1)
        XCTAssertEqual(manifest.datasets[0].availability, .unavailable)
        XCTAssertEqual(manifest.state, .partiallyUnavailable)
    }

    func testEmptyManifestHasExplicitEmptyState() throws {
        let manifest = try decodeManifest(items: []).domainModel(
            clientSchemaVersion: 1,
            accessiblePlans: [AccessPlan(rawValue: "free")]
        )

        XCTAssertEqual(manifest.state, .empty)
        XCTAssertEqual(manifest.datasets, [])
    }

    func testCatalogFiltersAndSortsByLanguageThenDomain() throws {
        let dto = try decodeManifest(items: [
            item(key: "programming-ru", language: "ru", domain: "programming"),
            item(key: "medicine-en", domain: "medicine"),
            item(key: "core-en", domain: "core")
        ])
        let manifest = dto.domainModel(
            clientSchemaVersion: 1,
            accessiblePlans: [AccessPlan(rawValue: "free")]
        )

        XCTAssertEqual(
            manifest.filtered().map(\.key.rawValue),
            ["core-en", "medicine-en", "programming-ru"]
        )
        XCTAssertEqual(
            manifest.filtered(language: LanguageCode(rawValue: "en")).map(\.key.rawValue),
            ["core-en", "medicine-en"]
        )
        XCTAssertEqual(
            manifest.filtered(domain: DatasetDomain(rawValue: "programming")).map(\.key.rawValue),
            ["programming-ru"]
        )
    }

    func testSyncResponseMapsToDomainAvailability() {
        let response = DatasetSyncResponseDTO(
            schemaVersion: 1,
            actions: [
                DatasetSyncActionDTO(
                    datasetKey: "core-en",
                    status: "update_available",
                    installedVersion: "1.0.0",
                    latestVersion: "1.1.0",
                    versionId: "version-2",
                    sqliteSchemaVersion: 1,
                    compressedSizeBytes: 100,
                    checksumSha256: String(repeating: "a", count: 64),
                    requiredPlan: "free"
                )
            ]
        )

        XCTAssertEqual(
            response.domainModel,
            DatasetSyncAvailability(
                schemaVersion: 1,
                entries: [
                    DatasetSyncAvailabilityEntry(
                        key: DatasetKey(rawValue: "core-en"),
                        status: .updateAvailable
                    )
                ]
            )
        )
    }

    private func decodeManifest(items: [String]) throws -> DatasetManifestDTO {
        let data = Data(
            """
            {
              "schema_version": 1,
              "generated_at": "2026-09-04T00:00:00Z",
              "datasets": [\(items.joined(separator: ","))]
            }
            """.utf8
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DatasetManifestDTO.self, from: data)
    }

    private func item(
        key: String,
        language: String = "en",
        domain: String = "core",
        schemaVersion: Int = 1,
        plan: String = "free",
        status: String = "active"
    ) -> String {
        """
        {
          "dataset_key": "\(key)",
          "language": "\(language)",
          "domain": "\(domain)",
          "title": "\(domain.capitalized)",
          "latest_version": "1.0.0",
          "version_id": "version-1",
          "sqlite_schema_version": \(schemaVersion),
          "compression": "gzip",
          "file_size_bytes": 200,
          "compressed_size_bytes": 100,
          "checksum_sha256": "\(String(repeating: "a", count: 64))",
          "required_plan": "\(plan)",
          "status": "\(status)"
        }
        """
    }
}
