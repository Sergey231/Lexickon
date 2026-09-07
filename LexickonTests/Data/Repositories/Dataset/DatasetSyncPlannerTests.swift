import Foundation
import XCTest
@testable import Lexickon

final class DatasetSyncPlannerTests: XCTestCase {
    func testDecisionTable() {
        let cases: [DecisionCase] = [
            DecisionCase(name: "install", localVersion: nil, targetVersion: "1.0.0", expected: .missing),
            DecisionCase(name: "keep", localVersion: "1.0.0", targetVersion: "1.0.0", expected: .upToDate),
            DecisionCase(
                name: "update",
                localVersion: "1.0.0",
                targetVersion: "1.1.0",
                expected: .updateAvailable
            ),
            DecisionCase(
                name: "no downgrade",
                localVersion: "2.0.0",
                targetVersion: "1.1.0",
                expected: .upToDate
            ),
            DecisionCase(
                name: "revoke",
                localVersion: "1.0.0",
                targetVersion: "1.1.0",
                serverStatus: "revoked",
                expected: .revoked
            ),
            DecisionCase(
                name: "incompatible",
                localVersion: "1.0.0",
                targetVersion: "1.1.0",
                availability: .incompatible,
                expected: .incompatible
            ),
            DecisionCase(
                name: "forbidden",
                localVersion: nil,
                targetVersion: "1.0.0",
                availability: .forbidden,
                expected: .notAllowed
            )
        ]

        for testCase in cases {
            let result = makeResult(testCase)
            XCTAssertEqual(result.actions.map(\.status), [testCase.expected], testCase.name)
            XCTAssertEqual(
                result.actions.map(\.decision),
                [expectedDecision(for: testCase.expected)],
                testCase.name
            )
            if testCase.expected != .missing && testCase.expected != .updateAvailable {
                XCTAssertNil(result.actions[0].latestVersionID, testCase.name)
            }
        }
    }

    private func expectedDecision(for status: DatasetSyncStatus) -> DatasetSyncDecision {
        DatasetSyncAction(
            key: DatasetKey(rawValue: "test"),
            status: status,
            installedVersion: nil,
            latestVersion: nil
        ).decision
    }

    func testSameInputsAlwaysProduceSamePlanAndStableOrdering() {
        let planner = DatasetSyncPlanner()
        let manifest = DatasetManifest(
            schemaVersion: 1,
            generatedAt: Date(timeIntervalSince1970: 1),
            datasets: [dataset(domain: "medicine"), dataset(domain: "core")]
        )
        let request = DatasetSyncRequest(
            clientSchemaVersion: 1,
            installed: [],
            wanted: [
                WantedDataset(language: LanguageCode(rawValue: "en"), domain: DatasetDomain(rawValue: "medicine")),
                WantedDataset(language: LanguageCode(rawValue: "en"), domain: DatasetDomain(rawValue: "core")),
                WantedDataset(language: LanguageCode(rawValue: "en"), domain: DatasetDomain(rawValue: "core"))
            ]
        )
        let response = DatasetSyncResponseDTO(
            schemaVersion: 1,
            actions: [actionDTO(key: "medicine-en"), actionDTO(key: "core-en")]
        )

        let first = planner.makePlan(
            manifest: manifest,
            installed: [],
            request: request,
            serverResponse: response
        )
        let second = planner.makePlan(
            manifest: manifest,
            installed: [],
            request: request,
            serverResponse: response
        )

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.actions.map(\.key.rawValue), ["core-en", "medicine-en"])
    }

    func testImmutableVersionMetadataMismatchIsNotSelectedForUpdate() {
        let testCase = DecisionCase(
            name: "metadata mismatch",
            localVersion: "1.0.0",
            targetVersion: "1.0.0",
            expected: .unavailable,
            localChecksum: String(repeating: "b", count: 64)
        )

        let result = makeResult(testCase)

        XCTAssertEqual(result.actions[0].status, .unavailable)
        XCTAssertNil(result.actions[0].latestVersionID)
    }

    private func makeResult(_ testCase: DecisionCase) -> DatasetSyncResult {
        let planner = DatasetSyncPlanner()
        let target = dataset(
            version: testCase.targetVersion,
            availability: testCase.availability
        )
        let local = testCase.localVersion.map {
            InstalledDataset(
                key: target.key,
                version: DatasetVersion(rawValue: $0),
                sqliteSchemaVersion: 1,
                checksumSHA256: testCase.localChecksum
            )
        }
        let request = DatasetSyncRequest(
            clientSchemaVersion: 1,
            installed: local.map { [$0] } ?? [],
            wanted: [WantedDataset(language: target.language, domain: target.domain)]
        )
        let response = DatasetSyncResponseDTO(
            schemaVersion: 1,
            actions: [actionDTO(key: target.key.rawValue, status: testCase.serverStatus)]
        )
        return planner.makePlan(
            manifest: DatasetManifest(
                schemaVersion: 1,
                generatedAt: Date(timeIntervalSince1970: 1),
                datasets: [target]
            ),
            installed: local.map { [$0] } ?? [],
            request: request,
            serverResponse: response
        )
    }

    private func dataset(
        domain: String = "core",
        version: String = "1.0.0",
        availability: DatasetAvailability = .available
    ) -> Dataset {
        Dataset(
            key: DatasetKey(rawValue: "\(domain)-en"),
            language: LanguageCode(rawValue: "en"),
            domain: DatasetDomain(rawValue: domain),
            title: domain.capitalized,
            latestVersion: DatasetVersion(rawValue: version),
            latestVersionID: DatasetVersionID(rawValue: "version-\(domain)"),
            sqliteSchemaVersion: availability == .incompatible ? 2 : 1,
            compression: .gzip,
            fileSizeBytes: 200,
            compressedSizeBytes: 100,
            checksumSHA256: String(repeating: "a", count: 64),
            requiredPlan: AccessPlan(rawValue: availability == .forbidden ? "pro" : "free"),
            status: .active,
            availability: availability
        )
    }

    private func actionDTO(key: String, status: String = "missing") -> DatasetSyncActionDTO {
        DatasetSyncActionDTO(
            datasetKey: key,
            status: status,
            installedVersion: nil,
            latestVersion: "1.0.0",
            versionId: "version-1",
            sqliteSchemaVersion: 1,
            compressedSizeBytes: 100,
            checksumSha256: String(repeating: "a", count: 64),
            requiredPlan: "free"
        )
    }
}

private struct DecisionCase {
    let name: String
    let localVersion: String?
    let targetVersion: String
    let serverStatus: String
    let availability: DatasetAvailability
    let expected: DatasetSyncStatus
    let localChecksum: String

    init(
        name: String,
        localVersion: String?,
        targetVersion: String,
        serverStatus: String = "update_available",
        availability: DatasetAvailability = .available,
        expected: DatasetSyncStatus,
        localChecksum: String = String(repeating: "a", count: 64)
    ) {
        self.name = name
        self.localVersion = localVersion
        self.targetVersion = targetVersion
        self.serverStatus = serverStatus
        self.availability = availability
        self.expected = expected
        self.localChecksum = localChecksum
    }
}
