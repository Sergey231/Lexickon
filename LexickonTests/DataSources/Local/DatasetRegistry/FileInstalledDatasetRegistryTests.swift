import Foundation
import XCTest
@testable import Lexickon

final class FileInstalledDatasetRegistryTests: XCTestCase {
    func testRoundTripPreservesInstallationMetadataAndUpdateState() async throws {
        let fileURL = temporaryFileURL()
        let registry = FileInstalledDatasetRegistry(fileURL: fileURL)
        let expected = InstalledDataset(
            key: DatasetKey(rawValue: "core-en"),
            version: DatasetVersion(rawValue: "1.2.0"),
            sqliteSchemaVersion: 1,
            checksumSHA256: String(repeating: "a", count: 64),
            installedAt: Date(timeIntervalSince1970: 1_700_000_000),
            updateState: .updateAvailable
        )

        try await registry.upsert(expected)
        let actual = try await registry.installedDatasets()

        XCTAssertEqual(actual, [expected])
    }

    func testLegacyRegistryMigratesAndCorruptedRecordIsDiscarded() async throws {
        let fileURL = temporaryFileURL()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let legacy = """
        [
          {
            "dataset_key": "core-en",
            "version": "1.0.0",
            "sqlite_schema_version": 1,
            "checksum_sha256": "\(String(repeating: "a", count: 64))"
          },
          {
            "dataset_key": "broken-en",
            "version": "1.0.0",
            "sqlite_schema_version": 1,
            "checksum_sha256": "broken"
          }
        ]
        """
        try Data(legacy.utf8).write(to: fileURL)
        let registry = FileInstalledDatasetRegistry(fileURL: fileURL)

        let installed = try await registry.installedDatasets()
        let migratedData = try Data(contentsOf: fileURL)
        let migratedJSON = try XCTUnwrap(
            JSONSerialization.jsonObject(with: migratedData) as? [String: Any]
        )

        XCTAssertEqual(installed.map(\.key.rawValue), ["core-en"])
        XCTAssertEqual(installed[0].installedAt, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(migratedJSON["schema_version"] as? Int, 1)
        XCTAssertEqual((migratedJSON["datasets"] as? [Any])?.count, 1)
    }

    func testDuplicateKeysAreNotDeclaredInstalled() async throws {
        let fileURL = temporaryFileURL()
        let registry = FileInstalledDatasetRegistry(fileURL: fileURL)
        let first = installed(version: "1.0.0")
        let second = installed(version: "2.0.0")

        try await registry.replace(with: [first, second])
        let result = try await registry.installedDatasets()

        XCTAssertEqual(result, [])
    }

    func testMalformedTopLevelRegistryThrowsCorrupted() async throws {
        let fileURL = temporaryFileURL()
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL)
        let registry = FileInstalledDatasetRegistry(fileURL: fileURL)

        do {
            _ = try await registry.installedDatasets()
            XCTFail("Expected corrupted registry")
        } catch let error as DatasetRegistryError {
            XCTAssertEqual(error, .corrupted)
        }
    }

    private func installed(version: String) -> InstalledDataset {
        InstalledDataset(
            key: DatasetKey(rawValue: "core-en"),
            version: DatasetVersion(rawValue: version),
            sqliteSchemaVersion: 1,
            checksumSHA256: String(repeating: "a", count: 64),
            installedAt: Date(timeIntervalSince1970: 1)
        )
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
            .appending(path: "installed-datasets.json")
    }
}
