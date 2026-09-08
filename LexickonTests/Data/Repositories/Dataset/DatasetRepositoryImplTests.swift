import Foundation
import XCTest
@testable import Lexickon

final class DatasetRepositoryImplTests: XCTestCase, @unchecked Sendable {
    // The complete flow is intentionally kept in one test so the request order is explicit.
    // swiftlint:disable:next function_body_length
    func testManifestToSyncPlanToSignedURLFlowUsesRegistryAsSourceOfTruth() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
            .appending(path: "installed-datasets.json")
        let registry = FileInstalledDatasetRegistry(fileURL: fileURL)
        try await registry.upsert(
            InstalledDataset(
                key: DatasetKey(rawValue: "core-en"),
                version: DatasetVersion(rawValue: "1.0.0"),
                sqliteSchemaVersion: 1,
                checksumSHA256: String(repeating: "a", count: 64),
                installedAt: Date(timeIntervalSince1970: 1)
            )
        )
        let session = SessionController(tokenStore: InMemoryTokenStore())
        try await session.establishSession(with: try XCTUnwrap(AccessToken(rawValue: "token")))
        let repository = DatasetRepositoryImpl(
            apiClient: makeClient(session: session),
            registry: registry
        )

        URLProtocolStub.registry.setHandler { request in
            switch request.url?.path {
            case "/v1/datasets/manifest":
                return .response(Self.response(for: request), Self.manifestData)
            case "/v1/datasets/sync":
                return .response(Self.response(for: request), Self.syncData)
            case "/v1/datasets/versions/version-2/download-url":
                XCTAssertEqual(
                    request.value(forHTTPHeaderField: "Authorization"),
                    "Bearer token"
                )
                return .response(Self.response(for: request), Self.downloadURLData)
            default:
                return .response(Self.response(for: request, statusCode: 404), Data())
            }
        }

        let manifest = try await repository.catalog()
        let result = try await repository.synchronize(
            DatasetSyncRequest(
                clientSchemaVersion: 1,
                installed: [
                    InstalledDataset(
                        key: DatasetKey(rawValue: "core-en"),
                        version: DatasetVersion(rawValue: "9.0.0"),
                        sqliteSchemaVersion: 1,
                        checksumSHA256: String(repeating: "f", count: 64)
                    )
                ],
                wanted: [
                    WantedDataset(
                        language: LanguageCode(rawValue: "en"),
                        domain: DatasetDomain(rawValue: "core")
                    )
                ]
            )
        )
        let download = try await repository.downloadURL(
            for: try XCTUnwrap(result.actions.first?.latestVersionID)
        )
        let persisted = try await registry.installedDatasets()
        let registryText = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertEqual(manifest.state, .available)
        XCTAssertEqual(result.actions.map(\.status), [.updateAvailable])
        XCTAssertEqual(persisted.map(\.updateState), [.updateAvailable])
        XCTAssertEqual(download.url.absoluteString, "https://storage.test/core.sqlite.gz?signature=secret")
        XCTAssertFalse(registryText.contains("storage.test"))
        XCTAssertFalse(registryText.contains("signature"))
    }

    func testRevokedDownloadResponseMapsToDatasetError() async throws {
        let session = SessionController(tokenStore: InMemoryTokenStore())
        try await session.establishSession(with: try XCTUnwrap(AccessToken(rawValue: "token")))
        let repository = DatasetRepositoryImpl(
            apiClient: makeClient(session: session),
            registry: FileInstalledDatasetRegistry(
                fileURL: FileManager.default.temporaryDirectory
                    .appending(path: UUID().uuidString)
                    .appending(path: "registry.json")
            )
        )
        URLProtocolStub.registry.setHandler { request in
            .response(
                Self.response(for: request, statusCode: 409),
                Data(#"{"detail":"Dataset version is revoked"}"#.utf8)
            )
        }

        do {
            _ = try await repository.downloadURL(for: DatasetVersionID(rawValue: "revoked"))
            XCTFail("Expected revoked error")
        } catch let error as AppError {
            XCTAssertEqual(error, .dataset(.revoked))
        }
    }

    private func makeClient(session: SessionController) -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return APIClient(
            baseURL: URL(string: "https://api.unit.test/v1")!,
            transport: URLSessionTransport(session: URLSession(configuration: configuration)),
            session: session
        )
    }

    private static func response(
        for request: URLRequest,
        statusCode: Int = 200
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }

    private static let manifestData = Data(
        """
        {
          "schema_version": 1,
          "generated_at": "2026-09-04T00:00:00Z",
          "datasets": [{
            "dataset_key": "core-en",
            "language": "en",
            "domain": "core",
            "title": "Core English",
            "latest_version": "1.1.0",
            "version_id": "version-2",
            "sqlite_schema_version": 1,
            "compression": "gzip",
            "file_size_bytes": 200,
            "compressed_size_bytes": 100,
            "checksum_sha256": "\(String(repeating: "b", count: 64))",
            "required_plan": "free",
            "status": "active"
          }]
        }
        """.utf8
    )

    private static let syncData = Data(
        """
        {
          "schema_version": 1,
          "actions": [{
            "dataset_key": "core-en",
            "status": "update_available",
            "installed_version": "1.0.0",
            "latest_version": "1.1.0",
            "version_id": "version-2",
            "sqlite_schema_version": 1,
            "compressed_size_bytes": 100,
            "checksum_sha256": "\(String(repeating: "b", count: 64))",
            "required_plan": "free"
          }]
        }
        """.utf8
    )

    private static let downloadURLData = Data(
        """
        {
          "url": "https://storage.test/core.sqlite.gz?signature=secret",
          "expires_at": "2026-09-04T00:15:00Z",
          "checksum_sha256": "\(String(repeating: "b", count: 64))",
          "compressed_size_bytes": 100,
          "compression": "gzip"
        }
        """.utf8
    )
}
