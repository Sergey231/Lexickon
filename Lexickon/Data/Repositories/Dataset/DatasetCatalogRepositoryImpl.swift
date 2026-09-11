import Foundation

struct DatasetCatalogRepositoryImpl: DatasetCatalogRepository {
    private let apiClient: APIClient
    private let supportedSchemaVersion: Int
    private let accessiblePlans: Set<AccessPlan>

    init(
        apiClient: APIClient,
        supportedSchemaVersion: Int = 1,
        accessiblePlans: Set<AccessPlan> = [AccessPlan(rawValue: "free")]
    ) {
        self.apiClient = apiClient
        self.supportedSchemaVersion = supportedSchemaVersion
        self.accessiblePlans = accessiblePlans
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

    func availability(
        installed: [InstalledDataset],
        wanted: [WantedDataset]
    ) async throws -> DatasetSyncAvailability {
        do {
            return try await apiClient.send(
                DatasetSyncAPIRequest(
                    clientSchemaVersion: supportedSchemaVersion,
                    installed: installed,
                    wanted: wanted
                )
            ).domainModel
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

    // A single exhaustive boundary keeps infrastructure errors out of Domain.
    // swiftlint:disable:next cyclomatic_complexity
    private func map(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
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
