import Foundation

struct DatasetRepositoryImpl: DatasetRepository {
    private let apiClient: APIClient
    private let registry: any InstalledDatasetRegistry
    private let supportedSchemaVersion: Int
    private let accessiblePlans: Set<AccessPlan>
    private let planner: DatasetSyncPlanner

    init(
        apiClient: APIClient,
        registry: any InstalledDatasetRegistry,
        supportedSchemaVersion: Int = 1,
        accessiblePlans: Set<AccessPlan> = [AccessPlan(rawValue: "free")],
        planner: DatasetSyncPlanner = DatasetSyncPlanner()
    ) {
        self.apiClient = apiClient
        self.registry = registry
        self.supportedSchemaVersion = supportedSchemaVersion
        self.accessiblePlans = accessiblePlans
        self.planner = planner
    }

    func catalog() async throws -> DatasetManifest {
        do {
            return try await apiClient
                .send(DatasetManifestAPIRequest())
                .domainModel(
                    clientSchemaVersion: supportedSchemaVersion,
                    accessiblePlans: accessiblePlans
                )
        } catch {
            throw map(error)
        }
    }

    func installedDatasets() async throws -> [InstalledDataset] {
        do {
            return try await registry.installedDatasets()
        } catch {
            throw map(error)
        }
    }

    func synchronize(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult {
        do {
            let installed = try await registry.installedDatasets()
            let manifestDTO = try await apiClient.send(DatasetManifestAPIRequest())
            let manifest = manifestDTO.domainModel(
                clientSchemaVersion: request.clientSchemaVersion,
                accessiblePlans: accessiblePlans
            )
            let response = try await apiClient.send(
                DatasetSyncAPIRequest(
                    clientSchemaVersion: request.clientSchemaVersion,
                    installed: installed,
                    wanted: request.wanted
                )
            )
            let result = planner.makePlan(
                manifest: manifest,
                installed: installed,
                request: request,
                serverResponse: response
            )
            try await persistUpdateStates(from: result, installed: installed)
            return result
        } catch {
            throw map(error)
        }
    }

    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL {
        do {
            let response = try await apiClient.send(
                DatasetDownloadURLAPIRequest(versionID: versionID)
            )
            guard let downloadURL = response.domainModel else {
                throw AppError.transport(.invalidResponse)
            }
            return downloadURL
        } catch {
            throw map(error)
        }
    }

    private func persistUpdateStates(
        from result: DatasetSyncResult,
        installed: [InstalledDataset]
    ) async throws {
        let statusByKey = Dictionary(uniqueKeysWithValues: result.actions.map { ($0.key, $0.status) })
        let updated = installed.map { dataset in
            InstalledDataset(
                key: dataset.key,
                version: dataset.version,
                sqliteSchemaVersion: dataset.sqliteSchemaVersion,
                checksumSHA256: dataset.checksumSHA256,
                installedAt: dataset.installedAt,
                updateState: Self.updateState(for: statusByKey[dataset.key])
            )
        }
        try await registry.replace(with: updated)
    }

    private static func updateState(for status: DatasetSyncStatus?) -> InstalledDatasetUpdateState {
        switch status {
        case .upToDate, .missing, .none:
            .current
        case .updateAvailable:
            .updateAvailable
        case .notAllowed:
            .forbidden
        case .deprecated:
            .deprecated
        case .revoked:
            .revoked
        case .incompatible:
            .incompatible
        case .unavailable, .unknownDataset:
            .unavailable
        }
    }

    // A single exhaustive boundary keeps infrastructure errors out of Domain.
    // swiftlint:disable:next cyclomatic_complexity
    private func map(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        if let registryError = error as? DatasetRegistryError {
            switch registryError {
            case .readFailed:
                return .localStorage(.readFailed)
            case .writeFailed:
                return .localStorage(.writeFailed)
            case .corrupted, .unsupportedSchemaVersion:
                return .localStorage(.corrupted)
            }
        }
        guard let networkError = error as? NetworkError else {
            return .unexpected(.invariantViolation)
        }
        switch networkError {
        case .cancelled:
            return .cancelled
        case .offline:
            return .transport(.offline)
        case .timedOut:
            return .transport(.timedOut)
        case .transport:
            return .transport(.unreachable)
        case .forbidden:
            return .dataset(.notAllowed)
        case .notFound:
            return .dataset(.unknownDataset)
        case let .conflict(code):
            if code?.localizedCaseInsensitiveContains("revoked") == true {
                return .dataset(.revoked)
            }
            if code?.localizedCaseInsensitiveContains("deprecated") == true {
                return .dataset(.deprecated)
            }
            return .dataset(.unavailable)
        case .unauthenticated:
            return .authorization(.unauthenticated)
        case .unauthorized:
            return .authorization(.sessionExpired)
        case .server(let statusCode, _), .unexpectedStatus(let statusCode, _):
            return .transport(.server(statusCode: statusCode))
        case .invalidRequest, .invalidResponse, .decoding, .badRequest:
            return .transport(.invalidResponse)
        }
    }
}
