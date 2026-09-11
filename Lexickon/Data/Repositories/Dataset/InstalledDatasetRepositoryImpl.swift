struct InstalledDatasetRepositoryImpl: InstalledDatasetRepository {
    private let registry: any InstalledDatasetRegistry

    init(registry: any InstalledDatasetRegistry) {
        self.registry = registry
    }

    func datasets() async throws -> [InstalledDataset] {
        do {
            return try await registry.installedDatasets()
        } catch {
            throw map(error)
        }
    }

    func apply(_ plan: DatasetSyncPlan) async throws {
        do {
            let installed = try await registry.installedDatasets()
            let actionByKey = Dictionary(
                plan.actions.map { ($0.key, $0) },
                uniquingKeysWith: { _, latest in latest }
            )
            let updated = installed.map { dataset in
                guard let action = actionByKey[dataset.key],
                      action.installedVersion == dataset.version else {
                    return dataset
                }
                return InstalledDataset(
                    key: dataset.key,
                    version: dataset.version,
                    sqliteSchemaVersion: dataset.sqliteSchemaVersion,
                    checksumSHA256: dataset.checksumSHA256,
                    installedAt: dataset.installedAt,
                    updateState: Self.updateState(for: action.status)
                )
            }
            try await registry.replace(with: updated)
        } catch {
            throw map(error)
        }
    }

    private static func updateState(
        for status: DatasetSyncStatus
    ) -> InstalledDatasetUpdateState {
        switch status {
        case .upToDate, .missing:
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

    private func map(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        guard let registryError = error as? DatasetRegistryError else {
            return .unexpected(.invariantViolation)
        }
        switch registryError {
        case .readFailed:
            return .localStorage(.readFailed)
        case .writeFailed:
            return .localStorage(.writeFailed)
        case .corrupted, .unsupportedSchemaVersion:
            return .localStorage(.corrupted)
        }
    }
}
